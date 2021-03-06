#!/usr/bin/env bash



# date - use gnu date
date() {
  if [[ "$(uname)" == "Darwin" ]]
  then
    gdate "${@:1}"
  else
    command date "${@:1}"
  fi
}

beer_o_clock() {
  if [[ "$1" == "" ]]; then
    echo -e "It's the weekend, you must be out of beer.\nGo get some more beer and afterwards reward yourself with two!"
  elif [[ "$(( 10#$2 ))" -ge "$1" ]]; then
    echo -e "Wait... you're not drinking?\nIt's $(date '+%H:%M')!\nGrab a fucking lager, ale or something that isn't water."
  else
    local now=$(date -d 'now' '+%s')
    local later=$(date -d "today ${1}:00:00" '+%s')
    local hrsUntil=$(( ( later - now ) / 60 / 60 % 24 ))
    local minUntil=$(( ( later - now ) / 60 % 60 ))

    echo "T-minus $hrsUntil hour(s) and $minUntil minute(s) until beer o'clock."
  fi
}

# beertime - why we're really here
beertime() {
  local hrs=
  hrs=$(date +"%H")
  local day=
  day=$(date +"%w")
  case $day in
    [1-4]*) beer_o_clock 17 "${hrs}";; # mon - thurs
    5) beer_o_clock 16 "${hrs}";; # fri
    *) beer_o_clock;; # sat/sun
  esac
}

# buildRespBody
# param: $1 content-type (String)
buildRespBody() {
  # request timezone
  local reqTZ="$(curl -sSL "https://ipapi.co/${REMOTE_HOST}/timezone")"
  local time=
  time="$(TZ=$reqTZ beertime)"

  if [[ "$1" == 'plain' ]]; then
    printf "%s\r" "${time}"
  elif [[ "$1" == 'json' ]]; then
    local beertime=true
    if [[ "$time" =~ 'T\-minus' ]]; then
      beertime=false
    fi
    echo "{\"success\":true,\"status_code\":200,\"status_text\":\"OK\",\"content\":{\"beertime?\":$beertime,\"message\":\"$(echo "${time}" | tr '\n' ' ')\"}}"
  elif [[ "$1" == 'html' ]]; then
    time=$(echo "$time" | sed ':a;N;$!ba;s/\n/\<\/br\>/g')
    echo "<html><head><link rel='shortcut icon' type='image/x-icon' href='/favicon.ico'></head><body style='font-family: monospace; font-size: 32px;'><p>$time</p></body></html>"
  else
    printf 'Internal Error: No Content-Type passed into buildRespBody.\nPlease file an issue here https://github.com/hhsnopek/beerokclock with the current URL.\nThank you!\r'
  fi
}

# respond
# params:
#   $1 - content-type (String)
#   $2 - body         (String)
respond() {
  echo "HTTP/1.1 200 OK"
  if [[ "$1" == 'application/json' ]]; then
    echo "Connection: keep-alive"
    echo "Transfer-Encoding: identity"
  else
    echo "Connection: close"
  fi
  echo "Content-Type: $1; charset=utf-8"
  let length=${#2}+1
  echo "Content-Length: ${length}"
  echo 'Link: </favicon.ico>; rel="icon"'
  echo "Host: beero.cl"
  echo "Date: $(TZ=UTC; date '+%a, %d %b %Y %T GMT')"
  echo -e "\n$2"
  sleep 1
}

# permRedirect
permRedirect() {
  echo 'HTTP/1.1 301 Moved Permanently'
  echo 'Location: http://beero.cl/ock'
}

log() {
  local message=$1
  printf "%s: %s\n" "$(date "+%y/%m/%d@%T")" "$message" >> "$LOG"
}


# -----------------------------------------------------------------------------
# Check if this file is being sourced, or executed.
# If not being executed, return now.
if [[ "${BASH_SOURCE:-}" != "$0" && "$0" != "bash" ]]
then
    return; # Stop sourcing the file here.
fi
# -----------------------------------------------------------------------------

LOG=/var/log/beeroclock.log

read -r request
log "REQUEST: $request"


[[ "$request" == "quit" ]] && exit 0

#while true; do
#  read -r header
#  [ "$header" == $'\r' ] && break
#done


# parse url & path
url="${request#GET }"
url="${url% HTTP/*}"
path="${url%%\?*}"
query="${url#*\?}"
if [[ "$path" == "$query" ]]; then
  query=''
fi

# parse it all
altResp=false
if [[ "$path" == '/ock.html' || "$query" == 'type=html' ]]; then # html
  type='html'
  contentType='text/html'
elif [[ "$path" == '/ock.json' || "$query" == 'type=json' ]]; then # json
  type='json'
  contentType='application/json'
elif [[ "$path" == '/ock' && "$query" == '' || "$query" == 'type=plain' ]]; then
  type='plain'
  contentType='text/plain'
elif [[ "$path" == '/beer' ]]; then # beer asciiart
  type='plain'
  contentType='text/plain'
  body=$(cat "$(dirname "$0")"/beer.asciiart)
  respond "$contentType" "$body"
  exit 0
elif [[ "$path" == '/favicon' || "$path" == '/favicon.ico' ]]; then # beer emoji
  altResp=true
  echo 'HTTP/1.1 200 OK'
  echo -e "Content-Type: image/x-icon; charset=binary\n"
  cat "$(dirname "$0")"/favicon.ico
  exit 0
elif [[ "${#query}" -gt 9 ]]; then # Unsupported Content-Type
  altResp=true
  echo 'HTTP/1.1 415 Unsupported Media Type'
  echo -e "\n415 Unsupported Media Type"
  exit 0
else # unknown route
  altResp=true
  permRedirect
  exit 0
fi

# if no alternative response, respond
if [[ "$altResp" == false ]]; then
  body="$(buildRespBody $type)"
  respond "$contentType" "$body"
  exit 0
fi
