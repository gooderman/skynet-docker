cd deps
VER=redis-4.0.1
rm -rf ${VER}.tar.gz
rm -rf ${VER}
wget http://download.redis.io/releases/${VER}.tar.gz
tar -xf ${VER}.tar.gz
cd ${VER}
make
cp -f src/redis-cli ../../

