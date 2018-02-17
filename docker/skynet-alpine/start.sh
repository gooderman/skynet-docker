#!/bin/bash
echo "---------start skynet---------"
echo $1 $2 
if [ $# == 0 ]; then
echo 'ping mysql'
ping mymysql -c 4
/app/skynet/skynet /data/GMA/config.lua
else
# /app/skynet/skynet /data/GMA/config.lua & 
# sleep 2s
echo 'ping myskynet'
ping myskynet -c 4
/app/skynet/skynet /data/GMA/config_test.lua
fi
echo "-----------------------------"
