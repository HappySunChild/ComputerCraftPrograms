---@diagnostic disable: undefined-field
local VERSION = 1.20

peripheral.find("modem", rednet.open)

local neighbor = peripheral.find("turtle")

if neighbor then
    neighbor.turnOn()
end

local programs = {
    ["Tunnel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/tunnel.lua",
    ["Refuel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/lavarefuel.lua",
    ["Bridge.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/bridge.lua",
    ["Miner.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/miner.lua",
    ["receiver.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/main.lua",
    ["webhook"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/modules/webhook.lua"
}

local function DownloadPrograms(update)
    for program, url in pairs(programs) do
        if update then
            if fs.exists(program) then
                fs.delete(program)
            end
        end

        if not fs.exists(program) then
            shell.run(string.format("wget %s %s", url, program))
        end
    end

    if not fs.exists("webhook") then
        DownloadPrograms()
    end
end

DownloadPrograms(false)

local webhook = require("webhook")
local url = webhook:getUrlFromFile("saved.url")
local hook

if url then
    hook = webhook:createWebhook(url, os.getComputerLabel())
end

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

local function SendFeedback(feedback)
    if url and hook then -- check if there is a webhook/url
        hook:sendMessage(feedback)
    else -- if there isnt then just broadcast the feedback
        rednet.broadcast(os.getComputerLabel() .. "/" .. feedback)
    end
end

local function RunProgram(program, args)
    shell.run(program, table.unpack(args))
end

SendFeedback("Running receiver V" .. VERSION)

while true do
    local id, message, _ = rednet.receive()

    local args = Split(message)
    local command = args[1]

    table.remove(args, 1)

    if command == "go" then
        RunProgram("go", args)
    elseif command == "dig" then
        local location = args[1]

        if location == "up" then
            turtle.placeUp()
        elseif location == "down" then
            turtle.placeDown()
        else
            turtle.place()
        end
    elseif command == "miner" then
        RunProgram("Miner.lua", args)
    elseif command == "tunnel" then
        RunProgram("Tunnel.lua", args)
    elseif command == "bridge" then
        RunProgram("Bridge.lua", args)
    elseif command == "refuel" then
        SendFeedback("Refueling...")
        RunProgram("Refuel.lua", args)
    elseif command == "update" then
        SendFeedback("Updating...")
        DownloadPrograms(true)
        os.reboot()
    elseif command == "reboot" then
        SendFeedback("Rebooting...")
        os.reboot()
    elseif command == "shutdown" then
        os.shutdown()
    elseif command == "dance" then
        SendFeedback("Prepare to get down.")
        shell.run("dance")
    elseif command == "select" then
        turtle.select(tonumber(args[1]) or 1)
    elseif command == "url" then
        url = args[1]

        if url then
            hook = webhook:createWebhook(url, os.getComputerLabel())
        end

        local success = webhook:saveUrlToFile(url, "saved.url")

        if success then
            SendFeedback("Created `saved.url` file")
        else
            SendFeedback(string.format("There was an error in saving the url! Extra info; URL: %s", url))
        end
    elseif command == "drop" then
        turtle.drop()
    elseif command == "return" then
        local stat = args[1]

        if stat == "fuel" then
            SendFeedback(string.format("Current fuel level: %s.", turtle.getFuelLevel()))
        elseif stat == "version" then
            SendFeedback(string.format("Current receiver version: %s", VERSION))
        end
    end
end
