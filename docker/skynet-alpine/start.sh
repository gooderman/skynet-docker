#!/bin/bash
echo "---------start skynet---------"
echo $1 $2 
echo 'ping mysql'
ping mymysql -c 4
if [ $# == 0 ]; then
/app/skynet/skynet /data/GMA/config.lua
else
/app/skynet/skynet /data/GMA/config.lua & 
sleep 2s
/app/skynet/skynet /data/GMA/config_test.lua
fi
echo "-----------------------------"
