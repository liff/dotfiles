command_available() {
    type "$1" &>/dev/null
}

is_ruby_project() {
    unsetopt nomatch
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

autoload -Uz add-zsh-hook

## Configuration for things that use environment variables.

# Use xdg-open to open random things.
[ -z "$BROWSER" ] && command_available xdg-open export BROWSER=xdg-open

# Configure GNUPG.
[ -z "$GPG_TTY" ] && export GPG_TTY=$(tty)

# Configure completion
ZSH_CACHE_HOME="${XDG_CACHE_HOME:-~/.cache}/zsh"
mkdir -p "$ZSH_CACHE_HOME"
zstyle :compinstall filename "$ZDOTDIR/.zshrc"
autoload -Uz compinit
fpath=(/usr/share/bloop/zsh $fpath)
compinit -d "$ZSH_CACHE_HOME/zcompdump-$ZSH_VERSION"

# Start autojump
test -r /etc/profile.d/autojump.zsh && . /etc/profile.d/autojump.zsh

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
export GIT_PS1_SHOWUPSTREAM=yes
test -r /run/current-system/sw/share/git/contrib/completion/git-prompt.sh && . /run/current-system/sw/share/git/contrib/completion/git-prompt.sh
test -r /usr/share/git/git-prompt.sh && . /usr/share/git/git-prompt.sh

# Configure lesspipe.
if command_available lesspipe; then
    LESSPIPE=lesspipe
elif command_available lesspipe.sh; then
    LESSPIPE=lesspipe.sh
fi
# Use `highlight` for syntax highlighting, if available.
if command_available highlight && [ -n "$LESSPIPE" ]; then
    export LESSOPEN="| $HOME/.local/bin/lessfilter-highlight %s"
fi

# Enable Rust backtraces
export RUST_BACKTRACE=1

# Configure GCC Colors
export GCC_COLORS='error=01;31:warning=00;33:note=00;36:caret=01;32:locus=01:quote=01'

# Configure dircolors if needed
if [ -r ~/.dir_colors ]; then
    DIR_COLORS_DB=~/.dir_colors
else
    DIR_COLORS_DB=""
fi
command_available dircolors && eval "$(dircolors --bourne-shell $DIR_COLORS_DB)"
command_available gdircolors && eval "$(gdircolors --bourne-shell $DIR_COLORS_DB)"

# Configure history
HISTSIZE=2147483647
SAVEHIST=2147483647
HISTFILE=$XDG_DATA_HOME/zsh/history
mkdir -p $(dirname $HISTFILE)

# Other shell settings
setopt appendhistory nomatch notify
unsetopt autocd beep extendedglob
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char-or-list
WORDCHARS=''


## Set aliases
command_available xdg-open && alias open="xdg-open"

# Figure out whether we should use OSX's default version of ls, gls or ls as GNU ls.
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
command_available nvim && alias vi=nvim
command_available nvim && alias vim=nvim

# Aliases for XDG basedir "compliance".
alias amm="amm --home $HOME/.local/share/ammonite"
alias wget="wget --hsts-file=$HOME/.cache/wget-hsts"

## Enable fzf
if command_available fzf-share; then
    . $(fzf-share)/completion.zsh
    . $(fzf-share)/key-bindings.zsh
else
    [ -r /usr/share/fzf/completion.zsh ] && . /usr/share/fzf/completion.zsh
    [ -r /usr/local/opt/fzf/shell/completion.zsh ] && . /usr/local/opt/fzf/shell/completion.zsh
    [ -r /usr/share/fzf/key-bindings.zsh ] && . /usr/share/fzf/key-bindings.zsh
    [ -r /usr/local/opt/fzf/shell/key-bindings.zsh ] && . /usr/local/opt/fzf/shell/key-bindings.zsh
fi

test -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    && . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    && . /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

## Enable rbenv
if command_available rbenv; then
    eval "$(rbenv init -)"
    __rbenv_psvar() {
        if is_ruby_project .; then
            psvar[1]="$(rbenv version-name)"
        else
            psvar[1]=''
        fi
    }
    add-zsh-hook precmd __rbenv_psvar
fi

__git_psvar() {
    local ps="$(__git_ps1 "%s")"
    psvar[2]=${ps:s/%%/%/}
}
add-zsh-hook precmd __git_psvar

## Configure prompt
test -r /etc/profile.d/vte.sh && . /etc/profile.d/vte.sh
setopt PROMPT_SUBST
unset RPROMPT RPS1
PS1='%(1j|%F{131}⟨%F{130}%j%F{131}⟩%f |)%(1V|%F{039}%1v |)%F{069}%(5~|%-2~/…/%3~|%4~)%(2V|%F{176}(%F{164}%2v%F{176})|)%(?|%F{226}|%F{196})⟫%f '

command_available fortune && fortune

