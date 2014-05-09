export PRINTER=reverehouse

# Take a directory (or a dir name for cdr) and set $d to the subpath below
# google3 (if any) Also sets many other useful vars for parts of the google3
# tree.
g4dir() {
        emulate -L zsh
        integer use_cdr silent
        local dir
        while getopts "nv" opt
        do
                case $opt in
                        (n) use_cdr=1  ;;
                        (s) silent=1  ;;
                        (*) echo 1>&2 "Unknown option: -$opt"; return 1 ;;
                esac
        done
        shift $(( OPTIND - 1 ))
	if (( $# == 0 )); then
                if [[ $d == "" ]] ; then
                        echo No google3 dir set
			return 1
                fi
		echo "$d"
		return 0
	fi

	cd "$@" 2>/dev/null || cdr "$@" || return 1
	d="${PWD#**/google3/}"
	if [[ $d == $PWD ]]; then
		echo 1>&2 No google3 dir in "'$PWD'"
		return 1
	fi
	t="${PWD%/$d}"		# top dir (the google3 dir)
	g="$t/blaze-genfiles"	# generated files
	gg="$g/$d"		# ... for this dir
	b="$t/blaze-bin"	# binary files
	bb="$b/$d"		# ... for this dir
	l="$t/blaze-testlogs"	# test log files
	ll="$l/$d"		# ... for this dir
	o="$t/blaze-out"	# output files
	oo="$o/$d"		# ... for this dir
	if (( ! silent )); then
		echo $d
	fi
}

func pa() {
	prodaccess "$@" --ssh_cert --kinit && . ~/.ssh/agent.kcrca.cam.corp.google.com
}

# This is wrong, there must be some way to do this: Run godoc or whatever to
# publish the HTML godoc for the current dir, or the current google3 or
# something like that.
func g4doc() {
	set -x
	godoc "$@" -port 8080 -local_google3=$t -logtostderr .
}
