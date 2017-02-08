. ~/.bash_functions

if [ "$(uname)" = 'Darwin' ]; then
    # Enable terminal colors on OS X
    export CLICOLOR=1
    # Reset path from launchctl
    export PATH="$(launchctl getenv PATH)"
    # Open URIs with a generic open command
    export BROWSER=open

    [ -f ~/.iterm2_shell_integration.bash ] && source ~/.iterm2_shell_integration.bash
else
    export BROWSER=xdg-open
fi

# Don't put duplicate or same successive entries in the history
export HISTCONTROL=ignoredups:ignoreboth

# Configure Bash prompt
export PROMPT_DIRTRIM=3

# Configure less
export VIEW=less
export PAGER="$VIEW"
export LESS="-Ri -b1024 -X"
command_available vimpager && export MANPAGER=vimpager

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
export GIT_PS1_SHOWUPSTREAM=yes

# Configure GCC Colors
export GCC_COLORS='error=01;31:warning=00;33:note=00;36:caret=01;32:locus=01:quote=01'

# Configure lesspipe
if command_available lesspipe; then
    LESSPIPE=lesspipe
elif command_available lesspipe.sh; then
    LESSPIPE=lesspipe.sh
fi

if command_available highlight && [ -n "$LESSPIPE" ]; then
    export LESSOPEN="| $HOME/.local/bin/lessfilter-highlight %s"
fi

# Configure dircolors if needed
command_available dircolors && eval "$(dircolors --bourne-shell)"
command_available gdircolors && eval "$(gdircolors --bourne-shell)"

# Try to find a JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    if [ -x '/usr/libexec/java_home' ]; then
        export JAVA_HOME=$(/usr/libexec/java_home)
    elif [ -L '/etc/alternatives/java' ]; then
        # there may be a neater way to do this but i don't care atm
        export JAVA_HOME="$(dirname $(dirname $(dirname $(readlink /etc/alternatives/java))))"
    fi

    [ -n "$JAVA_HOME" -a -z "$JDK_HOME" ] && export JDK_HOME="$JAVA_HOME"
fi

# Enable Rust backtraces
export RUST_BACKTRACE=1

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
if gls --version &>/dev/null; then
    alias ls="gls --format=across --classify --size --color=auto"
elif ls --version &>/dev/null; then
    alias ls="ls --format=across --classify --size --color=auto"
else
    alias ls="ls -xFsG"
fi

command_available colordiff && alias diff="colordiff"
command_available vim && alias vi=vim

## Enable bash_completion
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
[ -r /etc/bash_completion ] && ! shopt -oq posix && . /etc/bash_completion
[ -r /usr/share/git-core/contrib/completion/git-prompt.sh ] && . /usr/share/git-core/contrib/completion/git-prompt.sh
[ -n "$have_homebrew" -a -f $brew_prefix/etc/bash_completion ] && . $brew_prefix/etc/bash_completion
[ -r $HOME/.bash_completion ] && . $HOME/.bash_completion

## Enable Git prompt support
[ -n "$have_homebrew" -a -f $brew_prefix/etc/bash_completion.d/git-prompt.sh ] && . $brew_prefix/etc/bash_completion.d/git-prompt.sh

if ! type __git_ps1 &>/dev/null; then
    __git_ps1() {
        return 0
    }
fi

## Enable rbenv
if command_available rbenv; then
  eval "$(rbenv init -)"
  __rbenv_prompt="\[\e[0;34m\]\$(rbenv version-name)"
else
  __rbenv_prompt=''
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

if [ $UID -eq 0 ]; then
    __ps1_username_color='31'
else
    __ps1_username_color='32'
fi

if logged_in_remotely; then
    __ps1_host_color='1;36'
    __ps1_user_host="\[\e[${__ps1_username_color}m\]\u\[\e[m\]@\[\e[${__ps1_host_color}m\]\h\[\e[m\]:"
else
    __ps1_host_color='36'
    __ps1_user_host=''
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
    PS1="${__ps1_user_host}"'\[\e[34m\]\w\[\e[1;31m\]$(__git_email_check)\[\e[0;35m\]$(__git_ps1 "(%s)")'"${char} "
    [ -n "$__rbenv_prompt" ] && PS1="${__rbenv_prompt} $PS1"
}

case "$TERM" in
    xterm*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
esac

PROMPT_COMMAND="__update_ps1;$PROMPT_COMMAND"


