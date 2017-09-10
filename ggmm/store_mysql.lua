local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local mysql = require "skynet.db.mysql"
local util = require 'util'

local db = nil
local conf={
	host="127.0.0.1",
	port=3306,
	database="skynet",
	user="root",
	password="123456",
	max_packet_size = 1024 * 1024,
	on_connect = function(db)
		db:query("set charset utf8");
	end
}

local command = {}

function command.init()

	db=mysql.connect(conf)

	if not db then
		print("mysql failed to connect")
		return
	end
	print("mysql success to connect to server")
	local res = db:query("drop table if exists cats")
	res = db:query("create table cats (id serial primary key, name varchar(5))")
	util.dump(res,'create table cats')

	res = db:query("insert into cats (name) values (\'Bob\'),(\'\'),(null)")
	util.dump(res,'insert into cats')

	res = db:query("select * from cats order by id asc")
	util.dump(res,'select * from cats')
	-- multiresultset test
	res = db:query("select * from cats order by id asc ; select * from cats")
	util.dump(res,'multiresultset result')

	print ("escape string test result=", mysql.quote_sql_str([[\mysql escape %string test'test"]]) )

	-- bad sql statement
	local res =  db:query("select * from notexisttable" )
	util.dump(res,'bad query result')
end

function command.GET(key)
	return db:get(key)
end

function command.SET(key, value)
	local last = db:get(key)
	db:set(key, value)
	return last
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register ".store_mysql"
	command.init()
end)
