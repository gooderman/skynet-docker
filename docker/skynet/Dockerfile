FROM ubuntu:16.04
WORKDIR /app
VOLUME /data
ENV SKYNET_DEPS \
    bash \
    ca-certificates \
    autoconf \
    wget \
    git \
    make \
    g++ \
    libreadline-dev \
    unzip

ENV REMOVE_DEPS \  
	ca-certificates \
    autoconf \
    wget \
    git \
    make \
    g++ \
    libreadline-dev \
    unzip

COPY ./skynet_package_linux.Makefile ./skynet_package_linux.Makefile
COPY ./lfs_linux.Makefile ./lfs_linux.Makefile 
COPY ./lfs_linux_config ./lfs_linux_config 
COPY ./lua-cjson_linux.Makefile ./lua-cjson_linux.Makefile 
COPY ./lsqlite3_linux.Makefile ./lsqlite3_linux.Makefile     
COPY ./skynet_package_diff ./skynet_package_diff
    
RUN  \
	apt update && yes | apt install --no-install-recommends ${SKYNET_DEPS} \
	&& git clone https://github.com/cloudwu/skynet \
	&& cd skynet \
	&& make linux \
	&& rm -rf .git \	
	&& cd .. \
	&& git clone https://github.com/cloudwu/skynet_package \
	&& cd skynet_package \	
	&& mv Makefile Makefile_origin \
	&& cp ../skynet_package_linux.Makefile Makefile \
	&& make \
	&& rm -rf .git \	
	&& cd .. \
	&& git clone https://github.com/keplerproject/luafilesystem.git \
	&& cd luafilesystem \
	&& mv Makefile Makefile_origin \
	&& cp ../lfs_linux.Makefile Makefile \
	&& mv config config_origin \
	&& cp ../lfs_linux_config config \
	&& make \
	&& make install \
	&& cd .. \
	&& git clone https://github.com/cloudwu/lua-cjson.git \
	&& cd lua-cjson \
	&& mv Makefile Makefile_origin \
	&& cp ../lua-cjson_linux.Makefile Makefile \
	&& make install \
	&& cd .. \
	&& wget -O lsqlite3_fsl09x.zip http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09x.zip \
	# && tar -xzf lsqlite3_fsl09x.zip \
	&& unzip lsqlite3_fsl09x.zip \
	&& cd lsqlite3_fsl09x \
	&& mv Makefile Makefile_origin \
	&& cp ../lsqlite3_linux.Makefile Makefile \
	&& make \
	&& cd .. \
	&& rm -rf skynet/3rd \
	&& rm -rf luafilesystem \
	&& rm -rf lua-cjson \
	&& rm -rf lsqlite3_fsl09x \
	&& rm -f lsqlite3_fsl09x.zip \
	&& apt remove -y ${REMOVE_DEPS} \
	&& rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/data/start.sh"]	



