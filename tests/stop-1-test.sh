#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p stop [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "stop"


it_stops() {
	cleanup

    rerun beeroclock:start
    test -f ~/.beeroclock/container.txt
    .  ~/.beeroclock/container.txt

    rerun beeroclock:stop
    ! test -f ~/.beeroclock/container.txt
    
    status=$(docker inspect -f '{{.State.Running}}' "$CONTAINERID")
    case "$status" in
        true)
            docker stop "$CONTAINERID"
            rm  ~/.beeroclock/container.txt
        ;;
        false)
            echo "the service was stopped"
        ;;
    esac
}
