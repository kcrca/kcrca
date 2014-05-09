export PRINTER=reverehouse

# Take a directory (or a dir name for cdr) and set $d to the subpath below google3 (if any)
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
        if test -z "$@"; then
                if test -z "$d"; then
                        echo No google3 dir set
			return 1
                fi
		echo "$d"
		return 0
	fi

	if
		setopt PUSHD_SILENT
		if (( use_cdr )); then
			pdr "$@"
		else
			pushd "$@"
		fi
	then
		popd
		d="${PWD#**/google3/}"
		if test x"$d" = x"$PWD" ; then
			echo 1>&2 "No google3 dir in $PWD"
			return 1
		fi
		t="${PWD%/$d}"
		g="$t/blaze-genfiles"
		d="$d"
		bb="$t/blaze-bin/$d"
		gg="$g/$d"
		if (( ! silent )); then
			echo $d
		fi
	else
		return 1
	fi
}

func pa() {
	prodaccess --ssh_cert --kinit "$@" && . ~/.ssh/agent.kcrca.cam.corp.google.com
}

func g4doc() {
	set -x
	godoc "$@" -port 8080 -local_google3=$t -logtostderr .
}
