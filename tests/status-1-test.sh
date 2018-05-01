#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p status [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "status"

it_status_RUNNING() {
    cleanup

    rerun beeroclock:start
    test -f ~/.beeroclock/container.txt
    .  ~/.beeroclock/container.txt
    test -n "$CONTAINERID"

    output=$(rerun beeroclock:status)
    echo "$output" | grep "Status beeroclock: \[RUNNING\]"
}


it_status_STOPPED() {
    cleanup
    echo "Running status command"
    if ! output=$(rerun beeroclock:status)
    then
        echo "$output" | grep "Status beeroclock: \[STOPPED\]"
    else
        echo "Status was not STOPPED"
        return 1
    fi
}
