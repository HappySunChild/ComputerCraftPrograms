-- Turtle main.lua

peripheral.find("modem", rednet.open)

local neighbor = peripheral.find("turtle")

if neighbor then
	neighbor.turnOn()
end

local programs = {
	["miner.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/miner.lua",
	["bridge.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/bridge.lua",
	["refuel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/refuel.lua",
	["tunnel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/tunnel.lua",
}

local function broadcastStatus(status)
	local currentFuel = turtle.getFuelLevel()
	local fuelLimit = turtle.getFuelLimit()
	
	local dataString = string.format("%s\\%s\\%d\\%d", os.getComputerLabel(), status, currentFuel, fuelLimit)
	
	rednet.broadcast(dataString, "tStatus")
end

local function runProgram(program, args)
	local path = fs.combine("programs", program)
	
	if (fs.exists(path)) then
		shell.run(path, table.unpack(args or {}))
	else
		shell.run(program, table.unpack(args or {}))
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

local handlers = {
	forward = function ()
		repeat
			turtle.dig()
		until (turtle.forward())
	end,
	back = function ()
		if (not turtle.back()) then
			turtle.turnRight()
			turtle.turnRight()
			
			repeat
				turtle.dig()
			until (turtle.forward())
			
			turtle.turnLeft()
			turtle.turnLeft()
		end
	end,
	up = function ()
		repeat
			turtle.digUp()
		until (turtle.up())
	end,
	down = function ()
		repeat
			turtle.digDown()
		until (turtle.down())
	end,
	left = turtle.turnLeft,
	right = turtle.turnRight
}

local actions = {
	miner = function (args)
		broadcastStatus("Mining")
		
		runProgram("miner.lua", args)
	end,
	tunnel = function (args)
		broadcastStatus("Tunneling")
		
		runProgram("tunnel.lua", args)
	end,
	bridge = function (args)
		broadcastStatus("Bridging")
		
		runProgram("bridge.lua", args)
	end,
	refuel = function (args)
		broadcastStatus("Refueling")
		
		runProgram("refuel.lua", args)
	end,
	update = function ()
		broadcastStatus("Updating")
		
		downloadPrograms(true)
		
		os.reboot()
	end,
	dance = function ()
		broadcastStatus("Dancing")
		
		runProgram("dance")
	end,
	go = function (args)
		local n = 1
		
		while (n <= #args) do
			local action, distance = args[n], 1
			
			if (n < #args) then
				local value = tonumber(args[n + 1])
				
				if (value) then
					distance = value
					n = n + 1
				end
			end
			
			local handler = handlers[string.lower(action)]
			
			if (handler) then
				while (distance > 0) do
					local success, err = pcall(handler)
					
					if success then
						distance = distance - 1
					else
						print(err)
					end
				end
			end
			
			n = n + 1
		end
	end,
	dig = function (args)
		local direction = args[1]
		
		if (direction == "down") then
			turtle.digDown()
		elseif (direction == "up") then
			turtle.digUp()
		else
			turtle.dig()
		end
	end,
	ping = function ()
		broadcastStatus("Idle")
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
	while (true) do
		broadcastStatus("Idle")
		
		local id, message, protocol = rednet.receive()
		
		if protocol == "tCommand" then
			local args = split(message)

			local action = args[1]
			table.remove(args, 1)
			
			local callback = actions[action]
			
			if callback then
				local success, err = pcall(callback, args)
				
				if (not success) then
					print("Unable to perform action.")
					print(err)
				end
			end
		elseif protocol == "ping" then
			rednet.send(id, "Pong", "pong")
		end
	end
end

local function terminate()
	while (true) do
		local event = os.pullEventRaw("terminate")
		
		if event == "terminate" then
			broadcastStatus("Offline")
		end
	end
end

parallel.waitForAny(terminate, main)
