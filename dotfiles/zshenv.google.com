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

	# $d is the path below google3 to this dir
	t="${PWD%/$d}"		# full path to top dir (the google3 dir)
	g="$t/blaze-genfiles"	# generated files
	b="$t/blaze-bin"	# binary files
	l="$t/blaze-testlogs"	# test log files
	o="$t/blaze-out"	# output files
	tt="$t/$d"		# ... plus this dir
	gg="$g/$d"		# ... plus this dir
	bb="$b/$d"		# ... plus this dir
	ll="$l/$d"		# ... plus this dir
	oo="$o/$d"		# ... plus this dir

	# for use in scripts
	export G4_CUR="$d"
	export G4_TOP="$t"
	export G4_GEN="$g"
	export G4_BIN="$b"
	export G4_LOG="$l"
	export G4_OUT="$o"
	export G4_CUR_TOP="$tt"
	export G4_CUR_GEN="$gg"
	export G4_CUR_BIN="$bb"
	export G4_CUR_LOG="$ll"
	export G4_CUR_OUT="$oo"

	if (( ! silent )); then
		echo $d
	fi
}

export MCNODE_HOST=wgrk15
