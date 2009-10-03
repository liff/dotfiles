## -*- sh -*-

### Load helper functions
. ~/.funcs.decl.sh


### Set environment variables
[ -d ~/bin ] && export PATH=$PATH:~/bin

# don't put duplicate or same successive entries in the history
export HISTCONTROL=ignoredups:ignoreboth

export VIEW=$(choose less more pg)
if [ "$VIEW" = "less" ]; then
    # - allow less to display ANSI colors
    # - ignore case in searches
    # - use 1MB buffer size (memory is sooo cheap :)
    export LESS="-Ri -b1024"
fi

# choose a preferred browser
if [ ! -z "$DISPLAY" ]; then
    # graphical
    export BROWSER=$(choose google-chrome firefox links elinks)
else
    # text-mode
    export BROWSER=$(choose elinks links lynx)
fi

# use lesspipe and dircolors if available
exists lesspipe && eval $(lesspipe)
exists dircolors && eval $(dircolors --bourne-shell)

# apply host-specific settings
[ -f ~/.environment.local ] && . ~/.environment.local


### Clean up
. ~/.funcs.clean.sh
