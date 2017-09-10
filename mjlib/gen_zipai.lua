local util = require("util")
local dump = util.dump

local function sort(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    return r
end

local function ck4(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    local cktb={ '111(1+)','222(2+)','333(3+)','444(4+)','555(5+)','666(6+)','777(7+)','888(8+)','999(9+)','aaa(a+)','bbb(b+)'}
    for _,v in ipairs(cktb) do
        if(string.find(r,v)) then
            return false,v
        end
    end
    return true,r
end

local function ck5(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    local cktb={ '1111(1+)','2222(2+)','3333(3+)','4444(4+)','5555(5+)','6666(6+)','7777(7+)','8888(8+)','9999(9+)','aaaa(a+)','bbbb(b+)'}
    for _,v in ipairs(cktb) do
        if(string.find(r,v)) then
            return false,v
        end
    end
    return true,r
end

local ck = ck5

print("function ck",ck('386222223'))

local function filter(rr)
    for k,vt in pairs(rr) do
        local tmp = {}
        local t = {}
        for _,__v in ipairs(vt) do
            tmp[__v]=true
        end
        for __k in pairs(tmp) do
            table.insert(t,__k)
        end
        rr[k] = t
    end
    return rr
end

local t1 = {
    1,2,3,4,5,6,7,8,9
}
local t2 = {
    11,22,33,44,55,66,77,88,99
}
local t2_1 = {
    12,23, 34,45, 56,67, 78,89
}
local t2_2 = {
    13,24, 35,46, 57,68, 79
}
local t3 = {
    111,222,333,444,555,666,777,888,999,
    123,234,345,456,567,678,789
}
local t3_1 = {
    111,222,333,444,555,666,777,888,999,
}
local t3_2 = {
    123,234, 345,456, 567,678, 789
}


local function f1()
    local r={}
    for _,k1 in pairs(t1) do
        r[tostring(k1)]={1} --缺将
    end
    return filter(r)
end
local function f2()
    local r={}
    for _,k1 in pairs(t2) do
        r[tostring(k1)]={1} --1将
    end
    for _,k1 in pairs(t2_1) do
        r[tostring(k1)]={-1} --缺将
    end
    for _,k1 in pairs(t2_2) do
        r[tostring(k1)]={-1} --缺将
    end
    -- dump(r,"22-22")
    return filter(r)
end

local function f3()
    local r={}
    for _,k1 in pairs(t3) do
        r[tostring(k1)]={-1} --无将 & 成一搭牌
    end
    return filter(r)
end

local function f4()
    local rr={}
    local r={}
    -------------------------------
    local rr2 = {}
    for _,k1 in pairs(t2) do
        for _,k2 in pairs(t2) do
            table.insert(r,k1..k2)
        end
    end
    for _,s in ipairs(r) do
        local f,rs =  ck4(s) --四个必定无法胡过滤掉 癞子例外吗？？？
        if(f) then
            -- table.insert(rr,rs)
            if(not rr2[rs]) then
                rr2[rs]=2 --2将 
            end
        end
    end
    -------------------------------
    r = {}
    local rr_1= {}
    for _,k1 in pairs(t3) do
        for _,k2 in pairs(t1) do
            table.insert(r,k1..k2)
        end
    end
    for _,s in ipairs(r) do
        local f,rs =  ck4(s)
        if(f) then
            -- table.insert(rr,rs)
            if(not rr_1[rs]) then
                rr_1[rs] = 1 --缺将
            end
        end
    end
    -------------------------------
    r = {}
    local rr1= {}
    for _,k1 in pairs(t2) do
        for _,k2 in pairs(t2_1) do
            table.insert(r,k1..k2)
        end
        for _,k2 in pairs(t2_2) do
            table.insert(r,k1..k2)
        end
    end
    for _,s in ipairs(r) do
        local f,rs =  ck4(s)
        if(f) then
            -- table.insert(rr,rs)
            if(not rr1[rs]) then
                rr1[rs] = 1 --1将
            end
        end
    end
    -------------------------------
    -------------------------------
    local nn=0
    for k,v in pairs(rr1) do
        rr[k] = rr[k] or {}
        table.insert(rr[k],v)
        nn = nn+1
    end
    for k,v in pairs(rr2) do
        rr[k] = rr[k] or {}
        table.insert(rr[k],v)
        nn = nn+1
    end
    for k,v in pairs(rr_1) do
        rr[k] = rr[k] or {}
        table.insert(rr[k],v)
        nn = nn+1
    end
    local nnn = 0
    for _,_ in pairs(rr) do
        nnn = nnn+1
    end
    print(string.format("44-44 ===== %d",nnn))
    -- dump(rr,"44")
    return filter(rr)
end

local function f5()
    local r={}
    for _,k1 in pairs(t3) do
        for k2,v2 in pairs(__t2) do
            r[k1..k2]=v2
        end
    end
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("55-55 ===== %d",nn))
    -- dump(rr,"f5")
    return filter(rr)
end

local function f6()
    local t={}
    --3
    for _,k1 in pairs(t3) do
        --3
        for _,k2 in pairs(t3) do
            table.insert(t,k1..k2)
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for _,s in ipairs(r) do
        local f,rs =  ck(s)
        if(f) then
            -- table.insert(rr,rs)
            if(not rr[rs]) then
                rr[rs]= {-1}
                nn = nn + 1
            end
        end
    end
    print(string.format("66-66 ===== %d",nn))
    -- dump(rr,"f6")
    return filter(rr)
end

local function f7()
    local t={}
    --4
    for k,vt in pairs(__t4) do
        --3
        for _,k3 in pairs(t3) do
            local s = k..tostring(k3)
            t[s]=vt
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("77-77 ===== %d",nn))
    -- dump(rr,"fff7")
    return filter(rr)
end

local function f8()
    local t=__t6
    --3
    local r={}
    for k in pairs(t) do
        --2
        for k2,v2 in pairs(__t2) do
            r[k..k2]=v2
        end
    end
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("88-88 ===== %d",nn))
    -- dump(rr,"f8")
    return filter(rr)
