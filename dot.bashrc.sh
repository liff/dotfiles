## -*- sh -*-

# no need to run this for non-interactive shell
[ -z "$PS1" ] && return


## load helper functions
. ~/.funcs.decl.sh

## set bash options
set -o notify
shopt -s			\
    cdspell			\
    checkhash			\
    checkwinsize		\
    extglob			\
    histreedit			\
    histverify			\
    gnu_errfmt			\
    no_empty_cmd_completion
shopt -u			\
    dotglob			\
    hostcomplete		\
    lithist


## define aliases
alias ls="ls --format=across --classify --size --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias cgrep="grep --line-number --color=auto --exclude-dir=.{svn,git} --exclude='*~' --exclude='*.log' --recursive --binary-files=without-match"
alias gdb="gdb --quiet --tui"


## bash completion
[ -f /etc/bash_completion ] && . /etc/bash_completion


## set prompt

# show user/host in xterm
case "$TERM" in
    xterm*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
esac

# colourized prompt
if [ $UID -eq 0 ]; then
    # ROOT prompt (sudo, etc)
    PS1='\[\e[31m\]\u\[\e[0m\]@\[\e[36m\]\h\[\e[0m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]\$\[\e[m\] '
else
    # normal prompt
    PS1='\[\e[32m\]\u\[\e[0m\]@\[\e[36m\]\h\[\e[0m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]\$\[\e[m\] '
fi


## clean up
. ~/.funcs.clean.sh
