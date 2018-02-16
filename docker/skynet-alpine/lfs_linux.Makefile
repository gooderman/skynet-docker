# $Id: Makefile,v 1.36 2009/09/21 17:02:44 mascarenhas Exp $


T= lfs

CONFIG= ./config

include $(CONFIG)

HOME = /app
SKYNET_PATH = $(HOME)/skynet
TARGET = $(SKYNET_PATH)/luaclib/lfs.so

SRCS= src/$T.c
OBJS= src/$T.o

lib: src/lfs.so

src/lfs.so: $(OBJS)
	MACOSX_DEPLOYMENT_TARGET="10.3"; export MACOSX_DEPLOYMENT_TARGET; $(CC) $(LIB_OPTION) -o src/lfs.so $(OBJS)

test: lib
	LUA_CPATH=./src/?.so lua tests/test.lua

install:
	# mkdir -p $(DESTDIR)$(LUA_LIBDIR)
	cp -f src/lfs.so $(TARGET)

clean:
	rm -f src/lfs.so $(OBJS)
