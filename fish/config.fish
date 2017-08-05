for path in /opt/local/sbin /opt/local/bin /opt/bin ~/.bin
    if [ -d $path ]
        set -x PATH $path $PATH
    end
end

set -x EDITOR emacsclient

# less highlighting
set -x LESS ' -R '
if type -q src-hilite-lesspipe.sh
    set -x LESSOPEN "| src-hilite-lesspipe.sh %s"
else if [ -f /usr/share/source-highlight/src-hilite-lesspipe.sh ]
    set -x LESSOPEN "| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
end
