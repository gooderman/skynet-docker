# Use your path
HOME = /Users/jeep/skynet
SKYNET_PATH = $(HOME)/skynet
TARGET = $(SKYNET_PATH)/cservice/package.so

$(TARGET) : service_package.c
	# gcc -Wall -g --shared -fPIC -o $@ $^ -I$(SKYNET_PATH)/skynet-src
	gcc -g -O2 -Wall -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup -o $@ $^ -I$(SKYNET_PATH)/skynet-src
clean :
	rm $(TARGET)
