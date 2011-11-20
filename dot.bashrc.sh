## -*- sh -*-

# no need to run this for non-interactive shell
if [[ -n "$PS1" ]]; then

    ## load helper functions
    . ~/.funcs.decl

    ## set bash options
    set -o notify
    shopt -s			\
        cdspell			\
        checkhash		\
        checkwinsize		\
        extglob			\
        histreedit		\
        histverify		\
        gnu_errfmt		\
        no_empty_cmd_completion
    shopt -u			\
        dotglob			\
        hostcomplete		\
        lithist


    ## define aliases
    maybe_gnu_ls_options
    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
    alias cgrep="grep --line-number --color=auto --exclude-dir=.{svn,git} --exclude='*~' --exclude='*.log' --recursive --binary-files=without-match"
    exists ack-grep && \
        alias ack="ack-grep"
    alias gdb="gdb --quiet --tui"
    exists notify-send && \
        alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
    exists colordiff && alias diff="colordiff"
    test -d /opt/RubyMine && \
        alias rmspork='RUBYLIB=/opt/RubyMine/rb/testing/patch/common:/opt/RubyMine/rb/testing/patch/bdd:/opt/RubyMine/rb/testing/patch/testunit spork'
    alias bex="bundle exec"

    if [ "$PAGER" != "less" ]; then
        alias less=$PAGER
	alias zless=$PAGER
    fi

    ## bash completion
    [ -f /etc/bash_completion ] && ! shopt -oq posix && . /etc/bash_completion
    exists brew && [ -f `brew --prefix`/etc/bash_completion ] && . `brew --prefix`/etc/bash_completion

    ## set prompt

    # show user/host in xterm
    case "$TERM" in
        xterm*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
    esac

    # colourized prompt
    if [ $UID -eq 0 ]; then
        # ROOT prompt (sudo, etc)
        if logged_in_remotely; then
            PS1='\[\e[31m\]\u\[\e[m\]@\[\e[1;36m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]\$\[\e[m\] '
        else
            PS1='\[\e[31m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]\$\[\e[m\] '
        fi
    else
        # normal prompt
        if logged_in_remotely; then
            PS1='\[\e[32m\]\u\[\e[m\]@\[\e[1;36m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]>\[\e[m\] '
        else
            PS1='\[\e[32m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")\[\e[33m\]>\[\e[m\] '
        fi
    fi


    ## clean up
    . ~/.funcs.clean
fi

if [ -z "$rvm_version" ]; then
    if [[ -s "${rvm_path}/scripts/rvm" ]]; then
        . "${rvm_path}/scripts/rvm"
    elif [[ -s "${HOME}/.rvm/scripts/rvm" ]]; then
        . "$HOME/.rvm/scripts/rvm"
    elif [[ -s "/usr/local/rvm/scripts/rvm" ]]; then
        . "/usr/local/rvm/scripts/rvm"
    fi
fi

if [ -n "$rvm_version" ]; then
    rvm_prompt_space() {
	[[ -n "$(rvm-prompt)" ]] && echo " "
    }
    PS1="\[\e[1;34m\]\$(rvm-prompt i)\[\e[0;34m\]\$(rvm-prompt v)\[\e[0;31m\]\$(rvm-prompt g)\$(rvm_prompt_space)$PS1"
fi
