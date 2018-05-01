#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p client [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

. "$RERUN_MODULE_HOME_DIR"/lib/functions.sh

mock_response() {
cat <<'EOF'
HTTP/1.1 200 OK
Connection: keep-alive
Transfer-Encoding: identity
Content-Type: application/json; charset=utf-8
Content-Length: 193
Link: </favicon.ico>; rel="icon"
Host: beero.cl
Date: Fri, 27 Apr 2018 16:14:18 GMT

{"success":true,"status_code":200,"status_text":"OK","content":{"beertime?":true,"message":"Wait... you're not drinking? It's 16:14! Grab a fucking lager, ale or something that isn't water. "}}
EOF
}

# The Plan
# --------
describe "client"


it_submits_request() {
	cleanup
	
	if ! container=$(docker run -p 127.0.0.1:28080:28080 --privileged -d beeroclock)
	then
		printf >&2 "ERROR: Failure starting container."
		return 1
	fi
	sleep 5

	if ! json=$(rerun beeroclock:client --url http://localhost:28080/ock.json)
	then
		printf "ERROR: Caught error making client request ...cleaning up and bailing test."
		docker kill "$container"
		return 1
	fi
	test -n "$json"
	jq -e '.' <<< "$json"

	test 'true' = "$(jq '.success'     <<< "$json")"
	test '200'  = "$(jq '.status_code' <<< "$json")"
	test '"OK"' = "$(jq '.status_text' <<< "$json")"

	test 'true' = "$(jq '.content | .["beertime?"]' <<< "$json")"

	docker kill "$container"
}