end

local function f9()
    local t=__t6
    --3
    local r={}
    for k1,vt in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=vt
        end
    end
    local rr = {}
    local nn = 0
    for s,vt in pairs(r) do
        local f,rs = ck(s)
        if(f) then
            rr[rs]=vt
            nn = nn + 1
        end
    end
    print(string.format("99-99 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end

local function f10()
    local t={}
    --4
    for k,vt in pairs(__t4) do
        --3
        for k2 in pairs(__t6) do
            local s = k..k2
            t[s]=vt
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("10-10 ===== %d",nn))
    -- dump(rr,"fff7")
    return filter(rr)
end


local function f11()
    local t=__t9
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for k2,v2 in pairs(__t2) do
            r[k1..k2]=v2
        end
    end
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("11-11 ===== %d",nn))
    return filter(rr)
end

local function f12()
    local t=__t9
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            table.insert(r,k1..k2)
        end
    end
    local rr = {}
    local nn = 0
    for _,s in ipairs(r) do
        local f,rs =  ck(s)
        if(f) then
            if(not rr[rs]) then
                rr[rs]={-1}
                nn = nn + 1
            end
        end
    end
    print(string.format("12-12 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end

local function f13()
    local t={}
    --4
    for k,vt in pairs(__t4) do
        --3
        for k2 in pairs(__t9) do
            local s = k..k2
            t[s]=vt
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("13-13 ===== %d",nn))
    -- dump(rr,"fff7")
    return filter(rr)
end

local function f14()
    local t=__t12
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        --2
        for k2,v2 in pairs(__t2) do
            r[k1..k2]=v2
        end
    end
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("14-14 ===== %d",nn))
    return filter(rr)
end

--------------------------------------------------------
local function f15()
    local t=__t12
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            table.insert(r,k1..k2)
        end
    end
    local rr = {}
    local nn = 0
    for _,s in ipairs(r) do
        local f,rs =  ck(s)
        if(f) then
            if(not rr[rs]) then
                rr[rs]={-1}
                nn = nn + 1
            end
        end
    end
    print(string.format("15-15 ===== %d",nn))
    return filter(rr)
