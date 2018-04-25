#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p serve [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "serve"

before() {
	OUT=$(mktemp -t "service-XXX.txt")
}
after() {
	rm "$OUT"
}

# $ rerun beeroclock: serve
# GET /ock
# HTTP/1.1 200 OK
# Connection: close
# Content-Type: text/plain; charset=utf-8
# Content-Length: 55
# Link: </favicon.ico>; rel="icon"
# Host: beero.cl
# Date: Wed, 25 Apr 2018 15:07:01 GMT

# T-minus 1 hour(s) and 52 minute(s) until beer o'clock.
it_serves_ock() {
    rerun beeroclock:serve <<< "GET /ock" > "$OUT"
    grep 'HTTP/1.1 200 OK' "$OUT"
    grep 'Content-Type: text/plain' "$OUT"
}

it_serves_beer() {
    rerun beeroclock:serve <<< "GET /beer" > "$OUT"
    grep 'HTTP/1.1 200 OK' "$OUT"
    grep 'Content-Type: text/plain' "$OUT"
    grep 'Content-Length: 247' "$OUT"
}




