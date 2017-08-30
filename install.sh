####################################################
rm -rf skynet
git clone http://github.com/cloudwu/skynet
cd skynet
#cd 3rd
#git clone https://github.com/jemalloc/jemalloc
make macosx
cd ..
####################################################
cd deps
####################################################
rm -rf skynet_package
git clone http://github.com/cloudwu/skynet_package
cd skynet_package
mv Makefile Makefile_linux
cp ../skynet_package_macos.Makefile Makefile
make
cd ..
####################################################
rm -rf lua-cjson
git clone https://github.com/mpx/lua-cjson.git
cd lua-cjson
mv Makefile Makefile_orgin
cp ../lua-cjson.Makefile Makefile
make install
cd ..
####################################################
rm lsqlite3_fsl09x.zip
rm -rf lsqlite3_fsl09x
wget -O lsqlite3_fsl09x.zip http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09x.zip\?uuid\=fsl_9x
tar -xzf lsqlite3_fsl09x.zip
cd lsqlite3_fsl09x
mv Makefile Makefile_orgin
cp ../lsqlite3.Makefile Makefile
make clean
make
cd ..
####################################################
rm -rf lmu
git clone https://github.com/gooderman/lmu.git
cd lmu
mv Makefile Makefile.bak
mv Makefile.unqlite Makefile
make
cd ..
####################################################

# VER=redis-4.0.1
# rm -rf ${VER}.tar.gz
# rm -rf ${VER}
# wget http://download.redis.io/releases/${VER}.tar.gz
# tar -xf ${VER}.tar.gz
# cd ${VER}
# make
# cp -f src/redis-cli ../../
# cd ..

####################################################