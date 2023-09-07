-- Controller startup.lua

local ui = require("UI")
rednet.open("back")

local modes = {
	{ "Terminal", colors.cyan },
	{ "Keyboard", colors.green },
	{ "Presets",  colors.blue },
	{ "Turtles",  colors.lightBlue }
}

local presets = {
	{ { "MINER", colors.cyan, 3 },				{ "BRIDGE", colors.blue, 19 } },
	{ { "SHUTDOWN", colors.red, 3 },			{ "REBOOT", colors.green, 19 } },
	{ { "UPDATE TURTLES", colors.lightBlue, 3 } }
}

local statusColors = {
	["Idle"] = colors.blue,
	["Offline"] = colors.gray,
	["Mining"] = colors.lightGray,
	["Bridging"] = colors.lightBlue,
	["Refueling"] = colors.yellow,
	["Updating"] = colors.orange,
	["Rebooting"] = colors.lime,
	["Dancing"] = colors.magenta
}

local keymapping = {
	w = { command = "go forward", position = { x = 13, y = 9 } },
	a = { command = "go left", position = { x = 11, y = 10 } },
	s = { command = "go back", position = { x = 13, y = 10 } },
	d = { command = "go right", position = { x = 15, y = 10 } },
	e = { command = "go up", position = { x = 15, y = 9 } },
	q = { command = "go down", position = { x = 11, y = 9 } },
	r = { command = "dig up", position = { x = 17, y = 9 } },
	f = { command = "dig", position = { x = 17, y = 10 } },
	v = { command = "dig down", position = { x = 17, y = 11 } }
}

local turtles = {}

local function split(str, sep)
	sep = sep or "%s"

	local splitted = {}

	for s in string.gmatch(str, string.format("([^%s]+)", sep)) do
		table.insert(splitted, s)
	end

	return splitted
end

local function main()
	while true do
		term.clear()

		ui.list(modes, "Mode Select", true, function(selected)
			if selected == 1 then
				term.clear()

				ui.printCenter(1, "Terminal", colors.cyan)
				ui.printCenter(2, "Type `exit` to return.", colors.blue)

				local history = {}

				repeat
					term.setTextColor(colors.yellow)
					term.setCursorPos(1, 4)
					term.clearLine()
					term.write("> ")

					local input = read()
					table.insert(history, 1, input)

					rednet.broadcast(input, "TurtleCommand")

					term.setCursorPos(1, 6)

					term.setTextColor(colors.lightBlue)
					term.write("History")

					term.setTextColor(colors.red)
					for i, command in pairs(history) do
						term.setCursorPos(1, 7 + i)
						term.clearLine()

						term.write(command)
					end
				until input == "exit"
			elseif selected == 2 then
				term.clear()

				ui.printCenter(1, "Keyboard", colors.green)
				ui.printCenter(2, "Press `x` to return.", colors.blue)

				for k, data in pairs(keymapping) do
					ui.printAt(data.position.x, data.position.y, string.upper(k), colors.red)
				end

				while true do
					local _, keycode, held = os.pullEvent("key")
					local key = keys.getName(keycode)

					if key == "x" then
						break
					end

					if keymapping[key] then
						if held == false then
							local data = keymapping[key]

							ui.printAt(data.position.x, data.position.y, string.upper(key), colors.lime)
						end

						local function send()
							while true do
								rednet.broadcast(keymapping[key].command, "TurtleCommand")

								sleep(0.5)
							end
						end

						local function waitForKeyUp()
							repeat
								local _, upkey = os.pullEvent("key_up")
							until upkey == keycode

							local data = keymapping[key]

							ui.printAt(data.position.x, data.position.y, string.upper(key), colors.red)
						end

						parallel.waitForAny(waitForKeyUp, send)
					end
				end
			elseif selected == 3 then
				ui.interface(presets, "Presets", false, function(selected)
					if selected.x == 1 and selected.y == 1 then -- Miner
						term.clear()
						term.setCursorPos(1, 1)

						local xs, ys, zs = ui.prompt("X Size: "), ui.prompt("Y Size: "), ui.prompt("Z Size: ")

						term.setTextColor(colors.cyan)

						print(string.format("\nDigging an area of %s by %s by %s will take %s fuel.\n\n", xs, ys, zs,
							xs * ys * zs))

						term.setTextColor(colors.red)
						print("Press any key to return.")

						rednet.broadcast(string.format("miner %s %s %s", xs, ys, zs), "TurtleCommand")

						os.pullEvent("key")
					elseif selected.x == 2 and selected.y == 1 then -- Bridge
						term.clear()
						term.setCursorPos(1, 1)

						local distance = ui.prompt("Distance: ")

						term.setTextColor(colors.cyan)

						print(string.format("\nBridging a distance of %s and back will take %s fuel.\n\n", distance,
							distance * 2))

						term.setTextColor(colors.red)
						print("Press any key to return.")

						rednet.broadcast(string.format("bridge %s", distance), "TurtleCommand")

						os.pullEvent("key")
					elseif selected.x == 1 and selected.y == 2 then -- Shutdown
						rednet.broadcast("shutdown", "TurtleCommand")
					elseif selected.x == 2 and selected.y == 2 then -- Reboot
						rednet.broadcast("reboot", "TurtleCommand")
					elseif selected.x == 1 and selected.y == 3 then -- Update
						rednet.broadcast("update", "TurtleCommand")
					end
				end)
			elseif selected == 4 then
				local list = {}
				local tlist = {}

				if #turtles <= 0 then
					rednet.broadcast("Get", "TurtleStatus")

					sleep(0.1)
				end

				for _, t in pairs(turtles) do
					local color = statusColors[t.Status] or colors.brown

					table.insert(list, { string.format("%s: %s", t.Name, t.Status), color })
					table.insert(tlist, t)
				end

				ui.list(list, "Turtles", true, function(selected)
					local t = tlist[selected]

					rednet.send(t.Id, "info", "TurtleCommand")

					sleep(0.1)

					term.clear()
					term.setCursorPos(1, 1)

					ui.printCenter(1, t.Name, statusColors[t.Status])
					ui.printCenter(2, "Press any key to exit.", colors.red)
					ui.printCenter(5, string.format("Max Fuel: %s", t.Info.FuelMax), colors.lime)
					ui.printCenter(6, string.format("Fuel: %s", t.Info.Fuel), colors.green)

					os.pullEvent("key")
				end)
			end
		end)

		os.sleep(0.1)
	end
end

local function status()
	while true do
		local id, message = rednet.receive("TurtleStatus")
		local args = split(message, "\\")

		local command = args[1]

		if command ~= "Startup" and not turtles[id] then
			rednet.send(id, "Get", "TurtleStatus")
			sleep(0.1)
		end

		if command == "Startup" then -- add turtle
			local newTurtle = {}
			newTurtle.Name = args[2]
			newTurtle.Status = args[3]
			newTurtle.Id = id
			newTurtle.Info = {}

			turtles[id] = newTurtle
		end

		if turtles[id] then
			if command == "StatusSet" then
				turtles[id].Status = args[2]
			elseif command == "Info" then
				local t = turtles[id]
				t.Info.Fuel = args[2]
				t.Info.FuelMax = args[3]
			end
		end
	end
end

parallel.waitForAny(main, status)
