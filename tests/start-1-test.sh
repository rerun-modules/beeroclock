#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p start [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "start"


it_starts() {
	
	cleanup

    rerun beeroclock:start
    test -f ~/.beeroclock/container.txt
    .  ~/.beeroclock/container.txt
    test "true" = "$(docker inspect -f '{{.State.Running}}' "$CONTAINERID")"
    sleep 2
    # end to end test to see if docker port mapping and xinetd are working
    curl http://127.0.0.1:28080/beer | grep "========.   mb$" - 
    docker stop "$CONTAINERID"
    rm  ~/.beeroclock/container.txt
}
