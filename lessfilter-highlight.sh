#!/bin/sh

if type lesspipe.sh &>/dev/null; then
    LESSPIPE=lesspipe.sh
else
    LESSPIPE=lesspipe
fi

case "$1" in
    Makefile|*.mk|*.sh|*.c|*.cpp|*.cc|*.m|*.rb|*.py|*.rb|*.hs|*.lhs|*.java|*.scala|*.R|*.rs|*.sql|*.html|*.xml|*.xsd|*.js|*.coffee|*.css|*.scss|*.sass|*.haml|*.md|*.rst|*.php|*.php3|*.pl|*.conf|*.ini|*.conf|*.go|*.diff|*.patch|*.pp)
        command="highlight --quiet --out-format=xterm256 --line-numbers --style=solarized-light" ;;

    *.sbt)
        command="highlight --quiet --out-format=xterm256 --line-numbers --syntax=scala --style=solarized-light" ;;

    *.iml)
        command="highlight --quiet --out-format=xterm256 --line-numbers --syntax=xml --style=solarized-light" ;;

    *)
        command="$LESSPIPE" ;;
esac

exec $command "$@"
