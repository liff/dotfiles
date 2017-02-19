command_available() {
    type "$1" &>/dev/null
}

logged_in_remotely() {
    test -n "$SSH_TTY"
}

prepend_to_path_if_exists() {
    local IFS=:

    local dir
    for dir in "$@"; do
        for entry in $PATH; do [ "$entry" = "$dir" ] && continue 2; done
        [ -d "$dir" ] && export PATH="${dir}:${PATH}"
    done
}
