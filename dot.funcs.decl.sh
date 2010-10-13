## -*- sh -*-

# Returns true if command is in path.
exists() {
    local IFS=: element
    for element in $PATH; do
	[ ! -z "$element" -a -x "$element/$1" ] && return 0
    done
    return 1
}

# Given a list of programs, returns the first one
# that can be found in path.
choose() {
    local alt
    for alt in "$@"; do
	if exists $alt; then
	    echo $alt
	    return 0
	fi
    done
    return 1
}

# Appends the argument to path if the directory exists
append_to_path_if_exists() {
    local dir
    for dir in "$@"; do
	[ -d "$dir" ] && export PATH="${PATH}:${dir}"
    done
}

prepend_to_path_if_exists() {
    local dir
    for dir in "$@"; do
        [ -d "$dir" ] && export PATH="${dir}:${PATH}"
    done
}

logged_in_remotely() {
    test -n "$SSH_TTY"
}

