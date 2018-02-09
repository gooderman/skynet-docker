local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local util = require "util"

local roomid,renshu = ...
local rsp_get_roomid

local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local sp
local host
local send_request
local decode_msg

local fd = nil

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
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
	local r = socket.read(fd)
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

local CMD = {}
CMD.auth = function(data)
	local pack = send_request("auth",{key=crypt.base64encode(data.key)},1,'auth')
	send_package(fd,pack)
end
CMD.heartbeat = function()
	local pack = send_request("heartbeat",{},1,"heartbeat")
	send_package(fd,pack)
end

local function loop_heartbeat()
	while(true) do
		CMD.heartbeat()
		skynet.sleep(800)
	end
end

local function loop()
	fd = socket.open('127.0.0.1', skynet.getenv('GAME_LISTEN_PORT'))
	skynet.error('socket open ',fd)
	if(not fd) then
		return
	end
	-- socket.start(fd)
	while(true) do
		local p = dispatch_package()
		if p then
			local cmd , data = decode_msg(p,string.len(p))
			if(cmd~='heartbeat') then
				util.dump(data,'dispatch_package '..cmd)
				if(CMD[cmd]) then
					CMD[cmd](data)
				end
			end
			if(cmd=='auth') then
				skynet.fork(loop_heartbeat)
			end
		end
		skynet.sleep(10)
	end
end

skynet.start(function(v)
	skynet.error('robot====',roomid,renshu)

	sp = sprotoloader.load(1)
	host = sp:host('package')
	send_request = host:attach(sp)
	decode_msg = function(msg,sz)
		local tp,b,c,d,e = host:dispatch(msg)
		if(tp=='REQUEST')then
			-- tp,name,content,response,ud
			return b,c,d,e
		else
			-- tp,sid,content,ud
			--ud is name
			return d,c
		end
	end

	skynet.dispatch('lua', function(session, source, cmd,...)
		if(cmd=='getroomid') then
			if(roomid==0) then
				rsp_get_roomid = skynet.response(function(id)
					skynet.retpack(id)
				end)
			else
				skynet.retpack(roomid)
			end
		end
	end)
	skynet.fork(loop)
end)
