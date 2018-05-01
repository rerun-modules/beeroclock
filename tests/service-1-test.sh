#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m beeroclock -p service [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh


. "$RERUN_MODULE_HOME_DIR"/lib/server/service.sh


# The Plan
# --------
describe "service"

it_diffTime() {
	diffTime
}

it_calculates_beertime(){
	beertime
}

it_caclulates_beer_o_clock(){
	beer_o_clock
}