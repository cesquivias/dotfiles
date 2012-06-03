#!/bin/sh

if [ -f ~/.bashrc ]
then
    source ~/.bashrc
fi

if [ -f ~/.bashrc.local ]
then
    source ~/.bashrc.local
fi
