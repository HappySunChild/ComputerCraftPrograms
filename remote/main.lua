---@diagnostic disable: undefined-field
local VERSION = 1.21

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

local function GetRelayIdFromFile(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local id = file.readAll()
        file.close()

        if id then
            return id
        end
    end

    return nil
end

local function SetRelayIdToFile(id, path)
    if fs.exists(path) then
        local file = fs.open(path, "w")
        file.write(id)
        file.close()

        return true
    end

    return false
end

local relayID = GetRelayIdFromFile("relay.save")

local function SendFeedback(feedback)
    local message = string.format("Relay/%s/%s", os.getComputerLabel(), feedback)

    if relayID then
        rednet.send(relayID, message)
    else
        rednet.broadcast(message)
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
            turtle.digUp()
        elseif location == "down" then
            turtle.digDown()
        else
            turtle.dig()
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
    elseif command == "drop" then
        turtle.drop()
    elseif command == "return" then
        local stat = args[1]

        if stat == "fuel" then
            SendFeedback(string.format("Current fuel level: %s.", turtle.getFuelLevel()))
        elseif stat == "version" then
            SendFeedback(string.format("Current receiver version: %s", VERSION))
        end
    elseif command == "relay" then
        local id = args[1]

        if id then
            relayID = id
            SetRelayIdToFile(id, "relay.save")
        end
    end
end
