---@diagnostic disable: undefined-field
rednet.open("back")

local vector2 = {}

vector2.new = function(x, y)
    local newVec = {}
    newVec.x = x
    newVec.y = y

    newVec.print = function()
        print(string.format("(%s,%s)", tostring(newVec.x), tostring(newVec.y)))
    end

    newVec.equals = function(vec)
        return ((newVec.x == vec.x) and (newVec.y == vec.y))
    end

    newVec.magnitude = function()
        return (math.sqrt((newVec.x ^ 2 + newVec.y ^ 2)))
    end

    return newVec
end

table.find = function(t, v)
    for i, o in pairs(t) do
        if o == v then
            return i, v
        end
    end

    return nil
end

local function promptInput(promptText, color)
    term.setTextColor(color or colors.yellow)
    term.write(promptText)
    return read()
end

local function printcenter(y, text, color)
    local x = math.floor((26 - string.len(text)) / 2)

    term.setTextColor(tonumber(color) or colors.white)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

local function printat(x, y, text, color)
    term.setTextColor(tonumber(color) or colors.white)
    term.setCursorPos(x, y)
    term.write(text)
end

local function listOptionSelect(list, default, yoff, toptext, topcolor, exitkey, breakOnSelect, callback, keycallback)
    printcenter(1, toptext, topcolor)

    if exitkey then
        printcenter(19, "press " .. exitkey .. " to exit.")
    end

    local currentSelected = math.min(default, #list) or 1
    local lastSelected = math.min(default, #list) or 1

    for i, element in pairs(list) do
        local text, color = element[1], element[2]

        printcenter(i + yoff, i == currentSelected and "> " .. text .. " <" or text,
            i == currentSelected and colors.white or color)
    end

    while true do
        local _, keycode = os.pullEvent("key")
        local key = keys.getName(keycode) or "null"

        lastSelected = currentSelected

        if key == "down" then
            currentSelected = currentSelected + 1

            if currentSelected > #list then
                currentSelected = 1
            end
        elseif key == "up" then
            currentSelected = currentSelected - 1

            if currentSelected < 1 then
                currentSelected = #list
            end
        end

        if key == "down" or key == "up" then
            local currentElement = list[currentSelected]
            local lastElement = list[lastSelected]
            if lastElement and currentElement then
                local cname, _ = currentElement[1], currentElement[2]
                local lname, lcolor = lastElement[1], lastElement[2]

                printcenter(currentSelected + yoff, "> " .. cname .. " <", colors.white)
                printcenter(lastSelected + yoff, lname, lcolor)
            end
        end

        if key == "enter" then
            callback(currentSelected, list[currentSelected])

            if breakOnSelect then
                break
            end
        end

        if key == exitkey then
            term.clear()
            break
        end

        if keycallback then
            pcall(keycallback, key)
        end
    end
end

local function interfaceOptionsSelect(options, default, yoff, toptext, topcolor, exitkey, breakOnSelect, callback)
    printcenter(1, toptext, topcolor)

    if exitkey then
        printcenter(19, "Press " .. exitkey .. " to exit.", colors.white)
    end

    local currentSelected = default or vector2.new(1, 1)
    local lastSelected = vector2.new(1, 1)

    for y, elements in pairs(options) do
        for x, element in pairs(elements) do
            local currentElement = vector2.new(x, y)

            printat((currentElement.x == default.x and currentElement.y == default.y) and element[3] - 2 or element[3],
                y + yoff,
                (currentElement.x == default.x and currentElement.y == default.y) and "> " .. element[1] .. " <" or
                element[1]
                , (currentElement.x == default.x and currentElement.y == default.y) and colors.white or element[2])
        end
    end

    while true do
        local _, keycode = os.pullEvent("key")
        local key = keys.getName(keycode) or "null"

        if key == "up" then
            currentSelected.y = currentSelected.y - 1

            if currentSelected.y < 1 then
                currentSelected.y = #options
            end
        elseif key == "down" then
            currentSelected.y = currentSelected.y + 1

            if currentSelected.y > #options then
                currentSelected.y = 1
            end
        end

        if key == "left" then
            currentSelected.x = currentSelected.x - 1

            if currentSelected.x < 1 then
                currentSelected.x = #options[currentSelected.y]
            end
        elseif key == "right" then
            currentSelected.x = currentSelected.x + 1

            if currentSelected.x > #options[currentSelected.y] then
                currentSelected.x = 1
            end
        end

        if key == "up" or key == "down" or key == "left" or key == "right" then
            if options[currentSelected.y][currentSelected.x] == nil then
                currentSelected.y = lastSelected.y
            end

            local currentElement = options[currentSelected.y][currentSelected.x]
            local lastElement = options[lastSelected.y][lastSelected.x]

            printat(lastElement[3] - 2, lastSelected.y + yoff, "> " .. lastElement[1] .. " <", colors.black)
            printat(lastElement[3], lastSelected.y + yoff, lastElement[1], lastElement[2])
            printat(currentElement[3] - 2, currentSelected.y + yoff, "> " .. currentElement[1] .. " <", colors.white)

            lastSelected.x = currentSelected.x
            lastSelected.y = currentSelected.y
        end

        if key == "enter" then
            local ranSuccess, returned = pcall(callback, currentSelected, options[currentSelected.y][currentSelected.x])

            if returned == true then
                term.clear()

                printcenter(1, toptext, topcolor)

                if exitkey then
                    printcenter(19, "press " .. exitkey .. " to exit.", colors.white)
                end

                for y, elements in pairs(options) do
                    for x, element in pairs(elements) do
                        local currentElement = vector2.new(x, y)

                        printat((currentElement.x == currentSelected.x and currentElement.y == currentSelected.y) and
                            element[3] - 2 or element[3],
                            y + yoff,
                            (currentElement.x == currentSelected.x and currentElement.y == currentSelected.y) and
                            "> " .. element[1] .. " <" or
                            element[1]
                            ,
                            (currentElement.x == currentSelected.x and currentElement.y == currentSelected.y) and
                            colors.white or element[2])
                    end
                end
            end
            if breakOnSelect then
                break
            end
        end

        if key == exitkey then
            term.clear()
            break
        end
    end
end

local MODES = {
    { "Write", colors.blue },
    { "Keys", colors.lightBlue },
    { "Preset Buttons", colors.cyan }
}

local PRESET = {
    { { "TUNNEL", colors.yellow, 5 }, { "MINER", colors.lime, 17 } },
    { { "DROP", colors.orange, 6 }, { "REBOOT", colors.green, 16 } }
}

local menuSelect = 1

local keymap = {
    w = "go forward",
    a = "go left",
    s = "go back",
    d = "go right",
    e = "go up",
    q = "go down",
    f = "dig",
    r = "dig up",
    v = "dig down",
    z = "drop"
}

local kTable = {
    w = { at = vector2.new(13, 9), "W" },
    a = { at = vector2.new(11, 10), "A" },
    s = { at = vector2.new(13, 10), "S" },
    d = { at = vector2.new(15, 10), "D" },
    e = { at = vector2.new(15, 9), "E" },
    q = { at = vector2.new(11, 9), "Q" },
    f = { at = vector2.new(17, 10), "F" },
    r = { at = vector2.new(17, 9), "R" },
    v = { at = vector2.new(17, 11), "V" },
    z = { at = vector2.new(19, 9), "Z" }
}

while true do
    term.clear()

    listOptionSelect(MODES, menuSelect, 2, "Choose Controller Mode", colors.purple, nil, true,
        function(selected, element)
            menuSelect = selected

            if selected == 1 then
                term.clear()

                printcenter(1, "Write Mode", colors.blue)
                printcenter(2, "Type exit to exit.", colors.blue)

                local commandHistory = {}

                repeat
                    term.setTextColor(colors.yellow)
                    term.setCursorPos(1, 3)
                    term.clearLine()
                    term.write("Command: ")

                    local input = read()

                    printat(1, 6, "Command History: ", colors.lightBlue)

                    rednet.broadcast(input)

                    term.setCursorPos(1, 7)
                    term.clearLine()

                    printat(1, 7, input, colors.red)

                    for i = 1, #commandHistory do
                        term.setCursorPos(1, 7 + i)
                        term.clearLine()

                        printat(1, 7 + i, commandHistory[i], colors.red)
                    end

                    table.insert(commandHistory, 1, input)
                    commandHistory[8] = nil
                until input == "exit"
            elseif selected == 2 then
                term.clear()

                printcenter(1, "Key Mode", colors.lightBlue)
                printcenter(16, "Press x to exit.", colors.lightBlue)

                for i, key in pairs(kTable) do
                    local at = key.at
                    printat(at.x, at.y, key[1], colors.red)
                end

                while true do
                    local _, keycode, held = os.pullEvent("key")
                    local downkey = keys.getName(keycode)

                    if downkey == "x" then
                        break
                    end

                    if held == false then
                        local k = kTable[downkey]
                        if k then
                            local p = k.at
                            printat(p.x, p.y, k[1], colors.lime)
                        end
                    end

                    local function sendBroadcast()
                        local broadcastMessage = ""

                        broadcastMessage = keymap[downkey]

                        while true do
                            rednet.broadcast(broadcastMessage)

                            os.sleep(0.5)
                        end
                    end

                    local function waitForKeyUp()
                        repeat
                            local _, key = os.pullEvent("key_up")
                        until downkey == keys.getName(key)

                        local k = kTable[downkey]
                        if k then
                            local p = k.at
                            printat(p.x, p.y, k[1], colors.red)
                        end
                    end

                    parallel.waitForAny(waitForKeyUp, sendBroadcast)
                end
            elseif selected == 3 then
                term.clear()

                interfaceOptionsSelect(PRESET, vector2.new(1, 1), 2, "Button Interface", colors.cyan, "x", false,
                    function(selected, element)
                        local broadcastMessage = ""

                        if selected.equals(vector2.new(2, 1)) then
                            term.clear()
                            term.setCursorPos(1, 1)

                            local xsize = promptInput("X Size: ")
                            local ysize = promptInput("Y Size: ")
                            local zsize = promptInput("Z Size: ")

                            term.setTextColor(colors.lightBlue)

                            broadcastMessage = string.format("miner %s %s %s", xsize, ysize, zsize)

                            print(string.format("\nAn area of %s by %s by %s will take %s fuel.", tostring(xsize),
                                tostring(ysize), tostring(zsize), tostring(xsize * ysize * zsize)))

                            term.setTextColor(colors.pink)
                            print("\nBroadcasting command.\n\nPress any key to continue.")

                            rednet.broadcast(broadcastMessage)

                            os.pullEvent("key")

                            return true
                        elseif selected.equals(vector2.new(1, 2)) then
                            broadcastMessage = "drop"

                            rednet.broadcast(broadcastMessage)
                        elseif selected.equals(vector2.new(1, 1)) then
                            term.clear()
                            term.setCursorPos(1, 1)

                            local distance = promptInput("Distance to tunnel: ")
                            broadcastMessage = string.format("tunnel %s", distance)

                            term.setTextColor(colors.lightBlue)

                            print(string.format("\nA trip back and forth %s meter(s) will take %s fuel.", distance,
                                distance * 2))

                            term.setTextColor(colors.pink)
                            print("\nBroadcasting command.\n\nPress any key to continue.")

                            rednet.broadcast(broadcastMessage)

                            os.pullEvent("key")

                            return true
                        elseif selected.equals(vector2.new(2, 2)) then
                            broadcastMessage = "reboot"

                            rednet.broadcast(broadcastMessage)
                        end
                    end)
            end
        end)
end
