local skynet = require "skynet"
require "manager"
local socket = require "socket"
local proxy = require "socket_proxy"
local util = require "util"
require "functions"
local mjlib = import(".base",...) 


local a = os.clock()
local zall = require "mjlib.gen.A_wtt"
local fall = require "mjlib.gen.A_zi"

local b = os.clock()
skynet.error("mj_heshun_dianhu load",b-a)


-- local zipai={
-- 	{},z2,z3,{},z5,z6,{},z8,z9,{},z11,z12,{},z14
-- }
-- local fengpai={
-- 	{},f2,f3,{},f5,f6,{},f8,f9,{},f11,f12,{},f14
-- }


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
	if(paitp==4) then
		t = fall
	else
		t = zall
	end
	-- if(type(key)=='table') then
	-- 	local rr = {}
	-- 	for i,k in ipairs(key) do
	-- 		rr[i] = t[k] or false
	-- 	end 
	-- 	return rr
	-- else
		r = t[key]  or false
		return r
	-- end
end
function CMD.gett(paitp,key)
	local t
	if(paitp>=1 and paitp<=3) then
		t = zall
	else
		t = fall
	end
	if(type(key)=='table') then
		local rr = {}
		for i,k in ipairs(key) do
			rr[i] = t[k] or false
		end 
		return rr
	else
		r = t[key]  or false
		return r
	end
end
local BB = {
	1,10,100,
	1000,10000,100000,
	1000000,10000000,100000000
}
local __tongji = mjlib.tongji
local __floor = math.floor
local __fmod = math.fmod
local __combine = mjlib.combine
function CMD.tingA(pai)
	local t,tc = __tongji(pai)
	return CMD.tingA__(t,tc)
