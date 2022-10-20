-- this will go into a pocket or normal computer

peripheral.find("modem", rednet.open)

local w, h = term.getSize()

local currentMode = false
local modes = {
    [false] = "keys",
    [true] = "write"
}

local keymap = {
    ["w"] = "go forward",
    ["a"] = "go left",
    ["s"] = "go back",
    ["d"] = "go right",
    ["e"] = "go up",
    ["q"] = "go down",
    ["f"] = "dig",
    ["r"] = "dig up",
    ["v"] = "dig down",
    ["z"] = "drop"
}

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local function switchMode()
    currentMode = not currentMode

    clear()

    print("Switched modes to " .. tostring(modes[currentMode]))
end

clear()

while true do
    local event, keycode = os.pullEvent("key_up")
    local key = keys.getName(keycode)

    if currentMode then
        term.write("Broadcast: ")
        local input = read()

        if input == "t" then
            switchMode()
        end

        rednet.broadcast(input)
    else
        local broadcast = keymap[key]

        rednet.broadcast(broadcast)
        print("Broadcasting key: " .. key)
    end

    if key == "t" then
        switchMode()
    end
end
