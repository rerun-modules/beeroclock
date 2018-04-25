#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p beer [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "beer"

it_serves_a_beer() {
    rerun beeroclock:beer
}

