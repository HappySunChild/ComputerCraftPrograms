local args = { ... }

local method = args[1]

local w, h = term.getSize()
local mod = require("os.mod")

local function printCenter(y, text, slow)
    if not slow then
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        term.write(text)
    else
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        textutils.slowPrint(text, 7)
    end
end

if method == nil then
    if not fs.exists("os") then
        mod.install()

        if fs.exists("boot") then
            fs.move("boot", "os/boot")
        end
    end

    term.clear()
    term.setCursorPos(1, 1)

    printCenter(2, "Loading SPHERE-OS")
    printCenter(3, "--------")
    sleep(0.1)
    printCenter(3, "########", true)

    sleep(1)

    printCenter(5, "LOADING COMPLETE")

    sleep(2.85)

    shell.run("os/programs/main")
elseif method == "update" then
    fs.delete("os")

    mod.install()

    shell.run("reboot")
end
