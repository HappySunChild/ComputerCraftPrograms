-- probably will go into a disk

if disk.isPresent("top") then
    if fs.exists("startup.lua") then
        fs.delete("startup.lua")
    end

    fs.copy("disk/startup.lua", "startup.lua")
end

if not fs.exists("receiver.lua") then
    shell.run("wget https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/main.lua receiver.lua")
end

term.clear()
term.setCursorPos(1, 1)

print("Running Receiver\n------------------------------")

shell.run("receiver.lua")
