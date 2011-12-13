## -*- sh -*-

# Returns true if command is in path.
exists() {
    local IFS=: element
    if [ "${1#/}" != "$1" ]; then
        command -v "$1" &>/dev/null && return 0
    else
        for element in $PATH; do
            [ ! -z "$element" -a -x "$element/$1" ] && return 0
        done
    fi
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

maybe_gnu_ls_options() {
    local ls
    if ls --version &>/dev/null; then
        ls=ls
    elif gls --version &>/dev/null; then
        ls=gls
    else
        return 0
    fi
    alias ls="${ls} --format=across --classify --size --color=auto"
}

find_home() {
    (cmd="$(command -v $1)" \
    && while [ -L "$cmd" ]; do \
        cd "$(dirname $cmd)" \
        && cmd="$(readlink $(basename $cmd))"; \
    done \
    && cd $(dirname $cmd)/.. \
    && pwd)
}

if exists svnversion; then
    __svn_ps1() {
        local v=$(svnversion)
        [ "$v" != "exported" ] && echo "(${v})"
    }
else
    __svn_ps1() {
        return 0
    }
fi
