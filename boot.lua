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

    local basePrograms = {
        [".boot"] = "https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/.boot.lua"
    }

    for program, url in pairs(basePrograms) do
        print(string.format("wget %s %s", url, program))
        shell.run(string.format("wget %s %s", url, program))
    end
end

if method == nil then
    if not fs.exists("os") then
        install()

        fs.move(".boot", "os/.boot")
    end

    term.clear()
    term.setCursorPos(1, 1)

    printCenter(2, "Loading SPHERE-OS")
    printCenter(3, "--------")
    sleep(0.1)
    printCenter(3, "########", true)

    shell.run("os/.main")
elseif method == "update" then
    fs.delete("os")

    install()

    shell.run("os/.boot")
end
