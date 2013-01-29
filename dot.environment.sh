## -*- sh -*-

### Load helper functions
. ~/.funcs.decl


[ "${PATH#/usr/local/bin}" = "$PATH" ] && PATH="/usr/local/bin:$(echo "$PATH" | sed 's#/usr/local/bin##;s/:://')"

# conditionally add some common paths
prepend_to_path_if_exists \
    /opt/scala/bin \
    $HOME/.cabal/bin \
    $HOME/bin

append_to_path_if_exists \
    /opt/st2

exists rbenv && eval "$(rbenv init -)"

# don't put duplicate or same successive entries in the history
export HISTCONTROL=ignoredups:ignoreboth

export VIEW=$(choose view less most more pg)
export PAGER=$(choose less most more pg)
# - allow less to display ANSI colors
# - ignore case in searches
# - use 1MB buffer size (memory is sooo cheap :)
export LESS="-Ri -b1024 -X"

# choose a preferred browser and editor
if [ ! -z "$DISPLAY" ]; then
    # graphical
    if [ "$(uname)" = "Darwin" ]; then
        export BROWSER=open
        export EDITOR=$(choose vim vi)
    else
        export BROWSER=$(choose xdg-open gnome-open google-chrome chromium-browser firefox links elinks)
        export EDITOR=$(choose vim vi)
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

# Java likes to have a home
if [ -z "$JAVA_HOME" ]; then
    if [ -d /Library/Java/Home ]; then
        export JAVA_HOME=/Library/Java/Home
    elif [ -d /opt/java ]; then
        export JAVA_HOME=/opt/java
    elif [ -L /etc/alternatives/java ]; then
        # there may be a neater way to do this but i don't care atm
        export JAVA_HOME="$(dirname $(dirname $(dirname $(readlink /etc/alternatives/java))))"
    fi
    [ -n "$JAVA_HOME" -a -z "$JDK_HOME" ] && export JDK_HOME="$JAVA_HOME"
fi

if [ -z "$M2_HOME" ]; then
    if [ -d /opt/maven ]; then
        export M2_HOME=/opt/maven
        prepend_to_path_if_exists "${M2_HOME}/bin"
    elif [ -d /usr/share/maven2 ]; then
        export M2_HOME=/usr/share/maven2
    elif exists mvn; then
        export M2_HOME="$(find_home mvn)"
    fi
fi

# Android too
if [ -z "$ANDROID_HOME" ]; then
    if [ -d /opt/android ];then
        export ANDROID_HOME=/opt/android
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
        append_to_path_if_exists \
            "${ANDROID_HOME}/tools" \
            "${ANDROID_HOME}/platform-tools"
    elif exists android; then
        export ANDROID_HOME="$(find_home android)"
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
    fi
fi

# Store Rubinius cache files in /tmp and default to 1.9 mode
export RBXOPT="-X19 -Xrbc.db=/tmp/rbx-`whoami` $RBXOPT"

if [ -d "$HOME/.ec2" ]; then
    export EC2_PRIVATE_KEY=$HOME/.ec2/private_key.pem
    export EC2_CERT=$HOME/.ec2/certificate.pem
    export EC2_URL=https://eu-west-1.ec2.amazonaws.com
fi

# Configure Git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes

# apply host-specific settings
[ -f ~/.environment.local ] && . ~/.environment.local


### Clean up
. ~/.funcs.clean
