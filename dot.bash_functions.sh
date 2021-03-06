command_available() {
    type -p "$1" &>/dev/null
}

logged_in_remotely() {
    test -n "$SSH_TTY"
}

prepend_to_path_if_exists() {
    local IFS=:

    local dir
    for dir in "$@"; do
        for entry in $PATH; do [ "$entry" = "$dir" ] && continue 2; done
        export PATH="${dir}:${PATH}"
    done
}

is_ruby_project() {
    if [ ! -d "$1" ]; then
        return 0
    elif [ "$(realpath "$1")" = "$HOME" -o "$(realpath "$1")" = '/' ]; then
        return 1
    elif [ "$(echo "$1"/*.rb)" != "$1/*.rb" -o -f "$1"/Gemfile -o -f "$1"/*.gemspec ]; then
        return 0
    else
        is_ruby_project "$1"/..
    fi
}

