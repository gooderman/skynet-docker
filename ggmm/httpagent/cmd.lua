local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local M = {}

function M.login(data)
    return {cmd='login',desc="succ"}
end
function M.check(data)
    return {cmd='check',desc="succ"}
end
function M.quit(data)
    return {cmd='quit',desc="succ"}
end

return M

