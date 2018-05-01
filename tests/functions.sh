cleanup() {
	if ! cid=$(docker ps -q --filter="ancestor=beeroclock")
	then
		return 0; # nothing to cleanup
	fi
	if [[ -n "$cid" ]]
	then
		echo "Stopping container: $cid"
		docker stop "$cid"
	fi
}
