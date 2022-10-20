-- probably will go into a disk

if disk.isPresent("top") then
    fs.copy("disk/startup.lua", "startup.lua")
end

if not fs.exists("reciever.lua") then
    shell.run("wget https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/main.lua reciever.lua")
end

term.clear()
term.setCursorPos(1, 1)

print("Running Reciever\n------------------------------")

shell.run("reciever.lua")
