local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local sqlite3 = require "lsqlite3"
local util = require "util"
local db = nil

local util = require 'util'

local command = {}

function command.test()

	print("sqlite3.complete",sqlite3.complete)
	print("sqlite3.lversion",sqlite3.lversion())
	--db = sqlite3.open_memory()
	db = sqlite3.open(skynet.getenv("SQLITE_DB_FILE"))
	local hastable=false
	for row in db:nrows("SELECT count(*) AS numb FROM sqlite_master WHERE type='table' AND name='test'") do
		if(row.numb>0) then
			hastable = true
		end
	end
	print("db: rows------------------------")
	for row in db:rows("SELECT * FROM user") do
		print(row[1], row[2],row[3],row[4])
	end
	print("db: nrows------------------------")
	for row in db:nrows("SELECT * FROM user") do
		print(row.id, row.name,row.age,row.intro)
	end
	print("db: urows------------------------")
	for id,name,age,intro in db:urows("SELECT * FROM user") do
		print(id, name,age,intro)
	end
end
function command.init()
	skynet.error("sqlite3.complete",sqlite3.complete)
	skynet.error("sqlite3.lversion",sqlite3.lversion())
	--db = sqlite3.open_memory()
	db = sqlite3.open(skynet.getenv("SQLITE_DB_FILE"))
	local hastable=false
	for row in db:nrows("SELECT count(*) AS numb FROM sqlite_master WHERE type='table' AND name='user'") do
		if(row.numb>0) then
			hastable = true
		end
	end
	skynet.error("sqlite3.hastable",hastable)
	if(not hastable) then
		db:exec[[
			PRAGMA foreign_keys = false;

			-- ----------------------------
			--  Table structure for room
			-- ----------------------------
			DROP TABLE IF EXISTS "room";
			CREATE TABLE "room" (
				 "id" integer(4,0) NOT NULL,
				 "owner" integer(4,0) NOT NULL,
				 "args" TEXT,
				 "jushu" integer(4,0),
				PRIMARY KEY("id")
			);

			-- ----------------------------
			--  Table structure for user
			-- ----------------------------
			DROP TABLE IF EXISTS "user";
			CREATE TABLE "user" (
				 "id" INTEGER(4,0),
				 "openid" text,
				 "name" text,
				 "gender" integer,
				 "headimg" TEXT,
				 "platform" text,
				 "os" text,
				 "device" text,
				 "uuid" text,
				 "createtime" integer(4,0),
				PRIMARY KEY("id")
			);

			PRAGMA foreign_keys = true;
		]]
	end
	-- db:exec[[
	-- DELETE FROM user WHERE name like '%en';
	-- INSERT INTO user VALUES (NULL, 'King',22,'Hello King');
	-- ]]
	-- print("db: rows------------------------")
	-- for row in db:rows("SELECT * FROM user") do
	-- 	print(row[1], row[2],row[3],row[4])
	-- end
	-- print("db: nrows------------------------")
	-- for row in db:nrows("SELECT * FROM user") do
	-- 	print(row.id, row.name,row.age,row.intro)
	-- end
	-- print("db: urows------------------------")
	-- for id,name,age,intro in db:urows("SELECT * FROM user") do
	-- 	print(id, name,age,intro)
	-- end
end

function command.get_user(user)
	local sql
	if(user.id) then
		sql = string.format("SELECT * FROM user WHERE id='%d'",user.id)
	elseif(user.openid) then
		sql = string.format("SELECT * FROM user WHERE openid='%s'",user.openid)
	end
	if(sql) then
		for row in db:nrows(sql) do
			skynet.error("get_user succ",row.id,row.name)
			return row
		end
	end
	return 
end

local stmt_newuser
local sql = "INSERT INTO user VALUES (NULL, :openid, :name, :gender, :headimg, :platform, :os, :device, :uuid, :createtime)"
function command.new_user(user)
	skynet.error("new_user ",user.openid,user.name)
	stmt_newuser = stmt_newuser or db:prepare(sql)
	stmt_newuser:bind_names{ 
		openid = user.openid,  
		name = user.name,
		gender = user.gender,
		headimg = user.headimg,
		platform = user.platform,
		os = user.os,
		device = user.device,
		uuid = user.uuid,
		createtime = os.time(),
	}
	stmt_newuser:step()
	stmt_newuser:reset()
	return command.get_user(user)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register ".store_sqlite"
	command.init()
end)
