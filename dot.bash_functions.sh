command_available() {
    type "$1" &>/dev/null
}

logged_in_remotely() {
    test -n "$SSH_TTY"
}
