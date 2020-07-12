#!/usr/bin/env bash
# http proxy manager
#   proxy.sh
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

confFile="$ETROBO_ROOT/proxy.conf"
if [ -f "$confFile" ]; then
    proxyHost=`cat "$confFile" | grep ^host | awk '{print $2}'`
    proxyUser=`cat "$confFile" | grep ^user | awk '{print $2}'`
    proxyPass=`cat "$confFile" | grep ^pass | awk '{print $2}'`
fi

if [ -z "$http_proxy" ]; then
    if [ -n "$proxyHost" ]; then
        http_proxy="http://"
        if [ -n "$proxyUser" ]; then
            if [ -z "$proxyPass" ]; then
                read -sp "Enter your password for HTTP PROXY : " proxyPass
                echo
            fi
            http_proxy="${http_proxy}${proxyUser}:${proxyPass}@"
        fi
        export http_proxy="${http_proxy}${proxyHost}"
        export https_proxy="${http_proxy}"
    fi
else
    if [ -z "proxyHost" ] || [ "$1" = "update" ]; then
        if [ -n "`echo $http_proxy | grep @`" ]; then
            echo $http_proxy | sed -E "s/^http:\/\/(.*):(.*)\@(.*:.*)$/host \3\\nuser \1/" > $confFile
        else
            echo $http_proxy | sed -E "s/^http:\/\/(.*:.*)$/host \1/" > $confFile
        fi
    fi

    if [ -z "$https_proxy" ]; then
        export https_proxy="${http_proxy}"
    fi
fi

echo $http_proxy
cat $ETROBO_ROOT/proxy.conf
