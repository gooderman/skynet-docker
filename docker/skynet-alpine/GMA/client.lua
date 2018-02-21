if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

-- package.cpath = (os.getenv "HOME") .. "/skynet/luaclib/?.so"
package.cpath = "/Users/jeep/skynet/skynet/luaclib/?.so"
local socket = require "client.socket"
local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local last = ""

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		return v
	end
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end
local i=1
local authed =false
while true do
	-- dispatch_package()
	-- local cmd = socket.readstdin()
	-- if cmd then
	-- 	print("send_package",cmd)
	-- 	send_package(fd,cmd)
	-- else
	-- 	socket.usleep(100)
	-- end
	if(not authed) then
		local v  = dispatch_package()
		if(v) then
			print("recv_package",v)
		end
		if(v=='ping') then
			print("send_package",'pong')
			send_package(fd,'pong')
			authed = true
			send_package(fd,'pong'..'0')
		end
	else
		local v  = dispatch_package()
		if(v) then
			print("recv_package",v)
			print("send_package",'pong'..i)
			send_package(fd,'pong'..i)
			i = i+1
		end
	end
	socket.usleep(2*1000000)

end
