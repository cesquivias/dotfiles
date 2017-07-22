for path in /opt/local/sbin /opt/local/bin /opt/bin ~/.bin
    if [ -d $path ]
        set -x PATH $path $PATH
    end
end

set -x EDITOR emacsclient
