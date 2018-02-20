#!/bin/bash
docker network create -d host --ipv6 skynet-net
cd docker/mysql
docker stop mymysql
docker rm mymysql
docker run --rm -d --name mymysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -v `pwd`/data:/var/lib/mysql  --network skynet-net mysql:5.7
cd ../../
cd docker/openresty
docker stop myresty
docker rm myresty
docker run --rm -d --name myresty -p 80:80 -v `pwd`:/usr/local/openresty/nginx/html openresty/openresty:alpine
echo 'wait 2s for mysql startup'
sleep 2s
cd ../..
cd docker/skynet-alpine
docker stop myskynet
docker rm myskynet
docker run -d --rm --name myskynet -v `pwd`:/data -p 8000:8000 -p 8080:8080 -p 8888:8888 --network skynet-net whatoon/skynet-alpine
echo 'wait 2s for myskynet startup'
sleep 2s
docker stop myskynet_test
docker rm myskynet_test
docker run -it --rm --name myskynet_test -v `pwd`:/data  --network skynet-net whatoon/skynet-alpine '1'
cd ../..