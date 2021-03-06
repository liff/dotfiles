. ~/.bash_functions

[ -r ~/.bash_secrets ] && . ~/.bash_secrets


if [ "$(uname)" = 'Darwin' ]; then
    # Enable terminal colors on OS X
    export CLICOLOR=1
    # Reset path from launchctl
    __launchctl_path="$(launchctl getenv PATH)"
    [ -n "$__launchctl_path" ] && export PATH="$__launchctl_path"
    # Open URIs with a generic open command
    export BROWSER=open

    [ -f ~/.iterm2_shell_integration.bash ] && . ~/.iterm2_shell_integration.bash

    [ -z "$NPM_CONFIG_PREFIX" ] && export NPM_CONFIG_PREFIX=$HOME/Library/Caches/npm-packages
    export LESSHISTFILE="$HOME/Library/Caches/lesshst"
    export HTTPIE_CONFIG_DIR="$HOME/Library/Preferences/httpie"
else
    export BROWSER=xdg-open
    prepend_to_path_if_exists $HOME/.cargo/bin $HOME/.local/bin $HOME/.cache/npm-packages/bin
fi

# Don't put duplicate or same successive entries in the history
[ -n "$XDG_DATA_HOME" ] && export HISTFILE=$XDG_DATA_HOME/bash/history
export HISTCONTROL=ignoredups:ignoreboth
export HISTSIZE=2147483647

# Configure Bash prompt
export PROMPT_DIRTRIM=3

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
export GIT_PS1_SHOWUPSTREAM=yes

# Configure GNUPG
export GPG_TTY=$(tty)

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
if [ -r ~/.dir_colors ]; then
    DIR_COLORS_DB=~/.dir_colors
else
    DIR_COLORS_DB=""
fi
command_available dircolors && eval "$(dircolors --bourne-shell $DIR_COLORS_DB)"
command_available gdircolors && eval "$(gdircolors --bourne-shell $DIR_COLORS_DB)"

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
if command_available exa; then
    alias ls="exa --grid --across --group-directories-first --color-scale --git"
    alias ll="exa --color-scale --long --all --group-directories-first --header --git"
elif command_available gls && gls --version &>/dev/null; then
    alias ls="gls --format=across --classify --size --color=auto"
    alias ll="gls --format=long --classify --size --color=auto --all"
elif ls --version &>/dev/null; then
    alias ls="ls --format=across --classify --size --color=auto"
    alias ll="ls --format=long --classify --size --color=auto --all"
else
    alias ls="ls -xFsG"
    alias ll="ls -lxFsGa"
fi

command_available colordiff && alias diff="colordiff"

command_available vim && alias vi=vim

# Add 'vj' command for viewing JSON files
if command_available highlight && command_available json_pp; then
    vj() {
        json_pp < "$1" | highlight --syntax=json --quiet --out-format=xterm256 --line-numbers --style=solarized-light | less
    }
else
    vj() {
        less "$1"
    }
fi

alias amm="amm --home $HOME/.local/share/ammonite"
alias wget="wget --hsts-file=$HOME/.cache/wget-hsts"

## Enable fzf
[ -r /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash
[ -r /usr/local/opt/fzf/shell/completion.bash ] && . /usr/local/opt/fzf/shell/completion.bash
[ -r /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash
[ -r /usr/local/opt/fzf/shell/key-bindings.bash ] && . /usr/local/opt/fzf/shell/key-bindings.bash

## Enable bash_completion
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
[ -r /etc/bash_completion ] && ! shopt -oq posix && . /etc/bash_completion
[ -r /usr/share/git-core/contrib/completion/git-prompt.sh ] && . /usr/share/git-core/contrib/completion/git-prompt.sh
[ -r /usr/share/git/git-prompt.sh ] && . /usr/share/git/git-prompt.sh
[ -r /usr/local/etc/bash_completion.d/git-prompt.sh ] && . /usr/local/etc/bash_completion.d/git-prompt.sh
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
    local char='⟫'
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
    [ -n "$__rbenv_prompt" ] && is_ruby_project . && PS1="${__rbenv_prompt} $PS1"
}

if [ -r /etc/profile.d/vte.sh -a -n "$VTE_VERSION" ]; then
    . /etc/profile.d/vte.sh
    case "$TERM" in
        xterm*|vte*) PROMPT_COMMAND="__vte_prompt_command" ;;
    esac
else
    case "$TERM" in
        xterm*|vte*) PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"' ;;
    esac
fi

PROMPT_COMMAND="__update_ps1;$PROMPT_COMMAND"