end

local function f16()
    local t={}
    --4
    for k,vt in pairs(__t4) do
        --3
        for k2 in pairs(__t12) do
            local s = k..k2
            t[s]=vt
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("16-16 ===== %d",nn))
    -- dump(rr,"fff7")
    return filter(rr)
end

local function f17()
    local t=__t15
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for k2,v2 in pairs(__t2) do
            r[k1..k2]=v2
        end
    end
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("17-17 ===== %d",nn))
    return filter(rr)
end

--------------------------------------------------------
local function f18()
    local t=__t15
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            table.insert(r,k1..k2)
        end
    end
    local rr = {}
    local nn = 0
    for _,s in ipairs(r) do
        local f,rs =  ck(s)
        if(f) then
            if(not rr[rs]) then
                rr[rs]={-1}
                nn = nn + 1
            end
        end
    end
    print(string.format("18-18 ===== %d",nn))
    return filter(rr)
end

local function f19()
    --4
    local t={}
    for k,vt in pairs(__t4) do
        --3
        for k2 in pairs(__t15) do
            local s = k..k2
            t[s]=vt
        end
    end
    local r = t
    local rr = {}
    local nn = 0
    for k,vt in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(rr[rs]) then
                for _,v in pairs(vt) do
                    table.insert(rr[rs],v)
                end
            else
                local tb={}
                for _,v in pairs(vt) do
                    table.insert(tb,v)
                end
                rr[rs]=tb
                nn = nn + 1
            end
        end
    end
    print(string.format("19-19 ===== %d",nn))
    -- dump(rr,"fff7")
    return filter(rr)
end

