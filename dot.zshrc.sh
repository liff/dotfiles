command_available() {
    type "$1" &>/dev/null
}

# Lines configured by zsh-newuser-install
HISTFILE=~/.local/share/zsh/history
HISTSIZE=2147483647
SAVEHIST=2147483647
setopt appendhistory nomatch notify
unsetopt autocd beep extendedglob
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/olli/.config/zsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


## Configuration for things that use environment variables.

# Use xdg-open to open random things.
[ -z "$BROWSER" ] && command_available xdg-open export BROWSER=xdg-open

# Configure GNUPG.
export GPG_TTY=$(tty)

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
export GIT_PS1_SHOWUPSTREAM=yes
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

setopt PROMPT_SUBST
PS1='%F{blue}%(5~|%-2~/…/%3~|%4~)%F{magenta}$(__git_ps1 "(%s)")%(?|%F{yellow}|%F{red})⟫%f '

