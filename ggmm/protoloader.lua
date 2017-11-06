
local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto = require "protodata"

skynet.start(function()
	local c2s = sprotoparser.parse(proto)
	local s2c = sprotoparser.parse(proto)
	sprotoloader.save(c2s, 1)
	sprotoloader.save(s2c, 2)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