local function f20()
    local t=__t18
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for _,k2 in pairs(t2) do
            table.insert(r,k1..k2)
        end
    end
    local rr = {}
    local nn = 0
    for _,s in ipairs(r) do
        local f,rs =  ck(s)
        if(f) then
            -- table.insert(rr,rs)
            if(not rr[rs]) then
                rr[rs]={1}
                nn = nn + 1
            end
        end
    end
    print(string.format("20-20 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end
--需要的奖牌
__t1 = f1() --=1
__t2 = f2() --[2] --=1,-1
__t3 = f3() --[3] --=-1

--====
__t4 = f4() --[3,1][2,2]=[ 3*1 + 2*2 ] --=1,2
--====

__t5 = f5() --[2,3] --=1,-1
__t6 = f6() --[3,3] --=-1

--====
__t7 = f7() --[3,3,1][3,2,2]=[ 6*1 + 3*4 ] --=1,2
--====

__t8 = f8() --[3,3,2]==[6*2] --=1,-1
__t9 = f9() --[3,3,3]==[6*3] --=-1

-- --====
__t10 = f10() --[3,3,3,1][3,3,2,2]=[ 9*1 + 6*4 ] --=1,2
-- --====

__t11 = f11() --[3,3,3,2]=[9*2] --=1,-1
__t12 = f12() --[3,3,3,3]=[9*3] --=-1

-- --====
__t13 = f13() --[3,3,3,3,1][3,3,3,2,2]=[ 12*1 + 9*4 ] --=1,2
-- --====

__t14 = f14() --[3,3,3,3,2]=[12*2] --=1
__t15 = f15() --[3,3,3,3,3]=[12*3] -=-1

--====
__t16 = f16() --[3,3,3,3,3,1][3,3,3,3,2,2]=[ 15*1 + 12*4 ] --=1,2
--====

__t17 = f17() --[3,3,3,3,3,2]=[15*2] --=1,-1
__t18 = f18() --[3,3,3,3,3,3]=[15*3] --=-1

--====
__t19 = f19() --[3,3,3,3,3,3,1][3,3,3,3,3,2,2]=[ 18*1 + 15*4] --=1,2
--====

__t20 = f20() --[3,3,3,3,3,3,2]= [ 18*2 ] --=1


--排除死牌,不可能胡eg： 7张 1236666 这种只能胡6的
--从7,10,13,16,19中排除
--算法：7为例
--检查7中 包含 四张相同牌 的组合，增加任意其他牌，到8里面匹配，如果结果包含1，则有效，否则无效是死牌
--7+1--》8
--10+1--》11
--13+1--》14
--16+1--》17
--19+1--》20
function filter(a,b,info)
    local ct = 0
    local rm = 0
    local rmtb ={}
    for k in pairs(a) do
        ct = ct +1
        local has = false
        for _,v1 in pairs(t1) do
            local __k = sort(k..v1)
            local r =  b[__k]
            if(r) then
                for _,_v in pairs(r) do
                    if _v==1 then
                        has = true
                        break
                    end
                end                    
            end
            if(has) then
                break
            end
        end
        if(not has) then
            rm = rm + 1
            table.insert(rmtb,k)
        end
    end
    for _,k in ipairs(rmtb) do
        a[k] = nil
    end
    print(info,ct,rm)
end

filter(__t7,__t8,"filter __t7")
filter(__t10,__t11,"filter __t10")
filter(__t13,__t14,"filter __t13")
filter(__t16,__t17,"filter __t16")
filter(__t19,__t20,"filter __t19")

function tabletofile(tb,path)
    local file = io.open(path,'w+b')
    local sss = "local t={\n"
    local i=0
    for k,v in pairs(tb) do
        local line = ""
        if(type(v)=='table') then
            local ttss = "{"
            local dot = ''
            for _,numb in ipairs(v) do
                ttss = ttss..dot..numb
                dot=','
            end
            ttss = ttss.."}"
            line = string.format("[\"%s\"] = %s,\n",k,ttss)
        elseif(type(v)=='number') then
            line = string.format("[\"%s\"] = %d,\n",k,v)
        end
        sss = sss .. line
        i=1+1
        if(i>5000) then
            i=0
            file:write(sss)
            sss=""
        end
    end

    sss = sss .. "\n}\n"
    sss = sss .. "return t"
    file:write(sss)
    io.close(file)
end
local path = ...
path = path..'/zzz/'
os.execute("mkdir " .. path)
local tb = {
    __t1,
    __t2,
    __t3,
    __t4,
    __t5,
    __t6,
    __t7,
    __t8,
    __t9,
    __t10,
    __t11,
    __t12,
    __t13,
    __t14,
    __t15,
    __t16,
    __t17,
    __t18,
    __t19,
    __t20,
}

for k,v in ipairs(tb) do
    if(v) then
        print("tablefofile",k)
        local ppp = string.format("zi_%d.lua",k)
        ppp = path..ppp
        os.execute("rm -f "..ppp)
        tabletofile(v,ppp) 
    end
end    
-- tabletofile(__t4,path..'__t4.lua')
-- tabletofile(__t5,path..'__t5.lua')
-- tabletofile(__t6,path..'__t6.lua')
-- tabletofile(__t7,path..'__t7.lua')
-- tabletofile(__t8,path..'__t8.lua')
-- tabletofile(__t9,path..'__t9.lua')
-- tabletofile(__t10,path..'__t10.lua')
-- tabletofile(__t11,path..'__t11.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t20,path..'__t20.lua')
return tb


-- zipai_gen()
-- fengpai_gen()

-- 分组：
-- 列出所有 成打（2，3）的牌
-- eg：
-- 3*n | 3*n+2
-- 2,[11,22,33,44,55,66,77,88,99]--9

-- 3,[111,222,333,444,555,666,777,888,999,123,234,345,456,567,678,789]--16
-- 5,[3+2] C(16,1) * C(9,1)

-- 6,[3+3] C(16,2)
-- 8,[3+3+2] = [6+2] C(16,2)* C(9,1)

-- 9,[3+3+3] = [6+3] C(16,3)
-- 11,[3+3+3+2] = [9+2] C(16,3)* C(9,1)

-- 12,[3+3+3+3+3] = [9+3] C(16,4)
-- 14,[3+3+3+3+3+2] = [12+2] C(16,4) * C(9,1)


