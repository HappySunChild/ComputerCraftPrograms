local mod = require("mod")
local w, h = term.getSize()

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local function printCenter(y, text, color, slow, rate)
    if color then
        if colors[color] then
            term.setTextColor(color)
        else
            term.setTextColor(colors[color])
        end
    else
        term.setTextColor(colors.white)
    end

    if not slow then
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        term.write(text)
    else
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        textutils.slowWrite(text, rate or 7)
    end
end

local function prompt(text)
    term.write(text)
    return read()
end

clear()

local mainMenu = {
    { "LOG IN" },
    { "COMMAND" },
    { "SHUTDOWN" },
    { "UPDATE" },
    { "UNINSTALL" }
}

local active = true

while active do
    mod.optionSelect(mainMenu, 0, true, function(selected, element)
        local option = element[1] or selected

        if option == "LOG IN" then
            clear()
            local user = prompt("Enter User: ")

            if user then
                print("Thank you for logging in!")

                sleep(1)

                clear()
            end
        elseif option == "SHUTDOWN" then
            active = false

            os.shutdown()
        elseif option == "COMMAND" then
            active = false

            shell.run("os/programs/command")
        elseif option == "UPDATE" then
            active = false

            mod.clear()

            shell.run("os/programs/boot update")
            shell.run("reboot")
        elseif option == "UNINSTALL" then
            active = false

            mod.clear()

            fs.delete("os")
            fs.delete("startup.lua")
            fs.delete("back")
        end
    end)
end
