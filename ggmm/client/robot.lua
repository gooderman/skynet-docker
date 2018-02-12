local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local util = require "util"
local cjson = require "cjson"

local roomtype = 10
local uid,roomid,renshu = ...
uid = tostring(uid)
roomid = tonumber(roomid)
renshu = tonumber(renshu)
local rsp_get_roomid

local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local sp
local host
local send_request
local decode_msg

local fd = nil
local sid = 1

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
	sid = sid+1
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
local RMD = {}
local GCMD = {}
--接收
RMD.auth = function(data)
	local pack = send_request("auth",{key=crypt.base64encode(data.key)},sid,'auth')
	send_package(fd,pack)
	CMD.login()
end
RMD.login = function(data)
	-- util.dump(data,'RMD.login')
	if(data.state==0) then
		if(roomid==0) then
			CMD.newroom()
		else
			CMD.joinroom()
			GCMD.ready()
		end
	end
end
RMD.newroom = function(data)
	-- util.dump(data,'RMD.login')
	if(data.state==0) then
		roomid = data.room.id
		if(rsp_get_roomid) then
			rsp_get_roomid(true,roomid)
		end
		CMD.joinroom()
		GCMD.ready()
	end
end
RMD.datadn = function(data)
	local t = data.type
	local cmd = data.cmd
	local data = sp:decode(cmd,data.data)
	util.dump(data,'cmd-'..cmd)
end
---发送
CMD.heartbeat = function()
	local pack = send_request("heartbeat",{},sid,"heartbeat")
	send_package(fd,pack)
end

CMD.login = function()
	local req = {
		user ={
			openid = uid,
			name = "user"..uid,
			gender = math.random(1,2),
			headimg  = "http://user_head.jpg",
			platform  = "ios",
			os  = 'ios11.0',
			device = 'iphone-x',
			uuid ='',
		}
	}
	local pack = send_request("login",req,sid,"login")
	send_package(fd,pack)
end

CMD.newroom = function()
	local req = {
		type = roomtype,
		args = cjson.encode({
			renshu = renshu,
			jushu = 4,
			wanfa = 1,
			ting = true,
			bao = true,
			gangf = true,
		})
	}
	local pack = send_request("newroom",req,sid,"newroom")
	send_package(fd,pack)
end
CMD.joinroom = function()
	local req = {
		roomid = roomid
	}
	local pack = send_request("joinroom",req,sid,"joinroom")
	send_package(fd,pack)
end
CMD.joinroom = function()
	local req = {
		roomid = roomid
	}
	local pack = send_request("joinroom",req,sid,"joinroom")
	send_package(fd,pack)
end
CMD.dataup = function(cmd,data)
	local req = {
		type = roomtype,
		cmd = cmd
	}
	req.data = sp:encode(cmd,data)
	local pack = send_request("dataup",req,sid,"dataup")
	send_package(fd,pack)
end
--------------------------
GCMD.ready = function()
	CMD.dataup('ready_req',{ready=1})
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
				if(RMD[cmd]) then
					RMD[cmd](data)
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
	skynet.error('robot start ====',uid,roomid,renshu)

	sp = sprotoloader.load(roomtype)
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
				rsp_get_roomid = skynet.response()
			else
				skynet.retpack(roomid)
			end
		end
	end)
	skynet.fork(loop)
end)
