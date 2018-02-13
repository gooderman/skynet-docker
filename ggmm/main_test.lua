local skynet = require "skynet"

local function good()
	local uid = 10000
	for i=1,20 do
		local roomid = 0
		local renshu = math.random(3,4)
		local jushu = math.random(2,4)
		for i=1,renshu do
			local owner = skynet.newservice('robot',uid,roomid,renshu,jushu)
			if(roomid==0) then
				skynet.error('new robot roomid 1== 0')
				roomid = skynet.call(owner, 'lua', 'getroomid')
				skynet.error('new robot roomid 2==',roomid)
			end
			uid = uid+1
		end
		skynet.sleep(2)
	end	
end	
skynet.start(function()
	skynet.newservice("debug_console",8001)
	skynet.uniqueservice("protoloader")
	skynet.fork(good)
end)
