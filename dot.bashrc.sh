. ~/.bash_functions


## Set bash options
set -o notify
shopt -s          \
    cdspell       \
    checkhash     \
    checkwinsize  \
    extglob       \
    histappend    \
    histreedit    \
    histverify    \
    gnu_errfmt    \
    no_empty_cmd_completion
shopt -u         \
    dotglob      \
    hostcomplete \
    lithist

# cache homebrew info
if command_available brew; then
    have_homebrew=yes
    brew_prefix=$(brew --prefix)
fi

## Set aliases
command_available xdg-open && alias open="xdg-open"

# Figure out whether we should use OSX's default version of ls, gls or ls as GNU ls
ls_command=ls
if gls --version &>/dev/null; then
    ls_command=gls
fi
if $ls_command --version &>/dev/null; then
    alias ls="${ls_command} --format=across --classify --size --color=auto"
else
    alias ls="${ls_command} -xFsG"
fi
unset ls_command

command_available colordiff && alias diff="colordiff"
command_available vim && alias vi=vim

## Enable bash_completion
[ -f /etc/bash_completion ] && ! shopt -oq posix && . /etc/bash_completion
[ -n "$have_homebrew" -a -f $brew_prefix/etc/bash_completion ] && . $brew_prefix/etc/bash_completion

## Enable Git prompt support
[ -n "$have_homebrew" -a -f $brew_prefix/etc/bash_completion.d/git-prompt.sh ] && . $brew_prefix/etc/bash_completion.d/git-prompt.sh

if ! type __git_ps1 &>/dev/null; then
    __git_ps1() {
        return 0
    }
fi

## Build prompt
__ps1_char() {
    local status=$?
    local char='>'
    local color="33"
    [ $UID -eq 0 ] && char='\$'
    [ $status -ne 0 ] && color="1;31"
    echo -e "\[\033[${color}m\]${char}\[\033[m\]"
}

if logged_in_remotely; then
    __ps1_host_color='1;36'
else
    __ps1_host_color='36'
fi

if [ $UID -eq 0 ]; then
    __ps1_username_color='31'
else
    __ps1_username_color='32'
fi

if command_available git; then
    __git_email_check() {
        git rev-parse --git-dir &>/dev/null && [ -z "`git config --local --get user.email`" ] && echo '@'
    }
else
    __git_email_check() {
        return 0
    }
fi

__update_ps1() {
    local char=$(__ps1_char)
    PS1='\[\e['"${__ps1_username_color}"'m\]\u\[\e[m\]@\[\e['"${__ps1_host_color}"'m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[1;31m\]$(__git_email_check)\[\e[0;35m\]$(__git_ps1 "(%s)")'"${char} "
}

case "$TERM" in
    xterm*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
esac

PROMPT_COMMAND="__update_ps1;$PROMPT_COMMAND"
