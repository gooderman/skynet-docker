docker stop wpmysql
docker rm wpmysql
docker pull mysql:5.7
docker run --name wpmysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7

docker stop mywordpress
docker rm mywordpress
docker pull wordpress:latest
docker run --name mywordpress --link wpmysql:mysql -p 9000:80 -d wordpress


