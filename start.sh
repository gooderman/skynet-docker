pkill -9 skynet
#pkill -9 redis-server
#echo "\n\n\n---------start redis---------"
#./redis-3.2.8/bin/redis-server &
#ps -ef | grep redis
#echo "-----------------------------"
#./redis-3.2.8/bin/redis-cli -h 127.0.0.1
echo "\n\n\n---------start skynet---------"
echo $1 $2 
if [ $# == 0 ]; then
./skynet/skynet ./gm/config.lua
else
./skynet/skynet ./ggmm/config
fi
echo "-----------------------------"
