#!/usr/bin/env fish

if test -d /opt
   set -x PATH /opt/local/libexec/gnubin /opt/bin /opt/local/bin /opt/local/sbin $PATH
end
set -x PATH ~/.bin $PATH

set local_config
if test -e $local_config
   source $local_config
end
