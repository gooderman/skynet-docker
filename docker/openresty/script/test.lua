local cjson = require "cjson"
local data = {
	header = 'lua',
	body = '123456789000'
}

local mysql = require "resty.mysql"
local M={}
function M.testmysql() 	
	local db, err = mysql:new()
	if not db then
	    return "failed to instantiate mysql: "
	end

	db:set_timeout(1000) -- 1 sec

	local ok, err, errcode, sqlstate = db:connect{
	    host = "mymysql",
	    port = 3306,
	    database = "skynet",
	    user = "root",
	    password = "123456",
	    -- charset = "utf8",
	    max_packet_size = 1024 * 1024,
	    on_connect = function(db)
			local res = db:query("set charset utf8mb4 ; SET GLOBAL time_zone = '+8:00'");
		end
	}


	if not ok then
	    return "failed to connect mysql: "..err
	end

	-- ngx.say("connected to mysql.")

	local res, err, errcode, sqlstate =
	    db:query("drop table if exists cats")
	if not res then
	    return "bad result: "..err
	end

	res, err, errcode, sqlstate =
	    db:query("create table cats "
	             .. "(id serial primary key, "
	             .. "name varchar(5))")
	if not res then
	    return "bad result: "..err
	end


	res, err, errcode, sqlstate =
	    db:query("insert into cats (name) "
	             .. "values (\'Bob\'),(\'\'),(null)")
	if not res then
	    return "bad result: "..err
	end

	return 'mysql test succ'
end

function M.testdns()
	local resolver = require "resty.dns.resolver"
    local r, err = resolver:new{
        nameservers = {"127.0.0.11"},
        retrans = 5,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    }

    if not r then
        return "failed to instantiate the resolver: "..err
    end

    local answers, err, tries = r:query("myredis", nil, {})
    if not answers then
        return "failed to query the DNS server: "..err
    end
    if answers.errcode then
        return "server returned error code: "..answers.errcode..
                ": "..answers.errstr
    end

    for i, ans in ipairs(answers) do
        return "dns test true "..ans.name.." "..(ans.address or ans.cname)
    end
    return 'dns test fail'
end

local redis = require "resty.redis"
function M.testredis()
	local red = redis:new()
    red:set_timeout(10000) -- 1 sec
    local ok, err = red:connect("myredis", 6379)
    if not ok then
        return "failed to connect redis: "..err
    end

    ok, err = red:set("dog", "an animal")
    if not ok then
        return "failed to set dog: "..err
    end

    return 'test redis succ'
end	

function M.getinfo()
	local a,b,c
	local ok,info = pcall(M.testmysql)
	a = info
	ok,info = pcall(M.testredis)
	b = info
	ok,info = pcall(M.testdns)
	c = info
	return a.."\n"..b.."\n"..c
end

return {cjson.encode(data),M.getinfo}