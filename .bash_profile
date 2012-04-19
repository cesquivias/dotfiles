#!/bin/sh

export EDITOR=emacsclient
export PATH=~/.bin:/opt/bin:$PATH

# less highlighting
if [ -a /usr/share/source-highlight/src-hilite-lesspipe.sh ]
then
    export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
    export LESS=' -R '
fi

