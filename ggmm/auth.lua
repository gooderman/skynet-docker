local skynet = require "skynet"
local socket = require "socket"
local crypt = require "skynet.crypt"
local proxy = require "socket_proxy"

local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local sp
local host
local send_request
local decode_reponse

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

skynet.start(function()
	sp = sprotoloader.load(1)
	host = sp:host('package')
	send_request = host:attach(sp)
	decode_reponse = function(msg,sz)
		local tp,b,c,d,e = host:dispatch(msg)
		if(tp=='REQUEST')then
			-- tp,name,content,response,ud
			return b,c
		else
			-- tp,sid,content,ud
			--ud is name
			return d,c,b
		end
	end

	skynet.dispatch('lua',function(session, source, cmd, fd,ip)
		if(cmd=='auth') then
			skynet.error('auth start',fd,ip)
			local addr = proxy.subscribe(fd)
			skynet.error('auth 1',addr)
			skynet.sleep(10)
			local key = math.random(100000,999999)
			key = tostring(key)
			skynet.error('auth key',key)
			local reqdata = send_request("auth",{key=tostring(key)},1,"auth")
			skynet.error('auth send',string.len(reqdata))
			write(fd,reqdata,string.len(reqdata))

			local ok, msg,sz = pcall(read, fd)
			if not ok then
				skynet.error("auth fail read")
				skynet.send(source,'lua','auth-fail',nil,nil,ip,'read')
				return
			end
			local cmd,data = decode_reponse(msg,sz)
			skynet.error('auth rsp',cmd,data.key)
			if cmd == "auth" then
				local rspkey = crypt.base64encode(key)
				if(rspkey==data.key) then
					skynet.send(source,'lua','auth-succ',fd,addr,ip,data.key)
					return
				end
			end	
			proxy.close(fd)
			skynet.send(source,'lua','auth-fail',fd,addr,ip,key)
		end
	end)
end)
