local skynet = require "skynet"
local builder = require "skynet.datasheet.builder"
local datasheet = require "skynet.datasheet"

local function dump(t, prefix)
	for k,v in pairs(t) do
		print(prefix, k, v)
		if type(v) == "table" then
			dump(v, prefix .. "." .. k)
		end
	end
end

skynet.start(function()
	-- builder.new("foobar", {a = 1, b = 2 , c = {3} ,d={{'d'}}})
	-- local t = datasheet.query "foobar"
	-- dump(t, "[0]")
	-- local c = t.c
	-- dump(t, "[1]")
	-- builder.update("foobar", { b = 4, c = { 5 } })
	-- print("sleep")
	-- skynet.sleep(100)
	-- dump(t, "[2]")
	-- dump(c, "[2.c]")
	-- builder.update("foobar", { a = 6, c = 7, d = 8 })
	-- print("sleep")
	-- skynet.sleep(100)
	-- dump(t, "[3]")
	local ta = skynet.now()		
	local t = datasheet.query "majiang"
	local zp = t.zipai
	local n = math.random(1,20)
	local tt = zp[n]
	local tb = skynet.now()
	-- local rr = tt["123456789"]
	skynet.error("sheet test end",(tb-ta)*10,rr)
end)
