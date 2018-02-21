local skynet = require "skynet"
require "manager"
-- local socket = require "socket"
-- local proxy = require "socket_proxy"
local util = require "util"
require "functions"
local mjlib = import(".base",...) 


local a = os.clock()
local szall = require "mjlib.gen.B_wtt"
local dnall = require "mjlib.gen.B_zi_dn"
local xball = require "mjlib.gen.B_zi_xb"
local zfball = require "mjlib.gen.B_zi_zfb"
local MAX_TP = 6

local b = os.clock()
skynet.error("mj_heshun_suanfen load",b-a)


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
		local r = szall["adnkdkfka"]
	end	
	local tb = skynet.now()
	skynet.error("majiang test end",(tb-ta)*10)
end
function CMD.get(paitp,key)
	local t
	if(paitp==4) then
		t = dnall
	elseif(paitp==5) then
		t = xball	
	elseif(paitp==6) then
		t = zfball			
	else
		t = szall
	end
	r = t[key]  or false
	return r
end
function CMD.gett(paitp,key)
	local t
	if(paitp==4) then
		t = dnall
	elseif(paitp==5) then
		t = xball	
	elseif(paitp==6) then
		t = zfball			
	else
		t = szall
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
--每类牌最大序号
local CC = {
	9,9,9,2,2,3
}
local CC1 = {
	9,9,9,3,3,3 -- 东南西北需要特殊处理
}
--每种张数量 能否成搭 3*n+2
local OPT={0,1,1,0,1,1,0,1,1,0,1,1,0,1, 1,0,1,1,0,1}
OPT[0] = 1
OPT[-1] = 0

local __tongji = mjlib.tongji
local __floor = math.floor
local __fmod = math.fmod
local __combine = mjlib.combine
local __parse = mjlib.parse
function CMD.tingA(pai)
	local t,tc = __tongji(pai)
	return CMD.tingA__(t,tc)
end	
function CMD.tingA__(t,tc)
	-- local t,tc = __tongji(pai)
	-- util.dump(t,'CMD.ting.tj')
	-- util.dump(tc,'CMD.ting.tj2')
	--三个无效数量必定无效
	local n = 0
	for i=1,MAX_TP do
		local ct = tc[i]
		if OPT[ct] == 0 then
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
	for i=1,MAX_TP do
		ot[i] = {}
		local ct = tc[i]
		if OPT[ct-1] == 0 then
			ot[i][1]=0
		else	
			ot[i][1]=1
		end
		if OPT[ct+1] == 0 then
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
		for i=1,MAX_TP do
			local vb = t[i]
			local v = vb
			if(v>0) then
				local max = CC[i] --最大序号万条筒9东南2西北2中发白3
				for m=max,1,-1 do
					local v1 = __floor(v/BB[m])
					v = v - v1*BB[m]
					if v1>0 then
						local v2 = vb - BB[m]
						p_out = __combine(i,m)
						---------------------------	
						local vv = vb
						local max_a = CC1[i]
						for n=max_a,1,-1 do
							-- local tcp = {table.unpack(t)}
							local tcp = {t[1],t[2],t[3],t[4],t[5],t[6]}
							if(n==3 and (i==4 or i==5)) then
								tcp[i]=v2
								tcp[i-2] = t[i-2] + BB[1]
								if(CMD.huDNFXBZ__(tcp)) then
									p_in = __combine(i-2,1)
									rr[rc+1] = {p_out,p_in,'dnf-1'}
									rc = rc+1
								end
							else
								local v3 = v2+BB[n]
								tcp[i]=v3
								if(CMD.huA__(tcp)) then							
									p_in = __combine(i,n)
									rr[rc+1] = {p_out,p_in}
									rc = rc+1
								elseif(CMD.hu13Y__(tcp)) then
									p_in = __combine(i,n)
									rr[rc+1] = {p_out,p_in,'13y'}
									rc = rc+1
								elseif(CMD.huDNFXBZ__(tcp)) then
									p_in = __combine(i,n)
									rr[rc+1] = {p_out,p_in,'dnf'}
									rc = rc+1
								end
							end
						end
					end
				end
			end
		end
	end	
	if(true) then
		--迭代 自己减一个 其他加一个
		for i=1,MAX_TP do
			local vb = t[i]
			local v = vb
			--可减
			local max = CC[i]--最大序号万条筒9东南2西北2中发白3
			if(ot[i][1]>0 and vb>0) then
				--逐个sub
				local v = t[i]
				for m=max,1,-1 do
					local v1 = __floor(v/BB[m])
					v = v - v1*BB[m]
					if v1>0 then
						local v2 = vb - BB[m]
						--检测有效
						if CMD.get(i,v2) then
							p_out = __combine(i,m)
							--逐一尝试
							for j=1,MAX_TP do
								--可加
								if (ot[j][2]>0 and t[j]>0 and i~=j) then
									--逐个add
									local maxj = CC1[j]--最大序号万条筒9东南2西北2中发白3
									for n=1,maxj do
										local tcp = {t[1],t[2],t[3],t[4],t[5],t[6]}
										tcp[i]=v2
										if(n==3 and (j==4 or j==5)) then
											tcp[j-2] = t[j-2] + BB[1]
											if(CMD.huDNFXBZ__(tcp)) then
												p_in = __combine(j-2,1)
												rr[rc+1] = {p_out,p_in,'dnf-2'}
												rc = rc+1
											end
										else	
											local v3 = BB[n]
											-- local tcp = {table.unpack(t)}
											tcp[j]=tcp[j] + v3
											if(CMD.huA__(tcp)) then
												p_in = __combine(j,n)
												-- table.insert(rr,p_out.."--"..p_in)
												rr[rc+1] = {p_out,p_in}
												rc = rc+1
											elseif(CMD.hu13Y__(tcp)) then
												p_in = __combine(j,n)
												rr[rc+1] = {p_out,p_in,'13y'}
												rc = rc+1											
											elseif(CMD.huDNFXBZ__(tcp,tc)) then
												p_in = __combine(j,n)
												rr[rc+1] = {p_out,p_in,'dnf'}
												rc = rc+1
											end	
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
------------------------------
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
	for i=1,MAX_TP do
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
------------------------------
function CMD.hu7D(pai)
	local t,tc= __tongji(pai)
	return CMD.hu7D__(t,tc)
