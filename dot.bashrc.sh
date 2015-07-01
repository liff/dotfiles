## -*- sh -*-

if [ -z "$rvm_version" ]; then
    if [[ -s "${rvm_path}/scripts/rvm" ]]; then
        . "${rvm_path}/scripts/rvm"
    elif [[ -s "${HOME}/.rvm/scripts/rvm" ]]; then
        . "$HOME/.rvm/scripts/rvm"
    elif [[ -s "/usr/local/rvm/scripts/rvm" ]]; then
        . "/usr/local/rvm/scripts/rvm"
    fi
fi

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
    choose_ls_alias
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

    if [ -n "$PAGER" -a "$PAGER" != "less" ]; then
        alias less=$PAGER
        alias zless=$PAGER
    fi

    exists xdg-open && alias open="xdg-open"

    ## bash completion
    [ -f /etc/bash_completion ] && ! shopt -oq posix && . /etc/bash_completion
    exists brew && [ -f `brew --prefix`/etc/bash_completion ] && . `brew --prefix`/etc/bash_completion

    ## Git prompt and completion
    if exists brew && [ -f `brew --prefix git`/share/git-core/git-prompt.sh ]; then
        . `brew --prefix git`/share/git-core/git-prompt.sh
    elif [ -f /usr/share/git-core/git-prompt.sh ]; then
        . /usr/share/git-core/git-prompt.sh
        [ -f /usr/share/git-core/git-completion.bash ] && . /usr/share/git-core/git-completion.bash
    fi

    ## set prompt
    if ! type __git_ps1 &>/dev/null; then
        __git_ps1() {
            return 0
        }
    fi

    if grep '^prompt' ~/.hgrc &>/dev/null; then
        __hg_ps1() {
            hg prompt "$@" 2>/dev/null
        }
    else
        __hg_ps1() {
            return 0
        }
    fi

    __rvm_prompt=''
    __rbenv_prompt=''
    if [ -n "$rvm_version" ]; then
        rvm_prompt_space() {
            [[ -n "$(rvm-prompt)" ]] && echo " "
        }
        __rvm_prompt="\[\e[1;34m\]\$(rvm-prompt i)\[\e[0;34m\]\$(rvm-prompt v)\[\e[0;31m\]\$(rvm-prompt g)\$(rvm_prompt_space)"
    elif exists rbenv; then
        # Start rbenv, if installed
        exists rbenv && eval "$(rbenv init -)"
        __rbenv_prompt="\[\e[0;34m\]\$(rbenv version-name)"
    fi

    if exists bundle; then
        bex() {
            if test -r Gemfile.lock; then
                bundle exec "$@"
            else
                command "$@"
            fi
        }

        for cmd in rake rspec cap guard rackup spork thin whenever; do
            alias $cmd="bex ${cmd}"
        done
    fi

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

    # colourized prompt
    __update_ps1() {
        local char=$(__ps1_char)
        PS1='\[\e['"${__ps1_username_color}"'m\]\u\[\e[m\]@\[\e['"${__ps1_host_color}"'m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[35m\]$(__git_ps1 "(%s)")$(__hg_ps1 "({branch}{status})")$(__svn_ps1)'"${char} "
        [ -n "$__rbenv_prompt" ] && PS1="${__rbenv_prompt} $PS1"
        [ -n "$__rvm_prompt" ] && PS1="${__rvm_prompt} $PS1"
    }

    # show user/host in xterm
    case "$TERM" in
        xterm*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
    esac

    PROMPT_COMMAND="__update_ps1;$PROMPT_COMMAND"

    ## clean up
    . ~/.funcs.clean
fi
