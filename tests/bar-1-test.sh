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
	rerun beeroclock:bar
  	test -f ~/.beeroclock/container.txt
  	.  ~/.beeroclock/container.txt
	test "true" = "$(docker inspect -f '{{.State.Running}}' "$CONTAINERID")"
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