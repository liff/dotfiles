## -*- sh -*-

### Load helper functions
. ~/.funcs.decl


[ "${PATH#/usr/local/bin}" = "$PATH" ] && PATH="/usr/local/bin:$(echo "$PATH" | sed 's#/usr/local/bin##;s/:://')"

# don't put duplicate or same successive entries in the history
export HISTCONTROL=ignoredups:ignoreboth

export VIEW=$(choose less more pg)
if [ "$VIEW" = "less" ]; then
    # - allow less to display ANSI colors
    # - ignore case in searches
    # - use 1MB buffer size (memory is sooo cheap :)
    export LESS="-Ri -b1024 -X"
fi

# choose a preferred browser and editor
if [ ! -z "$DISPLAY" ]; then
    # graphical
    if [ "$(uname)" = "Darwin" ]; then
        export BROWSER=open
        export EDITOR=$(choose vim)
    else
        export BROWSER=$(choose gnome-open google-chrome chromium-browser firefox links elinks)
        export EDITOR=$(choose gedit gvim)
    fi
    [ "$EDITOR" = "gvim" ] && export EDITOR="gvim --nofork"
else
    # text-mode
    export BROWSER=$(choose elinks links lynx)
    export EDITOR=$(choose vim vi emacs)
fi

# use lesspipe and dircolors if available
exists lesspipe && eval $(lesspipe)
exists dircolors && eval $(dircolors --bourne-shell)

# conditionally add some common paths
prepend_to_path_if_exists \
    /opt/scala/bin \
    /var/lib/gems/1.8/bin \
    $HOME/.cabal/bin \
    $HOME/bin

append_to_path_if_exists \
    /opt/android/tools \
    /opt/android/platform-tools \
    /opt/atlassian-plugin-sdk/bin

# Java likes to have a home
if [ -z "$JAVA_HOME" ]; then
    if [ -d /Library/Java/Home ]; then
        export JAVA_HOME=/Library/Java/Home
    elif [ -L /etc/alternatives/java ]; then
        # there may be a neater way to do this but i don't care atm
        export JAVA_HOME="$(dirname $(dirname $(dirname $(readlink /etc/alternatives/java))))"
    fi
    [ -n "$JAVA_HOME" -a -z "$JDK_HOME" ] && export JDK_HOME="$JAVA_HOME"
fi

if [ -z "$M2_HOME" ]; then
    if [ -d /opt/maven ]; then
        export M2_HOME=/opt/maven
        prepend_to_path_if_exists ${M2_HOME}/bin
    elif [ -d /usr/share/maven2 ]; then
        export M2_HOME=/usr/share/maven2
    elif exists mvn; then
        M2_HOME="$(mvn="$(command -v mvn)" && while [ -L "$mvn" ]; do cd $(dirname $mvn) && mvn=$(readlink $mvn || echo $mvn); done && cd .. && pwd)"
    fi
fi

# Android too
if [ -d /opt/android ];then
    export ANDROID_HOME=/opt/android
    export ANDROID_SDK_ROOT=$ANDROID_HOME
fi

# apply host-specific settings
[ -f ~/.environment.local ] && . ~/.environment.local


### Clean up
. ~/.funcs.clean