end
function CMD.hu7D__(t,tc)
	local flag = true
	local all = 0
	for i=1,MAX_TP do
		all = all + tc[i]
	end	
	--无吃无碰无杠
	if(all~=14) then
		return false
	end
	-- --数量偶数判断
	-- for i=1,4 do
	-- 	all = all + tc[i]
	-- 	flag = flag and __fmod(tc[i],2)==0
	-- end
	-- if(not flag) then
	-- 	return flag
	-- end
	--判断每个数量
	for i=1,MAX_TP do
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
	for i=1,MAX_TP do
		all = all + tc[i]
	end	
	--无吃无碰无杠
	if(all~=14) then
		return false
	end
	------------------------------------
	local ctno2=0--记录奇数数量
	for i=1,MAX_TP do
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
	for i=1,MAX_TP do
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
		rr[1] = {tj[2],tj[1]}
		rr[2] = {tj[1],tj[2]}
	elseif(#tj==0) then
		--已经是胡牌，任意一张
		for i=1,MAX_TP do
			local v = t[i]
			local j=1
			while v>0 do
				if(__fmod(v,10)>0) then
					local vv = __combine(i,j)
					rr[#rr+1] = {vv,vv}
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
------东南飞西北转 胡牌
function CMD.huDNFXBZ(pai)
	local t,_= __tongji(pai)
	return CMD.huDNFXBZ__(t)
end
function CMD.huDNFXBZ__(t)
	local flag = true
	local tiao1 = __fmod(t[2],10)
	local tong1 = __fmod(t[3],10)
	local dong = __fmod(t[4],10)
	local nan = __fmod( __floor((t[4]-dong)/10) ,10)
	local xi = __fmod(t[5],10)
	local bei = __fmod( __floor((t[5]-xi)/10) ,10)

	local dnf = math.min(tiao1,math.min(dong,nan))
	local xbz = math.min(tong1,math.min(xi,bei))
	if(dnf==0 and xbz==0) then
		return false
	end

	local r1 = t[1]==0 and 0 or CMD.get(1,t[1])
	local r6 = t[6]==0 and 0 or CMD.get(6,t[6])
	--查不到
	if not (r1 and r6) then
		return false
	end	
	--多个将
	if (r1+r6)>1 then 
		return false
	end
	local rr={}
	--从多到少迭代
	for i=dnf,0,-1 do
		local tcp = {t[1],t[2],t[3],t[4],t[5],t[6]}
		---------------------
		---转换
		tcp[2]=t[2] - i*BB[1]
		tcp[4]=t[4] + i*BB[3]

		-- skynet.error("huDNFXBZ__3_dnf",tcp[4],tcp[2])
		---------------------
		--可以添加长度判断
		--可以直接查表过滤
		local r2 = tcp[2]==0 and 0 or CMD.get(2,tcp[2])
		local r4 = tcp[4]==0 and 0 or CMD.get(4,tcp[4])
		if (r2 and r4) then
			if(r1+r6+r2+r4<=1) then
				for j=xbz,0,-1 do 
					----------------------
					---转换
					tcp[3]=t[3] - j*BB[1]
					tcp[5]=t[5] + j*BB[3]

					-- skynet.error("huDNFXBZ__4_xbz",tcp[5],tcp[3])
					----------------------
					local r3 = tcp[3]==0 and 0 or CMD.get(3,tcp[3])
					local r5 = tcp[5]==0 and 0 or CMD.get(5,tcp[5])
					if (r3 and r5) then
						if(r1+r6+r2+r4+r3+r5==1) then
							rr[#rr+1] = {i,j}
						end
					end
				end
			end
		end
	end	
	return #rr>0, rr
end
------------------------------------
--十三幺
function CMD.hu13Y__(t)
--东南西北中发白9条9筒9万1条1筒1万 其中任一做将
	return 
	t[1]==100000002 and 
	t[2]==100000001 and 
	t[3]==100000001 and
	t[4]==11 and
	t[5]==11 and
	t[6]==111
end
function CMD.hu(pai,id)
	local t,tc= __tongji(pai)
	local a = CMD.hu13Y__(t)
	local b = CMD.hu7D__(t,tc)
	local c = CMD.huA__(t)
	local d = CMD.huDNFXBZ__(t)
	return a or b or c or d
end

function CMD.ting(pai)
	local t,tc = __tongji(pai)
	local ra = CMD.tingA__(t,tc) --包括普通牌(包括中发白)，东南飞西北转，十三幺
	local rb = CMD.ting7D__(t,tc)
	if not (ra or rb) then
		return false
	end
	local r = ra or {}
	table.merge(r, rb or {})
	return r
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
--幺九--先判断小幺再判断幺九
function CMD.checkHuType_YJ(t,id)
--1+9+风
    local a1 = ( t[1] - __floor(t[1]/BB[9]) * BB[9] ) / 10 < 1
    local a2 = ( t[2] - __floor(t[2]/BB[9]) * BB[9] ) / 10 < 1
    local a3 = ( t[3] - __floor(t[3]/BB[9]) * BB[9] ) / 10 < 1
    if (a1 and a2 and a3) and 
    	(t[1]>0 or t[2]>0 or t[3]>0) then
    	return true
    end
end
--小幺
function CMD.checkHuType_XY(t,id)
--1+风
    local a1 = t[1] / 10  < 1
    local a2 = t[2] / 10  < 1
    local a3 = t[3] / 10  < 1
    if (a1 and a2 and a3) and 
    	(t[1]>0 or t[2]>0 or t[3]>0) then
    	return true
    end
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
function CMD.testA()
	local ttt ={
		-- 1,2,3, 4,5,6, 31,31,31, 11,12,13, 20,20
		-- 11,12,13, 30,30,30, 32,33,34, 21,22,23, 6,6
		-- 1,1,2,2,3,3, 4,4, 5,5,6,6, 7,8
		28,29,10, 30,31,19, 32,33,34, 10,10,10, 9,9 --东南飞西北转中发白
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

	---------------------------------------------------------
	local ta = skynet.now()
	local r,r1
	for i=1,1 do
		r,r1 = CMD.huDNFXBZ(ttt)
	end
	local tb = skynet.now()
	skynet.error("call CMD.huDNFXBZ = ",r , " tm =",(tb-ta)*10)
	util.dump(r1,'CMD.huDNFXBZ')
	skynet.sleep(10)

	local ta = skynet.now()
	local r,r1
	local t,tc= mjlib.tongji(ttt)
	for i=1,1 do
		t[1] = t[1]+BB[3]
		t[1] = t[1]-BB[3]
		r,r1 = CMD.huDNFXBZ__(t)
	end
	local tb = skynet.now()
	skynet.error("call CMD.huDNFXBZ__ = ",r , " tm =",(tb-ta)*10)
	util.dump(r1,'CMD.huDNFXBZ__')
	skynet.sleep(10)
	---------------------------------------------------------
end
function CMD.test7D()
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

function CMD.test()
	local ttt = {
		{1,2,3, 4,5,6, 31,31,31, 11,12,13, 20,20 },
		{28,29,10, 30,31,9, 32,33,34, 10,11,12, 9,9}, --东南飞西北转中发白

		{1,1, 3,3, 5,5, 11,11, 15,15, 21,21, 31,30},--7对
		{1,1,9, 10,18, 19,27, 28,29,30,31,32,33,31},--13幺
	}
	local r
	for i=1,#ttt do
		r = CMD.hu(ttt[i])
		skynet.error("test CMD.hu "..i ,r)
	end
	---------------------------------------------------------
	-- local ta = skynet.now()
	-- local r
	-- for i=1,#ttt do
	-- 	r = CMD.ting(ttt[i])
	-- 	util.dump(r,'test CMD.ting '..i)
	-- end
	-- local tb = skynet.now()
	-- skynet.error("test CMD.ting tm =",(tb-ta)*10)	
	---------------------------------------------------------
	local ta = skynet.now()
	local r
	for i=1,10000 do
		r = CMD.ting(ttt[1])
	end
	local tb = skynet.now()
	skynet.error("test CMD.ting tm =",(tb-ta)*10)	
	util.dump(r,'test CMD.ting')
	-- skynet.error("LUA max integer",math.maxinteger)
end

return CMD