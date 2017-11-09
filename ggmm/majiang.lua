local skynet = require "skynet"
require "manager"
local socket = require "socket"
local proxy = require "socket_proxy"
local mjlib = require "majiang_lib"
local util = require "util"
require "functions"

local a = os.clock()
local z2 = require "mjlib.zzz.zi_2"
local z3 = require "mjlib.zzz.zi_3"
local z5 = require "mjlib.zzz.zi_5"
local z6 = require "mjlib.zzz.zi_6"
local z8 = require "mjlib.zzz.zi_8"
local z9 = require "mjlib.zzz.zi_9"
local z11 = require "mjlib.zzz.zi_11"
local z12 = require "mjlib.zzz.zi_12"
local z14 = require "mjlib.zzz.zi_14"
-- local z15 = require "mjlib.zzz.zi_15"
-- local z17 = require "mjlib.zzz.zi_17"
-- local z18 = require "mjlib.zzz.zi_18"
-- local z20 = require "mjlib.zzz.zi_20"

local f2 = require "mjlib.fff.feng_2"
local f3 = require "mjlib.fff.feng_3"
local f5 = require "mjlib.fff.feng_5"
local f6 = require "mjlib.fff.feng_6"
local f8 = require "mjlib.fff.feng_8"
local f9 = require "mjlib.fff.feng_9"
local f11 = require "mjlib.fff.feng_11"
local f12 = require "mjlib.fff.feng_12"
local f14 = require "mjlib.fff.feng_14"
-- local f15 = require "mjlib.fff.feng_15"
-- local f17 = require "mjlib.fff.feng_17"
-- local f18 = require "mjlib.fff.feng_18"
-- local f20 = require "mjlib.fff.feng_20"

local b = os.clock()
skynet.error("majiang load",b-a)


local zipai={
	{},z2,z3,{},z5,z6,{},z8,z9,{},z11,z12,{},z14
}
local fengpai={
	{},f2,f3,{},f5,f6,{},f8,f9,{},f11,f12,{},f14
}


-- local builder = require "skynet.datasheet.builder"
-- local datasheet = require "skynet.datasheet"
local CMD={}

function CMD.test()
	skynet.error("majiang test begain")
	local ta = skynet.now()		
	for i=1,10000000 do
		local r = zipai[14]["adnkdkfka"]
	end	
	local tb = skynet.now()
	skynet.error("majiang test end",(tb-ta)*10)
end

function CMD.get(paitp,key)
	local t
	if(paitp>=1 and paitp<=3) then
		t = zipai
	else
		t = fengpai
	end
	if(type(key)=='table') then
		local rr = {}
		for i,k in ipairs(key) do
			local n = string.len(k)
			if(t[n]) then
				rr[i] = t[n][k] or false
			else
				rr[i] = false
			end
		end 
		return rr
	else
		local n = string.len(key)
		local r
		if(t[n]) then
			r = t[n][key]
		end
		return r
	end
end
local function copytb(tp,t)
	local r = {}
	for _,v in ipairs(t) do
		table.insert(r,mjlib.combine(tp,v))
	end
	return r
end
function CMD.ting(pai)
	local cc={0,1,1,0,1,1,0,1,1,0,1,1,0,1, 1,0,1,1,0,1}
	cc[0] = 1
	cc[-1] = 0

	local t,tc = mjlib.tongji(pai)
	-- util.dump(t,'CMD.ting.tj')
	-- util.dump(tc,'CMD.ting.tj2')
	--三个无效数量必定无效
	local n = 0
	for i=1,4 do
		local ct = tc[i]
		if cc[ct] == 0 then
			n = n+1
			if(n>2) then
				return false
			end
		end
	end
	-- skynet.error('CMD.ting.look')
	--数量-1, +1 是否有效
	--确定是否需要迭代
	local ot = {} --{0,1}
	for i=1,4 do
		ot[i] = {}
		local ct = tc[i]
		if cc[ct-1] == 0 then
			ot[i][1]=0
		else	
			ot[i][1]=1
		end
		if cc[ct+1] == 0 then
			ot[i][2]=0
		else	
			ot[i][2]=1
		end
	end
	-- util.dump(ot,'CMD.ting.op')
	local rr = {}
	local p_out = 0
	local p_in = 0
	--迭代自己+-
	for i=1,4 do
		if(tc[i]>0) then
			local cktb = clone(pai)
			for m=1,9 do
				local cktb2 = clone(cktb)
				if mjlib.sub(cktb2,i,m) then
					p_out = mjlib.combine(i,m)
					local cktb3 = clone(cktb2)
					for n=1,9 do
						local cktb4 = clone(cktb3)
						mjlib.add(cktb4,i,n)
						p_in = mjlib.combine(i,n)
						if(CMD.hu(cktb4)) then
							table.insert(rr,p_out.."--"..p_in)
						end
					end
				end
			end
		end
	end
if(true) then
	--迭代自己-其他+
	for i=1,4 do
		local tbsub = t[i]
		--可减
		if(ot[i][1]>0 and tc[i]>0) then
			local ss = mjlib.tb2str(t[i])
			--逐个sub
			for m=1,tc[i] do
				local s = ss
				p_out = mjlib.combine(i,tbsub[m])
				s = string.sub(s,1,m-1)..string.sub(s,m+1)
				-- skynet.error('CMD.s[m]',i,s)
				--检测有效
				if CMD.get(i,s) then
					local cktb = clone(pai)
					mjlib.sub(cktb,i,tbsub[m])
					--逐一尝试
					for j=1,4 do
						local cktb2 = clone(cktb)
						--可加
						if (ot[j][2]>0 and tc[j]>0) then
							--逐个add
							local cktb3 = clone(cktb2)
							for k=1,9 do
								p_in = mjlib.combine(j,k)
								local cktb4 = clone(cktb3)
								mjlib.add(cktb4,j,k)
								if(CMD.hu(cktb4)) then
									table.insert(rr,p_out.."--"..p_in)
								end
							end
						end
					end
				else
						
				end
			end
		end	
	end
end	
	if(#rr>0) then
		return rr
	end
end

function CMD.hu(pai)
	local t,tc = mjlib.tongji(pai)
	local ts={}
	local flag = true
	local jc = 0
	for i=1,4 do
		if tc[i]>0 then
			local key = mjlib.tb2str(t[i])
			local r  = CMD.get(i,key)
			if(not r) then
				flag = false
				break
			else
				jc = jc + r
			end
		end
	end
	return flag and jc==1
end
local function test()
	local ttt ={
		1,2,3, 3,4,5, 31,31,31, 11,12,13, 20,20
	}
	local ta = skynet.now()
	local r = CMD.hu(ttt)
	local tb = skynet.now()
	skynet.error("call CMD.hu = ",r , " tm =",(tb-ta)*10)

	local ta = skynet.now()
	local r
	for i=1,1000 do
		r = CMD.ting(ttt)
	end
	local tb = skynet.now()

	skynet.error("call CMD.ting tm =",(tb-ta)*10)

	util.dump(r,'CMD.ting')

end
skynet.start(function()

	-- local ta = skynet.now()		
	-- builder.new("majiang", {zipai = zipai, fengpai = fengpai})
	-- local tb = skynet.now()
	-- skynet.error("majiang builder end",(tb-ta)*10)
	-- zipai = nil
	-- fengpai = nil
	skynet.fork(test)
	skynet.dispatch('lua',function(session, source, cmd, ...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(ff) then
				return skynet.retpack(ff(...))
			end
		end
	end)
	skynet.register ".majiang"
end)
