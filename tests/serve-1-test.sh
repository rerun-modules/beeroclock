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

it_serves() {
    result=$(rerun beeroclock:serve)
    test "$result" = "Time for beer!"
}


