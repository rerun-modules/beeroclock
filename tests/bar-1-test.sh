#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p bar [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "bar"

it_starts() {
    rerun beeroclock:bar --rebuild true
    test -f ~/.beeroclock/container.txt
    .  ~/.beeroclock/container.txt
    test "true" = "$(docker inspect -f '{{.State.Running}}' "$CONTAINERID")"
    sleep 2
    # end to end test to see if docker port mapping and xinetd are working
    curl http://127.0.0.1:28080/beer | grep "========.   mb$" - 
    docker stop "$CONTAINERID"
    rm  ~/.beeroclock/container.txt
}

it_stops() {
    rerun beeroclock:bar
    test -f ~/.beeroclock/container.txt
    .  ~/.beeroclock/container.txt

    rerun beeroclock:bar --close true
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
