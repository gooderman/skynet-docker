# Use your path
HOME = /app
SKYNET_PATH = $(HOME)/skynet
TARGET = $(SKYNET_PATH)/luaclib/lsqlite3.so

$(TARGET) : lsqlite3.c sqlite3.c
	gcc -DLSQLITE_VERSION=\"0.9.4\" -Wall -g -O2 --shared -fPIC -o $@ $^ -I$(SKYNET_PATH)/3rd/lua
	#gcc -DLSQLITE_VERSION=\"0.9.4\" -g -O2 -Wall -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup -o $@ $^ -I$(SKYNET_PATH)/3rd/lua
clean :
	rm $(TARGET)
