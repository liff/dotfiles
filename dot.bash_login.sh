. ~/.bash_functions

# cache $(uname) information
__UNAME="$(uname)"

if [ "$__UNAME" = 'Darwin' ]; then
    __OSX=yes
fi

# Enable terminal colors on OS X
[ -n $__OSX ] && export CLICOLOR=1

# Reset path from launchctl
[ -n $__OSX ] && export PATH="$(launchctl getenv PATH)"

# Don't put duplicate or same successive entries in the history
export HISTCONTROL=ignoredups:ignoreboth

# Configure Bash prompt
export PROMPT_DIRTRIM=3

# Configure less
export VIEW=less
export PAGER="$VIEW"
export LESS="-Ri -b1024 -X"
command_available vimpager && export MANPAGER=vimpager

# Open URIs with a generic open command
if [ -n $__OSX ]; then
    export BROWSER=open
else
    export BROWSER=xdg-open
fi

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
export GIT_PS1_SHOWUPSTREAM=yes

# Try to find a JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    if [ -x /usr/libexec/java_home ]; then
        export JAVA_HOME=$(/usr/libexec/java_home)
    elif [ -L /etc/alternatives/java ]; then
        # there may be a neater way to do this but i don't care atm
        export JAVA_HOME="$(dirname $(dirname $(dirname $(readlink /etc/alternatives/java))))"
    fi

    [ -n "$JAVA_HOME" -a -z "$JDK_HOME" ] && export JDK_HOME="$JAVA_HOME"
fi

# Configure GCC Colors
export GCC_COLORS='error=01;31:warning=00;33:note=00;36:caret=01;32:locus=01:quote=01'

# Configure lesspipe
if command_available lesspipe; then
    LESSPIPE=lesspipe
elif command_available lesspipe.sh; then
    LESSPIPE=lesspipe.sh
fi

if command_available highlight && [ -n "$LESSPIPE" ]; then
    export LESSOPEN="| $HOME/bin/lessfilter-highlight %s"
fi

# Configure dircolors if needed
command_available dircolors && eval "$(dircolors --bourne-shell)"

[ -f ~/.iterm2_shell_integration.bash ] && source ~/.iterm2_shell_integration.bash

. ~/.bashrc
