---@diagnostic disable: undefined-field

peripheral.find("modem", rednet.open)

local args = { ... }
local url = args[1]

local webhook = require("webhook")
local hook = webhook:createWebhook(url, "Turtle Relay")

local received = {}

local lastReceived = os.epoch("local") / 1000

local function Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function listen()
    while true do
        local id, message = rednet.receive()
        local args = Split(message, "/")

        if args[1] == "Relay" then
            lastReceived = os.epoch("local") / 1000

            table.insert(received, args[2] .. "/" .. args[3])
        end
    end
end

local function clear()
    while true do
        if (os.epoch("local") / 1000) - lastReceived > 0.3 and #received > 0 then
            -- make a embed and send it to the url
            local embed = hook:createEmbed("Turtle Info")

            for i, unsplit in pairs(received) do
                local args = Split(unsplit, "/")

                received[i] = args
            end

            table.sort(received, function(a, b)
                if tonumber(a[1]) < tonumber(b[1]) then
                    return true
                end
            end)

            for i, t in pairs(received) do
                embed:addField(t[1], t[2], true)
            end

            hook:sendEmbed(embed)

            hook.createdEmbeds = {}
            received = {}
        else
            sleep()
        end
    end
end

parallel.waitForAny(listen, clear)
