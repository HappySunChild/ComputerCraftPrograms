local args = { ... }

local method = args[1]

local w, h = term.getSize()

local function printCenter(y, text, slow)
    if not slow then
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        term.write(text)
    else
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        textutils.slowPrint(text, 7)
    end
end

local function install()
    fs.makeDir("os")
    fs.makeDir("os/programs")

    local programs = {
        ["os/programs/boot"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/boot.lua",
        ["os/programs/main"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/main.lua",
        ["startup.lua"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/startup.lua"
    }

    for program, url in pairs(programs) do
        if fs.exists(program) then
            fs.delete(program)
        end

        shell.run(string.format("wget %s %s", url, program))
    end
end

if method == nil then
    if not fs.exists("os") then
        install()

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

    sleep(0.1)

    printCenter(5, "LOADING COMPLETE")

    sleep(0.3)

    shell.run("os/programs/main")
elseif method == "update" then
    fs.delete("os")

    install()

    shell.run("os/.boot")
end
