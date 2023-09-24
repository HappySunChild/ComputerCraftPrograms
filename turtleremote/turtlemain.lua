-- Turtle main.lua

local version = 1.4
local controllerId = -1

local neighbor = peripheral.find("turtle")

if neighbor then
	neighbor.turnOn()
end

local programs = {
	["miner.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/miner.lua",
	["bridge.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/bridge.lua",
	["refuel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/refuel.lua",
	["tunnel.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/programs/tunnel.lua",
	["main.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/turtlemain.lua"
}

local function updateStatus(status)
	if controllerId == -1 then
		print("no controller id")
		
		return
	end
	
	local currentFuel = turtle.getFuelLevel()
	local fuelLimit = turtle.getFuelLimit()
	
	local dataString = string.format("%s\\%s\\%d\\%d", os.getComputerLabel(), status, currentFuel, fuelLimit)
	
	rednet.send(controllerId, dataString, "tStatus")
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
	run = function (args)
		local program = args[1]
		
		if (program) then
			table.remove(args, 1)
			
			runProgram(program, args)
		end
	end,
	pastebin = function (args)
		updateStatus("Pastebin")
		
		local id = args[1]
		
		if (id) then
			runProgram("pastebin run", args)
		end
	end,
	update = function ()
		updateStatus("Updating")
		
		downloadPrograms(true)
		
		os.reboot()
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
		updateStatus("Idle")
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

local function getController() -- yields
	rednet.broadcast("get", "controllerRequest")
	
	local id, message = rednet.receive("controllerResponse")
	
	if message == "success" then -- "password"
		print("controller found!")
		
		controllerId = id
		
		return true
	else
		print("invalid password")
		
		getController()
	end
end

downloadPrograms()

local function main()
	peripheral.find("modem", rednet.open)
	
	print(version)
	print("\nwaiting for controller...")
	
	getController() -- waits for controller to respond
	
	while (true) do
		local id, message, protocol = rednet.receive()
		
		if id == controllerId then
			updateStatus("Idle")
			
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
end

main()
