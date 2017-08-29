docker stop mymysql
docker rm mymysql
docker run --name mymysql -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=123456 -v /Users/jeep/skynet/docker/mysql/data:/var/lib/mysql mysql:5.7
