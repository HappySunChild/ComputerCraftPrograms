peripheral.find("modem", rednet.open)

local neighbor = peripheral.find("turtle")

if neighbor then
    neighbor.turnOn()
end

local programs = {
    ["Miner.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/miner.lua",
    ["Bridge.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/bridge.lua",
    ["Refuel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/lavarefuel.lua",
    ["Tunnel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/tunnel.lua",
    ["main.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/main.lua"
}

local function DownloadPrograms(replace)
    for program, url in pairs(programs) do
        if replace then
            if fs.exists(program) then
                fs.delete(program)
            end
        end

        if not fs.exists(program) then
            shell.run(string.format("wget %s %s", url, program))
        end
    end
end

local function Split(str, sep)
    sep = sep or "%s"

    local splitted = {}

    for s in string.gmatch(str, string.format("([^%s]+)", sep)) do
        table.insert(splitted, s)
    end

    return splitted
end

local function UpdateStatus(status)
    rednet.broadcast(string.format("StatusSet\\%s", status), "TurtleStatus")
end

local function RunProgram(program, args)
    shell.run(program, table.unpack(args))
end

DownloadPrograms()

rednet.broadcast(string.format("Startup\\%s\\Idle", os.getComputerLabel() or os.getComputerID()), "TurtleStatus")

local function main()
    while true do
        local id, message = rednet.receive("TurtleCommand")
        local args = Split(message)

        local cmd = args[1]

        table.remove(args, 1)

        UpdateStatus("Idle")

        if cmd == "go" then
            RunProgram("go", args)
        elseif cmd == "dig" then
            if args[1] == "up" then
                turtle.digUp()
            elseif args[1] == "down" then
                turtle.digDown()
            else
                turtle.dig()
            end
        elseif cmd == "miner" then
            RunProgram("Miner.lua", args)
        elseif cmd == "tunnel" then
            RunProgram("Tunnel.lua", args)
        elseif cmd == "bridge" then
            RunProgram("Bridge.lua")
        elseif cmd == "refuel" then
            UpdateStatus("Refueling")
            RunProgram("Refuel.lua")
        elseif cmd == "update" then
            UpdateStatus("Updating")
            DownloadPrograms(true)
            os.reboot()
        elseif cmd == "reboot" then
            UpdateStatus("Rebooting")
            os.reboot()
        elseif cmd == "shutdown" then
            UpdateStatus("Offline")
            os.shutdown()
        elseif cmd == "dance" then
            UpdateStatus("Dancing")
            RunProgram("dance", args)
        elseif cmd == "info" then
            rednet.send(id, string.format("Info\\%s\\%s", turtle.getFuelLevel(), turtle.getFuelLimit()), "TurtleStatus")
        end
    end
end

local function listener()
    while true do
        local id, message = rednet.receive("TurtleStatus")

        if message == "Get" then
            rednet.send(id, string.format("Startup\\%s\\Idle", os.getComputerLabel() or os.getComputerID()),
            "TurtleStatus")
        end
    end
end

parallel.waitForAny(main, listener)
