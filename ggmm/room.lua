local skynet = require "skynet"
local util = require 'util'

local majiang
local function loop()
	local ttt ={
		"1",
		--2
		"11",
		"23",
		--3
		"123",
		--4
		"1122",
		"1234",
		--5
		"11234",
		"23456",
		--6
		"123456",
		--7
		"1234567",
		"1122345",
		"1357988"
		--8
	}
	while true do
		-- local ta = skynet.now()
		-- local r = skynet.call(majiang,'lua','get',1,ttt)
		-- local tb = skynet.now()
		-- skynet.error("call majiang tm =",(tb-ta)*10)
		-- util.dump(r)
		-- skynet.sleep(500)
		skynet.send(majiang,'lua','test')
		skynet.sleep(100)
	end
end

skynet.start(function()
	
	majiang = skynet.queryservice('majiang')
	
	skynet.fork(loop)

	skynet.dispatch('lua',function(session, source, cmd)
	end)
end)
