#!/bin/bash
docker network create -d bridge skynet-net
cd docker/mysql
docker stop mymysql
docker rm mymysql
docker run -d --name mymysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -v ${PWD}/data:/var/lib/mysql --network skynet-net mysql:5.7
cd ../../
cd docker/redis
docker stop myredis
docker rm myredis
docker run -d --name myredis -p 6379:6379 -v ${PWD}/data:/data -v ${PWD}/conf:/conf --network skynet-net redis:alpine /conf/redis.conf
cd ../../
cd docker/openresty
docker stop myresty
docker rm myresty
docker run -d --name myresty -p 80:80 -v ${PWD}/script:/script -v ${PWD}/data:/data -v ${PWD}/html:/usr/local/openresty/nginx/html -v ${PWD}/config/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro -v ${PWD}/logs:/usr/local/openresty/nginx/logs --network skynet-net openresty/openresty:alpine
echo 'wait 2s for mysql startup'
sleep 2s
cd ../..
cd docker/skynet-alpine
docker stop myskynet
docker rm myskynet
docker run --rm --name myskynet -v ${PWD}:/data -p 8000:8000 -p 8080:8080 -p 8888:8888 --network skynet-net whatoon/skynet-alpine
echo 'wait 2s for myskynet startup'
sleep 2s
docker stop myskynet_test
docker rm myskynet_test
docker run -it --rm --name myskynet_test -v ${PWD}:/data  --network skynet-net whatoon/skynet-alpine '1'
cd ../..