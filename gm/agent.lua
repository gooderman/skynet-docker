local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local WATCHDOG

local CMD = {}
local REQUEST = {}
local client_fd

local sp
local host
local send_request

function REQUEST:heartup()
	print("heartup",self.what)
	local r = skynet.call("SIMPLEDB", "lua", "look", "A","MAIN")
	skynet.error(r)
	return { result = 99 }
end

function REQUEST:login()
	print("login")
	skynet.error("REQUEST:login")
	return { result = 200 }
end

function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function handle_package(cmd, args)
	local f = assert(REQUEST[cmd])
	local r = f(args)
	return r
end

local function send_package(data)
	local package = string.pack(">s2", data)
	socket.write(client_fd, package)
end

local function decode_package(msg,sz)
	return  host:dispatch(msg,sz)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return decode_package(msg,sz)
	end,
	dispatch = function (_, _, type,cmd, data,response,ud,...)
		print(type,cmd,ud)
		local r = handle_package(cmd,data)
		local rsp = response(r,ud)
		send_package(rsp)
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	sp = sprotoloader.load(1)
	host = sp:host('package')
	send_request = host:attach(sp)
	skynet.fork(function()
		local i=0
		while true do
			send_package(send_request('heartdown'))
			skynet.sleep(500)
			i=i+1
			-- if(i==3) then
			-- 	break
			-- end	
		end
		skynet.sleep(500)
		send_package(send_request("kickoff"))
		skynet.sleep(20)
		REQUEST:quit()
		-- skynet.sleep(10)
		-- skynet.exit()
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
