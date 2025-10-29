--[[
    A handler module to process send test email requests

    Copyright (C) 2023 Casa Systems Inc.
--]]
local turbo = require("turbo")
local SessionRequestHandler = require("session_handler")

local email_text="\"\
*** This is an automatically generated email, please do not reply ***\
\
Hello,\
\
Please note that this is a test email.\
\
Regards,\
\
Your Lantronix Industrial IoT Gateway\
\""
local email_type="\"Email server settings test.\""

local SendTestEmailHandler = class("SendTestEmailHandler", SessionRequestHandler)

function SendTestEmailHandler:post(url)
    turbo.log.debug('SendTestEmailHandler:post('..url..')')
    local recipient = self:get_argument("recipient")
    local server = self:get_argument("server")
    local port = self:get_argument("port")
    local username = self:get_argument("username")
    local password = self:get_argument("password")
    local security = self:get_argument("security")
    local useauth = self:get_argument("useauth")
    if recipient == '' or server == '' or port == '' or security == '' then
        error(turbo.web.HTTPError(400, "Bad request"))
    end
    -- add '' to escape special characters
    recipient = string.gsub(recipient, "'", "'\\''")
    server = string.gsub(server, "'", "'\\''")
    port = string.gsub(port, "'", "'\\''")
    username = string.gsub(username, "'", "'\\''")
    password = string.gsub(password, "'", "'\\''")
    security = string.gsub(security, "'", "'\\''")
    useauth = string.gsub(useauth, "'", "'\\''")
    local cmd
    local common_parms = " -s '" .. security .. "' -a '" .. server .. "' -p '" .. port .. "' '" ..  recipient .. "' '" .. email_text .. "' '" .. email_type .. "'"
    if useauth == "0" then
        cmd = "/usr/bin/send_email.sh" ..  " -x" .. common_parms
    else
        cmd = "/usr/bin/send_email.sh" .. " -u '" .. username .. "' -w '" .. password .. "'" .. common_parms
    end
    local response = {result="0"}
    local res = os.execute(cmd)
    response.result = res/256 == 1 and 0 or 1
    self:write(response)
end

-----------------------------------------------------------------------------------------------------------------------
-- Module configuration
-----------------------------------------------------------------------------------------------------------------------
local module = {}
function module.init(handlers)
    table.insert(handlers, {"^/(EmailClientTestCfg)/send_test_email(.*)$", SendTestEmailHandler})
end

return module
