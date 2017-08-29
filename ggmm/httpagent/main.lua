local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local cjson = require "cjson"
local command = require "httpagent.cmd"
local util = require "util"

local function response(id, code, msg, ...)
    print("web返回")
    print(msg)
    local data = msg
    local ok, err = httpd.write_response(sockethelper.writefunc(id), code, data, ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        skynet.error(string.format("fd = %d, %s", id, err))
    end
end

local function handle(id)
    socket.start(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 128)
    skynet.error("httpd read",code, url, method,header,body)
    if not code or code ~= 200 then
        return
    end

    util.dump(header,"header")
    
    if url=='/login' then
    elseif url=='/check' then
    elseif url=='/quit' then
    end

    local rst={}
    if body and string.len(body)>0 then
        local req = cjson.decode(body)
        if(req and req.cmd and command[req.cmd]) then
            rst = command[req.cmd](req) or {}
            local str = cjson.encode(rst)
            response(id,200,str)
            return
        end
    end

    local tb = {}
    tb.msg='default ok'
    local str = cjson.encode(tb)
    response(id,200,str)
end

skynet.start(function()
    skynet.dispatch("lua", function (_,_,id)
        handle(id)
        socket.close(id)
        -- if not pcall(handle, id) then
        --    response(id, 200, "{\"msg\"=\"exception\"}")
        -- end
    end)
end)
