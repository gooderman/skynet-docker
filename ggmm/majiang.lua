local skynet = require "skynet"
require "manager"
local socket = require "socket"
local proxy = require "socket_proxy"


local a = os.clock()
local z1 = require "mjlib.zzz.zi_1"
local z2 = require "mjlib.zzz.zi_2"
local z3 = require "mjlib.zzz.zi_3"
local z4 = require "mjlib.zzz.zi_4"
local z5 = require "mjlib.zzz.zi_5"
local z6 = require "mjlib.zzz.zi_6"
local z7 = require "mjlib.zzz.zi_7"
local z8 = require "mjlib.zzz.zi_8"
local z9 = require "mjlib.zzz.zi_9"
local z10 = require "mjlib.zzz.zi_10"
local z11 = require "mjlib.zzz.zi_11"
local z12 = require "mjlib.zzz.zi_12"
local z13 = require "mjlib.zzz.zi_13"
local z14 = require "mjlib.zzz.zi_14"
local z15 = require "mjlib.zzz.zi_15"
local z16 = require "mjlib.zzz.zi_16"
local z17 = require "mjlib.zzz.zi_17"
local z18 = require "mjlib.zzz.zi_18"
local z19 = require "mjlib.zzz.zi_19"
local z20 = require "mjlib.zzz.zi_20"

local f1 = require "mjlib.fff.feng_1"
local f2 = require "mjlib.fff.feng_2"
local f3 = require "mjlib.fff.feng_3"
local f4 = require "mjlib.fff.feng_4"
local f5 = require "mjlib.fff.feng_5"
local f6 = require "mjlib.fff.feng_6"
local f7 = require "mjlib.fff.feng_7"
local f8 = require "mjlib.fff.feng_8"
local f9 = require "mjlib.fff.feng_9"
local f10 = require "mjlib.fff.feng_10"
local f11 = require "mjlib.fff.feng_11"
local f12 = require "mjlib.fff.feng_12"
local f13 = require "mjlib.fff.feng_13"
local f14 = require "mjlib.fff.feng_14"
local f15 = require "mjlib.fff.feng_15"
local f16 = require "mjlib.fff.feng_16"
local f17 = require "mjlib.fff.feng_17"
local f18 = require "mjlib.fff.feng_18"
local f19 = require "mjlib.fff.feng_19"
local f20 = require "mjlib.fff.feng_20"

local b = os.clock()
skynet.error("majiang load",b-a)


local zipai={
	z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16,z17,z18,z19,z20
}
local fengpai={
	f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20
}

skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd, paitp, key)
		if(cmd=='get') then
			local t
			if(paitp==1) then
				t = zipai
			else
				t = fengpai
			end
			if(type(key)=='table') then
				local rr = {}
				for i,k in ipairs(key) do
					local n = string.len(k)
					if(t[n]) then
						rr[i] = t[n][k]
					else
						rr[i] = nil
					end
				end 
				skynet.retpack(rr)
			else
				local n = string.len(key)
				local r
				if(t[n]) then
					r = t[n][key]
				end
				skynet.retpack(r)
			end
		elseif(cmd=='test') then
			skynet.error("majiang test begain")
			local ta = skynet.now()		
			for i=1,100000000 do
				local r = zipai[19]["adnkdkfka"]
			end	
			local tb = skynet.now()
			skynet.error("majiang test end",(tb-ta)*10)
		end
	end)
	skynet.register ".majiang"
end)
