local skynet = require "skynet"

skynet.start(function()
	skynet.newservice("debug_console",8001)
	skynet.uniqueservice("protoloader")
	skynet.newservice('robot',0,4)
end)
