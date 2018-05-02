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
	t=$(diffTime)
	test "$t" = 0
}

it_calculates_beertime(){
	beertime
}

it_caclulates_beer_o_clock(){
	beer_o_clock | grep "It's the weekend, you must be out of beer."
	beer_o_clock 12 12 | grep "Wait... you're not drinking?"
	beer_o_clock 23 2 | grep "T-minus"
}

it_beer_around_the_world() {
    base='Etc/GMT'
    let i=-12
    while (( i < 13 ))
    do
      mid=$([ ${i} -gt 0 ] && echo "+" || echo "")
      export TZ="${base}${mid}${i}"

      beertime

      (( i++ ))
    done

    #return 1
}
