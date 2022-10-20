-- this is the one you should download because it will download the main program and will automatically run it

if not fs.exists("reciever.lua") then
    shell.run("wget https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/remote/main.lua reciever.lua")
end

term.clear()
term.setCursorPos(1, 1)

print("Running Reciever\n------------------------------")

shell.run("reciever.lua")
