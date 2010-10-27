## -*- sh -*-

### Load helper functions
. ~/.funcs.decl


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
    export BROWSER=$(choose google-chrome chromium-browser firefox links elinks)
else
    # text-mode
    export BROWSER=$(choose elinks links lynx)
fi

# use lesspipe and dircolors if available
exists lesspipe && eval $(lesspipe)
exists dircolors && eval $(dircolors --bourne-shell)

# conditionally add some common paths
prepend_to_path_if_exists \
    /opt/scala/bin \
    /var/lib/gems/1.8/bin \
    /var/lib/gems/1.9.1/bin \
    $HOME/.cabal/bin \
    $HOME/bin

append_to_path_if_exists \
    /opt/jruby/bin \
    /opt/android/tools \
    /opt/atlassian-plugin-sdk/bin

# Java likes to have a home
if [ -L /etc/alternatives/java ]; then
    # there may be a neater way to do this but i don't care atm
    [ -z "$JAVA_HOME" ] && export JAVA_HOME=$(dirname $(dirname $(dirname $(readlink /etc/alternatives/java))))
    [ -z "$JDK_HOME" ] && export JDK_HOME="$JAVA_HOME"
fi

# Android too
[ -d /opt/android ] && export ANDROID_HOME=/opt/android

# apply host-specific settings
[ -f ~/.environment.local ] && . ~/.environment.local


### Clean up
. ~/.funcs.clean
