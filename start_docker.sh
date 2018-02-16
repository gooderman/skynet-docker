#!/bin/bash
docker network create -d bridge skynet-net
cd docker/mysql
docker stop mymysql
docker rm mymysql
docker run --rm -d --name mymysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -v `pwd`/data:/var/lib/mysql  --network skynet-net mysql:5.7
echo 'wait 2s for mysql startup'
sleep 2s
cd ../..
cd docker/skynet-alpine
docker run -it --rm -v `pwd`:/data -p 8000:8000 -p 8080:8080 -p 8888:8888 --network skynet-net skynet_alpine:v1 '1'
cd ../..