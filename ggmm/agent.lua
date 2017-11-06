local skynet = require "skynet"
local crypt = require "skynet.crypt"
local proxy = require "socket_proxy"

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
	skynet.error('agent decode_msg',cmd)
	if(cmd and COMMAND[cmd] and data) then
		local rsp = COMMAND[cmd](data)
		if(response) then
			local reqdata = response(rsp,ud)
			skynet.error('agent response ',string.len(reqdata))
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
			skynet.error("agent fail read")
			skynet.send(agentMgr,'lua','agent-closed',fd)
			skynet.exit()
			return
		end
	end
end
function COMMAND.heartup(data)
	heartupid = heartupid + 1
	local t = {id = heartupid}
	return t
end

function COMMAND.createRoom(data)
	local r = skynet.call('roommgr','lua','newroom',userinfo.userid,data)
	return r
end

function COMMAND.joinRoom(data)
	local r = skynet.call('roommgr','lua','joinroom',userinfo.userid,data)
	return r
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

	skynet.dispatch('lua',function(session, source, cmd,_fd,_addr,_ip)
		if(cmd=='init') then
			agentMgr = source
			fd = _fd
			addr = _addr
			ip = _ip
			print('agent init',fd,addr,ip)
			proxy.subscribe(fd)
			skynet.fork(loop)
			-- error("fuckfuck")
			skynet.retpack({fd=fd,addr=addr,ip=ip})
		end
	end)
end)
