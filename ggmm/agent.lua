local skynet = require "skynet"
local crypt = require "skynet.crypt"
local proxy = require "socket_proxy"
local util = require "util"

local store_sqlite

local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local sp
local host
local send_request
local decode_msg

local function read(fd)
	return skynet.tostring(proxy.read(fd))
end
local function write(fd,data,len)
	return proxy.write(fd,data,len)
end

local function dump(t, prefix)
	for k,v in pairs(t) do
		print(prefix, k, v)
		if type(v) == "table" then
			dump(v, prefix .. "." .. k)
		end
	end
end
local heartupid = 1000
local addr
local fd
local ip
local roomid
local userinfo

local COMMAND = {}
local function decode_request(msg)
	local cmd,data,response,ud = decode_msg(msg)
	-- skynet.error('agent decode_msg',cmd)
	if(cmd and COMMAND[cmd] and data) then
		local rsp = COMMAND[cmd](data)
		if(response) then
			local reqdata = response(rsp,ud)
			-- skynet.error('agent response ',string.len(reqdata))
			write(fd,reqdata,string.len(reqdata))
		end
	end
end
local function loop()
	while true do
		-- skynet.error('agent loop',fd,addr,ip)
		local ok, msg = pcall(read,fd)
		if ok then
			pcall(decode_request,msg)
		else	
			COMMAND.close("agent fail read")
			return
		end
	end
end
local function test()
	while true do
		util.dump(userinfo,'userinfo')
		if(userinfo) then
			skynet.error("test 1")
			local rr = COMMAND.newroom({renshu=4,type=1})
			skynet.error("test 2")
			util.dump(rr,'newroom')
			skynet.sleep(100)
			rr = COMMAND.getroom()
			util.dump(rr,'getroom')
			skynet.sleep(100)
			rr = COMMAND.joinroom({roomid=rr.room.id})
			util.dump(rr,'joinroom')
		end
		-- skynet.sleep(100)
	end
end
function COMMAND.close(msg)
	skynet.error(msg)
	skynet.send(agentMgr,'lua','agent-closed',fd)
	proxy.close(fd)
	local rr  = COMMAND.getroom()
	if(rr.state==0) then
		local roomaddr = rr.room.addr
		skynet.call(roomaddr,'lua','quit',skynet.self(),userinfo.id)
	end
	skynet.exit()
end
function COMMAND.heartup(data)
	heartupid = heartupid + 1
	local t = {id = heartupid}
	return t
end
function COMMAND.login(data)
	util.dump(data,'cmd.login')
	local userdb = skynet.call(store_sqlite,'lua','get_user',data.player)
	if(not userdb) then
		userdb = skynet.call(store_sqlite,'lua','new_user',data.player)
	end
	if(userdb) then
		userinfo = userdb
		return {state=0,player=userdb}
	else
		skynet.fork(function()
				COMMAND.close("login fail close")
			end)
		return {state=1}
	end
end
-- function COMMAND.auth(data)
-- 	dump(data,'cmd.auth')
-- 	return {key='0'}
-- end
function COMMAND.getroom()
	if(userinfo) then
		local state,info = skynet.call('.roommgr','lua','getroom',userinfo)
		return {state = state,room = info}
	else
		return {state = -1}
	end
end

function COMMAND.newroom(data)
	local state,roomid,info = skynet.call('.roommgr','lua','newroom',userinfo,data)
	if(state==0) then
		info.id = roomid
	end
	return {state = state,room = info}
end

function COMMAND.joinroom(data)
	local st,info = skynet.call('.roommgr','lua','joinroom',userinfo,data.roomid)
	return {state = state,room = info}
end

local NTF_CMD={}
function NTF_CMD.ntf_gameready()
	local reqdata = send_request("gameready",{ready=1},1,"")
	write(fd,reqdata,string.len(reqdata))
end

skynet.start(function()

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

	store_sqlite = skynet.uniqueservice("store_sqlite")

	skynet.dispatch('lua',function(session, source, cmd,_fd,_addr,_ip)
		if(cmd=='init') then
			agentMgr = source
			fd = _fd
			addr = _addr
			ip = _ip
			print('agent init',fd,addr,ip)
			proxy.subscribe(fd)
			skynet.fork(loop)
			-- skynet.fork(test)
			-- error("fuckfuck")
			skynet.retpack({fd=fd,addr=addr,ip=ip})
		elseif(NTF_CMD[cmd]) then
			skynet.retpack(NTF_CMD[cmd]())
		end
	end)
end)
