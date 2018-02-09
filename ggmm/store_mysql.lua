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
		local res = db:query("set charset utf8mb4 ; SET GLOBAL time_zone = '+8:00'");
		util.dump(res,'mysql on_connect')
	end
}

local command = {}

function command.init()

	db=mysql.connect(conf)

	if not db then
		skynet.error("mysql failed to connect")
		return
	end
	skynet.error("mysql success to connect to server")
	
	local res
	res = db:query("drop table if exists user; drop table if exists record")
	util.dump(res,'mysql init drop table user record')
	
	local sql_create_user =[[
		create table if not exists user(
			id int not null primary key auto_increment,
			openid varchar(128) not null,
			name varchar(128),
			gender int,
			headimg varchar(256),
			platform varchar(32),
			os varchar(16),
			device varchar(64),
			uuid varchar(64),
			createtime timestamp(4) default CURRENT_TIMESTAMP(4) not null,
			lastlogintime timestamp(4) default CURRENT_TIMESTAMP(4)
		)AUTO_INCREMENT = 100001;
	]]
	res = db:query(sql_create_user)
	util.dump(res,'mysql create table user')

	local sql_create_record =[[
		create table if not exists record(
			id int not null primary key auto_increment,
			roomid int not null,
			roomtype int not null,
			ownerid int not null,
			renshu int not null,
			jushu int not null,
			score varchar(256),
			proto  varchar(128),
			name varchar(64),
			time timestamp(4) default CURRENT_TIMESTAMP(4) not null
		)AUTO_INCREMENT = 100001;
	]]
	res = db:query(sql_create_record)
	util.dump(res,'mysql create table record')

	command.test()

end

function command.test()
	local users = {
		{
			openid = 'abc111',  
			name = 'Bob',
			gender = 1,
			headimg = "http://bing.cn",
			platform = 'android',
			os = 'android 6.0',
			device = 'sumsang s8',
			uuid = '111111'
		},
		{
			openid = 'abc112',  
			name = 'lisa',
			gender = 2,
			headimg = 'http://apple.com/cn',
			platform = 'ios',
			os = 'ios 10.0',
			device = 'iphone 6s',
			uuid = '111112'
		},
		{
			openid = 'abc113',  
			name = 'Jeep',
			gender = 1,
			headimg = 'http://bing.cn',
			platform = 'android',
			os = 'android 6.0',
			device = 'sumsang s8',
			uuid = '111113'
		}
	}

	command.new_user(users[1])
	command.new_user(users[2])
	command.new_user(users[3])

	local rec = {
		roomid = 100001,
		roomtype = 10,
		ownerid = 100002,
		renshu = 3,
		jushu = 4,
		score = '{id1:0,id2:100}',
		proto = '/record/100001_3.txt',
		name = '点胡麻将',
	}
	command.save_record(rec)
	local dd = command.get_record(100001,4)
	util.dump(dd,'get_record')
	
	-- users[1].name = 'bobbbbb'
	-- skynet.sleep(500)
	-- local uu = command.get_user(users[1])
	-- util.dump(uu)
	-- command.del_user_byid(100001)

	-- res = db:query("select * from user")
	-- util.dump(res,'select all user')

	-- command.del_alluser()

	-- res = db:query("select * from user")
	-- util.dump(res,'select all user')

	-- multiresultset test
	-- res = db:query("select * from user order by id asc ; select * from user")
	-- util.dump(res,'mysql multiresultset result')
	-- skynet.error("escape string test result=", mysql.quote_sql_str([[\mysql escape %string test'test"]]) )

	-- -- bad sql statement
	-- local res =  db:query("select * from notexisttable" )
	-- util.dump(res,'bad query result')
end

local sql_get_user_by_id = [[select *,UNIX_TIMESTAMP(createtime) as timestamp from user where id='%d']]
local sql_get_user_by_openid = [[select *,UNIX_TIMESTAMP(createtime) as timestamp from user where openid='%s']]
function command.get_user(user,noupd)
	local sql
	if(user.id) then
		sql = string.format(sql_get_user,user.id)
	elseif(user.openid) then
		sql = string.format(sql_get_user_by_openid,user.openid)
	end
	if(sql) then
		local data = db:query(sql)
		if(data and data[1]) then
			skynet.error("mysql get_user succ",data[1].id,data[1].name)
			if(not noupd) then
				command.upd_user(user)
			end
			--convert time
			data[1].createtime = math.floor(data[1].timestamp)
			data[1].timestamp = nil
			return data[1]
		end
	end
	return 
end

local sql_new_user = [[insert into user (openid,name,gender,headimg,platform,os,device,uuid) values ('%s','%s',%d,'%s','%s','%s','%s','%s')]]
function command.new_user(user)
	skynet.error("new_user ",user.openid,user.name)
	local sql = string.format(sql_new_user,
		user.openid,  
		user.name,
		user.gender,
		user.headimg,
		user.platform,
		user.os,
		user.device,
		user.uuid
	)
	local data = db:query(sql)
	util.dump(data,'mysql new_user')
	return command.get_user(user,true)
end


local sql_upd_user = [[update user set name='%s',gender='%d',headimg='%s',lastlogintime=NOW() where openid='%s']]
function command.upd_user(user)
	skynet.error("mysql upd_user ",user.openid,user.name)
	local sql = string.format(sql_upd_user,
		user.name,
		user.gender,
		user.headimg,
		user.openid
	)
	local data = db:query(sql)
	util.dump(data,'mysql upd_user')
	return true
end

local sql_del_all_user = [[delete from user]]
function command.del_alluser()
	skynet.error("mysql sql_del_all_user ")
	local sql = sql_del_all_user
	local data = db:query(sql)
	util.dump(data,'mysql sql_del_all_user')
	return true
end

local sql_del_user = [[delete from user where id='%d']]
function command.del_user_byid(id)
	skynet.error("mysql del_user_byid ")
	local sql = string.format(sql_del_user,id)
	local data = db:query(sql)
	util.dump(data,'mysql del_user_byid')
	return true
end

local sql_new_record = [[insert into record (roomid,roomtype,ownerid,renshu,jushu,score,proto,name) values (%d,%d,%d,%d,%d,'%s','%s','%s')]]
function command.new_record(data)
	skynet.error("mysql new_record ")
	local sql = string.format(sql_new_record,
		data.roomid,
		data.roomtype,
		data.ownerid,
		data.renshu,
		data.jushu,
		data.score,
		data.proto,
		data.name
	)
	local data = db:query(sql)
	util.dump(data,'mysql new_record')
	return true
end

function command.save_record(data)
	return command.new_record(data)
end

local sql_get_record = [[select * ,UNIX_TIMESTAMP(time) as timestamp from record where roomid=%d and jushu=%d]]
function command.get_record(roomid,jushu)
	skynet.error("mysql get_record ")
	local sql = string.format(sql_get_record,
		roomid,
		jushu
	)
	local data = db:query(sql)
	if(data and data[1]) then
		--convert time
		data[1].time = math.floor(data[1].timestamp)
		data[1].timestamp = nil
		return data[1]
	end
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
