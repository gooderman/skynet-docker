
local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local protos = {}
protos[1] = require "protos.common"
protos[10] = require "protos.heshun_dianhu"
-- protos[11] = require "protos.heshun_dianhu"

skynet.start(function()
	local common = sprotoparser.parse(protos[1])
	local dianhu = sprotoparser.parse(protos[10])
	-- local suanfen = sprotoparser.parse(protos[11])
	sprotoloader.save(common, 1)	
	sprotoloader.save(dianhu, 10)
	-- sprotoloader.save(suanfen, 11)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
