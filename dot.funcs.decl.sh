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

# Returns true if terminal supports colors.
color_support() {
    # Assume Linux if /usr/share/terminfo exists. dunno if this is correct
    if [ "$TERM" = "xterm-color" ] || [ -d /usr/share/terminfo ]; then
	return 0
    else
	return 1
    fi
}
