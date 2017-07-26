#!/usr/bin/env fish

for path in /opt/local/sbin /opt/local/bin /opt/bin /opt/local/libexec/gnubin ~/.bin
    if [ -d $path ]
        set -x PATH $path $PATH
    end
end

set -x EDITOR emacsclient

set local_config ~/.config/fish/config.fish.local
if [ -e $local_config ]
   source $local_config
end
