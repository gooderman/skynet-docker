local skynet = require "skynet"
local crypt = require "skynet.crypt"
local proxy = require "socket_proxy"
local util = require "util"

local store_sqlite
local store_mysql

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
local ___agentmgr
local __heartupid = 1000
local __addr
local __fd
local __ip
local __roomid
local __roomaddr 
local __userinfo
local __selfaddr
local __testco
---------------------------------------------------------------
local COMMAND = {}
local __closing
local __closwill
function COMMAND.closed(msg)
	if(__closing) then
		return
	end
	__closing = true
	skynet.error(msg)
	skynet.send(___agentmgr,'lua','agent-closed',__fd)
	proxy.close(__fd)
	if(__roomaddr and __roomaddr>0) then
		skynet.send(__roomaddr,'lua','agent_closed',skynet.self(),__userinfo.id)
	end
	skynet.exit()
end

function COMMAND.close(msg)
	skynet.error('COMMAND.close by reason',msg)
	COMMAND.closed(msg)
end
--reg to agentmgr: one uid multidevice login will be replaceed
function COMMAND.reg(uid)
	local r = skynet.call(___agentmgr,'lua','reg',__fd,uid)
	if(r) then
		util.dump(r,'COMMAND.reg')
	end
end
--抢登陆
function COMMAND.replaced(uid)
	__closwill = true
	local reqdata = send_request("replaced",{},1,"")
	write(__fd,reqdata,string.len(reqdata))
	COMMAND.close('agent be replaced',uid)
end

function COMMAND.heartbeat(data)
	__heartupid = __heartupid + 1
	local t = {id = __heartupid}
	return t
end
function COMMAND.login(data)
	local userdb = skynet.call(store_sqlite,'lua','get_user',data.user)
	if(not userdb) then
		userdb = skynet.call(store_sqlite,'lua','new_user',data.user)
	end
	-- util.dump(data,'cmd.login')
	if(userdb) then
		if(__userinfo and __userinfo.id~=userdb.id) then
			skynet.fork(function()
				COMMAND.close("another user login")
			end)
			return {state=2}
		else
			__userinfo = userdb
			COMMAND.reg(__userinfo.id)
			return {state=0,user=userdb}
		end
	else
		skynet.fork(function()
				COMMAND.close("login fail close")
			end)
		return {state=1}
	end
end
function COMMAND.quit(data)
	COMMAND.close('user quit')
end
-- function COMMAND.auth(data)
-- 	dump(data,'cmd.auth')
-- 	return {key='0'}
-- end
function COMMAND.getroom()
	if(__userinfo) then
		local state,info,addr = skynet.call('.roommgr','lua','getroom',__userinfo)
		return {state = state,room = info}
	else
		return {state = -1}
	end
end

function COMMAND.newroom(data)
	local state,info,addr = skynet.call('.roommgr','lua','newroom',__userinfo,data)
	if(state==0) then
	end
	return {state = state,room = info}
end

function COMMAND.joinroom(data)
	local state,info,addr = skynet.call('.roommgr','lua','joinroom',__userinfo,data.roomid)
	if(state==0) then
		__roomaddr = addr
	end
	return {state = state,room = info}
end

function COMMAND.dataup(data)
	if(__roomaddr) then
		local tp,cmd,rdata = skynet.call(__roomaddr,'lua','gcmd','dataup',data)
		if(tp and cmd and rdata) then
			return {type=tp,cmd=cmd,data=rdata}
		end
	end
end

---------------------------------------------------------------
function COMMAND.datadn(type,cmd,data)
	local reqdata = send_request("datadn",{type=type,cmd=cmd,data=data},1,"")
	write(__fd,reqdata,string.len(reqdata))
end
---------------------------------------------------------------
---------------------------------------------------------------
local NTF_CMD={}
function NTF_CMD.data_ntf(type,cmd,data)
	return COMMAND.datadn(type,cmd,data)
end
function NTF_CMD.quit_ntf()
	__roomid = 0
	__roomaddr = 0
end
function NTF_CMD.dismiss_ntf()
	__roomid = 0
	__roomaddr = 0
end
---------------------------------------------------------------
---------------------------------------------------------------
local function decode_request(msg)
	local cmd,data,response,ud = decode_msg(msg)
	-- skynet.error('agent decode_msg',cmd)
	if(cmd and data) then
		if(COMMAND[cmd]) then
			local rsp = COMMAND[cmd](data)
			if(rsp and response) then
				local reqdata = response(rsp,ud)
				-- skynet.error('agent response ',string.len(reqdata))
				write(__fd,reqdata,string.len(reqdata))
			end
		end
	end
end

local function loop()
	while true do
		-- skynet.error('agent loop',__fd,__addr,__ip)
		local ok, msg = pcall(read,__fd)
		-- local ok, msg = true,read(__fd)
		if(__testco) then
			skynet.wakeup(__testco)
		end
		if ok then
			pcall(decode_request,msg)
		else	
			COMMAND.closed("agent fail read")
			return
		end
		if(__closwill or __closing) then
			break
		end
	end
end

local function test()
	while true do
		util.dump(__userinfo,'userinfo')
		if(__userinfo) then
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

skynet.start(function()

	__selfaddr = skynet.self()

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

	-- __testco = skynet.fork(function(v1,v2)
	-- 	skynet.error("agent testco start",v1,v2)
	-- 	local idx = 1
	-- 	while(true) do
	-- 		skynet.error("agent testco idx",idx)
	-- 		skynet.wait()
	-- 		idx = idx + 1
	-- 	end
	-- 	skynet.error("agent testco end")
	-- end,100,200)

	
	store_sqlite = skynet.uniqueservice("store_sqlite")
	store_mysql = skynet.uniqueservice("store_mysql")

	skynet.dispatch('lua',function(session, source, cmd,...)
		if(cmd=='init') then
			___agentmgr = source
			__fd,__addr,__ip = ...
			print('agent init',__fd,__addr,__ip)
			proxy.subscribe(__fd)
			skynet.fork(loop)
			-- skynet.fork(test)
			-- error("fuckfuck")
			skynet.retpack({fd=__fd,addr=__addr,ip=__ip})
		elseif(cmd=='replaced') then
			COMMAND.replaced(uid)
		elseif(NTF_CMD[cmd]) then
			skynet.retpack(NTF_CMD[cmd](...))
		end
	end)
end)

