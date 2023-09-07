-- Turtle main.lua

peripheral.find("modem", rednet.open)

local neighbor = peripheral.find("turtle")

if neighbor then
	neighbor.turnOn()
end

local programs = {
	["miner.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/miner.lua",
	["bridge.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/bridge.lua",
	["refuel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/lavarefuel.lua",
	["tunnel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/tunnel.lua",
}

local function runProgram(program, args)
	local path = fs.combine("programs", program)
	
	if (fs.exists(path)) then
		shell.run(path, table.unpack(args))
	else
		shell.run(path, table.unpack(args))
	end
end

local function downloadPrograms(replace)
	for name, url in pairs(programs) do
		local path = fs.combine("programs", name)
		
		if (replace and fs.exists(path)) then
			fs.delete(path)
		end

		if not (fs.exists(path)) then
			shell.run("wget", url, path)
		end
	end
end

local actions = {
	miner = function (args)
		runProgram("miner.lua", args)
	end,
	tunnel = function (args)
		runProgram("tunnel.lua", args)
	end,
	bridge = function (args)
		runProgram("bridge.lua", args)
	end,
	refuel = function (args)
		runProgram("refuel.lua", args)
	end,
	update = function ()
		downloadPrograms(true)
		
		os.reboot()
	end,
	dance = function ()
		runProgram("dance")
	end,
	reboot = os.reboot,
	shutdown = os.shutdown,
}

local function split(str, sep)
	sep = sep or "%s"
	
	local splitted = {}
	
	for s in string.gmatch(str, string.format("([^%s]+)", sep)) do
		table.insert(splitted, s)
	end
	
	return splitted
end

downloadPrograms()

local function main()
	while true do
		local id, message = rednet.receive("tCommand")
		local args = split(message)

		local action = args[1]
		table.remove(args, 1)
		
		local callback = actions[action]
		
		if callback then
			xpcall(callback, warn, args)
		end
	end
end

main()