end	
function CMD.tingA__(t,tc)
	local cc={0,1,1,0,1,1,0,1,1,0,1,1,0,1, 1,0,1,1,0,1}
	cc[0] = 1
	cc[-1] = 0

	-- local t,tc = __tongji(pai)
	-- util.dump(t,'CMD.ting.tj')
	-- util.dump(tc,'CMD.ting.tj2')
	--三个无效数量必定无效
	local n = 0
	for i=1,4 do
		local ct = tc[i]
		if cc[ct] == 0 then
			n = n+1
			if(n>2) then
				return false,1
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
	local rc = 0
	local p_out = 0
	local p_in = 0
	if(true) then	
		--迭代自己减一个加一个
		for i=1,4 do
			local vb = t[i]
			local v = vb
			if(v>0) then
				for m=9,1,-1 do
					local v1 = __floor(v/BB[m])
					v = v - v1*BB[m]
					if v1>0 then
						local v2 = vb - BB[m]
						p_out = __combine(i,m)
						---------------------------	
						local vv = vb
						for n=9,1,-1 do
							local v3 = v2+BB[n]
							local tcp = {t[1],t[2],t[3],t[4]}
							tcp[i]=v3 
							-- skynet.error(i,m,n,v3)
							if(CMD.huA__(tcp)) then							
								p_in = __combine(i,n)
								-- table.insert(rr,p_out.."--"..p_in)
								rr[rc+1] = p_out.."--"..p_in
								rc = rc+1
							end
						end
					end
				end
			end
		end
	end	
	if(true) then
		--迭代 自己减一个 其他加一个
		for i=1,4 do
			local vb = t[i]
			local v = vb
			--可减
			if(ot[i][1]>0 and vb>0) then
				--逐个sub
				local v = t[i]
				for m=9,1,-1 do
					local v1 = __floor(v/BB[m])
					v = v - v1*BB[m]
					if v1>0 then
						local v2 = vb - BB[m]
						--检测有效
						if CMD.get(i,v2) then
							p_out = __combine(i,m)
							--逐一尝试
							for j=1,4 do
								--可加
								if (ot[j][2]>0 and t[j]>0 and i~=j) then
									--逐个add
									for n=1,9 do
										local v3 = BB[n]
										local tcp = {t[1],t[2],t[3],t[4]}
										tcp[i]=v2
										tcp[j]=tcp[j] + v3 
										if(CMD.huA__(tcp)) then
											p_in = __combine(j,n)
											-- table.insert(rr,p_out.."--"..p_in)
											rr[rc+1] = p_out.."--"..p_in
											rc = rc+1
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
	end	
	if(#rr>0) then
		return rr
	end
end
function CMD.huA(pai)
	local t,_= __tongji(pai)
	return CMD.huA__(t)
end
function CMD.huA__(t)
	local flag = true
	local jc = 0
	-- util.dump(t,"CMD.hu")
	-- skynet.error(mjlib.i2str(t[1]))
	-- skynet.error(mjlib.i2str(t[2]))
	-- skynet.error(mjlib.i2str(t[3]))
	-- skynet.error(mjlib.i2str(t[4]))
	for i=1,4 do
		if t[i]>0 then
			-- local key = mjlib.i2str(t[i])
			local key = t[i]
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

function CMD.hu7D(pai)
	local t,tc= __tongji(pai)
	return CMD.hu7D__(t,tc)
end
function CMD.hu7D__(t,tc)
	local flag = true
	-- local all = 0
	-- for i=1,4 do
	-- 	all = all + tc[i]
	-- end	
	-- --无吃无碰无杠
	-- if(all~=14) then
	-- 	return false
	-- end
	-- --数量偶数判断
	-- for i=1,4 do
	-- 	all = all + tc[i]
	-- 	flag = flag and __fmod(tc[i],2)==0
	-- end
	-- if(not flag) then
	-- 	return flag
	-- end
	--判断每个数量
	for i=1,4 do
		local v = t[i]
		while v>0 do
			if(__fmod(v,2)==1) then
				flag = false
				break
			end
			v = __floor(v/10) 
		end
		if flag == false then
			break
		end
	end
	return flag
end
function CMD.ting7D(pai)
	local t,tc= __tongji(pai)
	return CMD.ting7D__(t,tc)
end
function CMD.ting7D__(t,tc)
	local all = 0
	for i=1,4 do
		all = all + tc[i]
	end	
	--无吃无碰无杠
	if(all~=14) then
		return false
	end
	------------------------------------
	local ctno2=0--记录奇数数量
	for i=1,4 do
		ctno2 = ctno2 + __fmod(tc[i],2)
	end
	--2个以上数量非偶数 排除
	if(ctno2>2) then
		return false
	end
	------------------------------------
	local rr={}
	--统计所有奇数牌
	local tj={}
	for i=1,4 do
		local v = t[i]
		local j=1
		while v>0 do
			if(__fmod(v,2)==1) then
				tj[#tj+1] = __combine(i,j)
			end
			v = __floor(v/10) 
			j = j + 1
		end
		--超过2个单排
		if(#tj>2) then
			return false
		end
	end

	if(#tj==2) then
		--两张中出任意一张
		rr[1] = tj[1].."--"..tj[2]
		rr[2] = tj[2].."--"..tj[1]
	elseif(#tj==0) then
		--已经是胡牌，任意一张
		for i=1,4 do
			local v = t[i]
			local j=1
			while v>0 do
				if(__fmod(v,10)>0) then
					local vv = __combine(i,j)
					rr[#rr+1] = vv.."--"..vv
				end
				v = __floor(v/10)
				j = j + 1
			end
		end
	end
	------------------------------------
	if(#rr>0) then
		return rr
	end
end
------------------------------------
--吊将
function CMD.checkHuType_DJ(t,id)
--去掉两个id以后,查表有效
--去掉三个id以后,查表无效
end
--大吊车，手牌只一张，吊将
function CMD.checkHuType_DDJ(t,id)
--包括id 只有两张手牌
end
--碰碰
function CMD.checkHuType_PP(t,id)
--去掉三个id以后,查表有效
end
--七对
function CMD.checkHuType_7D(t,id)
--全是两个
end
--十三幺
function CMD.checkHuType_13Y(t,id)
--东南西北中发白9条9筒9万1条1筒+1万做将
end
--幺九
function CMD.checkHuType_YJ(t,id)
--1+9+风
end
--小幺
function CMD.checkHuType_YJ(t,id)
--1+风
end
--清一色
function CMD.checkHuType_QYS(t,id)
--只有一门 无风
end
--混一色
function CMD.checkHuType_QYS(t,id)
--只有一门数字牌 + 风牌
end
--一条龙
function CMD.checkHuType_YTL(t,id)
--同门1-9
end
--一般高
function CMD.chenHuType_YBG(t,id)
--同色三张一搭牌，2组，去掉以后 查表有效
end
--老少
function CMD.checkHuType_LS(t,id)
--同色123 789--
end
--坎
function CMD.checkHuType_KAN(t,id)
--去掉id-1,id,id+1,查表有效 且 是缺口
end
--缺口
function CMD.checkHuType_Only(t,id)
--id换成任意一张，查表全无效
end
--缺几门(数字牌)
function CMD.checkHuType_QM(t,id)
end
--门清
function CMD.checkHuType_MQ(t,id)
--无吃碰
end
-------------------------------------
--缺一门 1
--门清(不吃不碰) 1
--胡258 1
--258将 1

--老少123789 1
--456 1
--一般高123123 1

--东南飞 西北转 中发白 3
--明杠 1
--暗杠 2
--中发白 杠 2
--中发白 暗杠 4

--碰碰胡 5
--混一色 5
--清一色 10
--一条龙 10
--七对 20
--幺九 30
--小幺 50
--十三花 100
------------------------------------
--东南飞 西北转 中发白 胡牌算法
--细分牌种
---1 万
---2 条
---3 筒
---4 东南1条
---5 西北1筒
---6 中发白
--1条1筒排列组合分别 转为4和5 算胡牌
---2个1条 2个1筒 组合
---两层for循环倒序从多到少，每一项再去查表，是否有效即可
---22,21,20,
---12,11,10,
---02,01,00
------------------------------------
local function testA()
	local ttt ={
		-- 1,2,3, 4,5,6, 31,31,31, 11,12,13, 20,20
		-- 11,12,13, 30,30,30, 7,8,9, 21,22,23, 6,6
		1,1,2,2,3,3, 4,4, 5,5,6,6, 7,8
	}
	local ta = skynet.now()
	local r
	for i=1,100000 do
		r = CMD.huA(ttt)
	end
	local tb = skynet.now()
	skynet.error("call CMD.huA = ",r , " tm =",(tb-ta)*10)
	skynet.sleep(10)

	local ta = skynet.now()
	local r
	local t,tc= mjlib.tongji(ttt)
	for i=1,100000 do
		t[1] = t[1]+BB[3]
		t[1] = t[1]-BB[3]
		r = CMD.huA__(t)
	end
	local tb = skynet.now()
	skynet.error("call CMD.huA__ = ",r , " tm =",(tb-ta)*10)
	skynet.sleep(10)
	---------------------------------------------------------
	local ta = skynet.now()
	local r
	for i=1,10000 do
		r = CMD.tingA(ttt)
	end
	local tb = skynet.now()
	skynet.error("call CMD.tingA tm =",(tb-ta)*10)
	util.dump(r,'CMD.tingA')
	skynet.sleep(10)

	local ta = skynet.now()
	local r
	local t,tc= mjlib.tongji(ttt)
	for i=1,10000 do
		t[2] = t[2]+BB[9]
		t[2] = t[2]-BB[9]
		r = CMD.tingA__(t,tc)
	end
	local tb = skynet.now()
	skynet.error("call CMD.tingA__ tm =",(tb-ta)*10)
	util.dump(r,'CMD.tingA__')
end
local function test7D()
	---------------------------------------------------------
	---------------------------------------------------------
	---------------------------------------------------------
	local ttt ={
		-- 1,2,3, 4,5,6, 31,31,31, 11,12,13, 20,20
		-- 1,1,1,1, 11,11,11,11, 30,30,30,30, 7,7
		1,1,2,2,3,3,4,4,5,5,6,6, 7,8
	}
	local ta = skynet.now()
	local r
	for i=1,100000 do
		r = CMD.hu7D(ttt)
	end
	local tb = skynet.now()
	skynet.error("call CMD.hu7D = ",r , " tm =",(tb-ta)*10)
	skynet.sleep(10)

	local ta = skynet.now()
	local r
	local t,tc= mjlib.tongji(ttt)
	for i=1,100000 do
		t[1] = t[1]+BB[3]
		t[1] = t[1]-BB[3]
		r = CMD.hu7D__(t,tc)
	end
	local tb = skynet.now()
	skynet.error("call CMD.hu7D__ = ",r , " tm =",(tb-ta)*10)
	skynet.sleep(10)
	---------------------------------------------------------
	local ta = skynet.now()
	local r
	for i=1,10000 do
		r = CMD.ting7D(ttt)
	end
	local tb = skynet.now()
	skynet.error("call CMD.ting7D tm =",(tb-ta)*10)
	util.dump(r,'CMD.ting7D')
	skynet.sleep(10)

	local ta = skynet.now()
	local r
	local t,tc= mjlib.tongji(ttt)
	for i=1,10000 do
		t[2] = t[2]+BB[8]
		t[2] = t[2]-BB[8]
		r = CMD.ting7D__(t,tc)
	end
	local tb = skynet.now()
	skynet.error("call CMD.ting7D__ tm =",(tb-ta)*10)
	util.dump(r,'CMD.ting7D__')
end

local function test_table()

	local ttt = {
		222222200,
		111222,
		33221133,
	}
	
	local ta = skynet.now()
	local r
	for i=1,10000000 do
		for j=1,1 do
			r = zall[ttt[j]]
		end
	end
	local tb = skynet.now()
	skynet.error("call table[i] tm =",(tb-ta)*10)
	skynet.sleep(10)


	local ta = skynet.now()
	local r
	for i=1,10000000 do
		for j=1,1 do
			r = zall_s[tostring(ttt[j])]
		end
	end
	local tb = skynet.now()
	skynet.error("call table[s1] tm =",(tb-ta)*10)
	skynet.sleep(10)


	for j=1,3 do
		ttt[j] = tostring(ttt[j])
	end
	local ta = skynet.now()
	local r
	for i=1,10000000 do
		for j=1,1 do
			r = zall_s[ttt[j]]
		end
	end
	local tb = skynet.now()
	skynet.error("call table[s2] tm =",(tb-ta)*10)
	skynet.sleep(10)
end

skynet.start(function()

	-- local ta = skynet.now()		
	-- builder.new("majiang", {zipai = zipai, fengpai = fengpai})
	-- local tb = skynet.now()
	-- skynet.error("majiang builder end",(tb-ta)*10)
	-- zipai = nil
	-- fengpai = nil
	skynet.fork(testA)
	skynet.fork(test7D)
	-- skynet.fork(test_table)
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
