# Shell functions for the beeroclock module.
#/ usage: source RERUN_MODULE_DIR/lib/functions.sh command
#

# Read rerun's public functions
[[ -n "${RERUN:-}" ]] && {
	. "$RERUN" || {
    	echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
	    return 1
	}
}


# Source the option parser script.
#
if [[ -r "$RERUN_MODULE_DIR/commands/$1/options.sh" ]] 
then
    . "$RERUN_MODULE_DIR/commands/$1/options.sh" || {
        rerun_die "Failed loading options parser."
    }
fi

# - - -
# Your functions declared here.
# - - -

