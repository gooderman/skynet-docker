docker stop mymysql
docker rm mymysql
if [ -d data ];then
rm -rf data
fi
mkdir data
#first create 
docker run --name mymysql -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=123456 -v /Users/jeep/skynet/docker/mysql/data:/var/lib/mysql mysql:5.7

#second copy mysql.cnf from container
# docker stop mymysql
# docker start mymysql
docker exec mymysql /bin/bash -c "cp /etc/mysql/mysql.conf.d/mysqld.cnf /var/lib/mysql"
mv data/mysqld.cnf ./mysqld.cnf
docker stop mymysql
docker rm mymysql

if [ -d data ];then
rm -rf data
fi
mkdir data
docker run --name mymysql -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=123456 -v /Users/jeep/skynet/docker/mysql/data:/var/lib/mysql -v /Users/jeep/skynet/docker/mysql/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf mysql:5.7
# docker start mymysql
#####################################################
#cp /etc/mysql/mysql.conf.d/mysqld.cnf /var/lib/mysql
#docker run --name mymysql -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=123456 -v /Users/jeep/skynet/docker/mysql/data:/var/lib/mysql -v /Users/jeep/skynet/docker/mysql/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf mysql:5.7
