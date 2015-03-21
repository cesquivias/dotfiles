#!/bin/sh

# Command to go up N number of directories
function upd() {
    if [ $1 -gt 0 ]; then
        n=$1
        while [ $n -gt 0 ]
        do
            cd ..
            n=$(($n - 1))
        done
    fi
}

function make_basrclocal() {
    if [ -e ~/.bashrc.local ]; then
        return;
    fi

    echo "# -*- mode: shell-script;-*-" > ~/.bashrc.local
}
