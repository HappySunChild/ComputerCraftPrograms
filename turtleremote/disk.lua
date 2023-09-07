term.clear()
term.setCursorPos(1, 1)

local function delete(file)
	if fs.exists(file) then
		local success = pcall(fs.delete, file)
		
		if success then
			print(string.format("Removed file; %s", file))
		end
	end
end

if disk.isPresent("top") then
	delete("startup.lua")
	delete("main.lua")
	
	fs.copy("disk/startup.lua", "startup.lua")
	
	print("Copying `startup.lua` from disk.")
end

if not fs.exists("main.lua") then
	print("Missing `main.lua`. Downloading...")
	
	shell.run("wget https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/turtleremote/turtlemain.lua main.lua")
end

print("Running Main\n---------------------------------------")

if fs.exists("main.lua") then
	shell.run("main.lua")
else
	print("Download failed! Rebooting...")
	
	sleep(2.5)
	
	os.reboot()
end
