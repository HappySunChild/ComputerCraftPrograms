---@diagnostic disable: undefined-field, need-check-nil

local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm") -- This requires CC:Tweaked 100 or higher because of this module

local args = { ... }

local runMethod = args[1]

term.clear()
term.setCursorPos(1, 1)

local w, h = term.getSize()

local volume = 1
local pitch = 1

local RECORDS = {
    { "11", colors.brown },
    { "13", colors.red },
    { "blocks", colors.orange },
    { "cat", colors.yellow },
    { "chirp", colors.lime },
    { "far", colors.green },
    { "mall", colors.cyan },
    { "mellohi", colors.lightBlue },
    { "pigstep", colors.blue },
    { "stal", colors.purple },
    { "strad", colors.magenta },
    { "wait", colors.pink },
    { "ward", colors.red }
}

local MENU = {
    { "RECORDS", colors.red },
    { "CUSTOM RECORDS", colors.orange },
    { "DFPWM FILES", colors.yellow },
    { "SAVES", colors.lime },
    { "ADD RECORD", colors.green },
    { "ADD DFPWM", colors.cyan },
    { "ADD SAVE", colors.blue },
    { "REMOVE ALL SAVES", colors.lightBlue },
    { "VOLUME", colors.purple },
    { "PITCH", colors.magenta },
    { "STOP", colors.pink },
    { "EXIT", colors.red },
    { "UPDATE", colors.brown }
}

function table.find(t, v)
    if t and v then
        for i, o in pairs(t) do
            if o == v then
                return i
            end
        end
    end

    return nil
end

function colors.random()
    local rand = math.random(1, 16)
    local c = colors.white
    local cols = {}

    for i, color in pairs(colors) do
        if type(color) == "number" then
            table.insert(cols, color)
        end
    end

    return cols[rand]
end -- get random color function

local function isValidId(id)
    local success = pcall(function()
        speaker.playSound(id, 0, 0)
        speaker.stop()
    end)

    return success
end

local function promptInput(promptText)
    term.write(promptText)
    return read()
end

local function printcenter(y, text, color)
    local x = math.floor((w - string.len(text)) / 2)

    term.setTextColor(tonumber(color) or colors.white)
    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

local function playSound(sound_jsonid, l_pitch, l_volume)
    if sound_jsonid and sound_jsonid ~= nil then
        speaker.playSound(sound_jsonid, tonumber(l_volume) or tonumber(volume), tonumber(l_pitch) or tonumber(pitch))
    end
end

-- custom json id sound functions

local function createSaveFile()
    if not fs.exists("saved.txt") then
        local file = fs.open("saved.txt", "w")
        file.write("")
        file.close()

        local file = fs.open("records.save", "w")
        file.write("")
        file.close()

        return true
    else
        return false
    end
end

local function clearSaveFile()
    if fs.exists("saved.txt") then
        local file = fs.open("saved.txt", "w")
        file.write("")
        file.close()

        return true
    else
        createSaveFile()

        return false
    end
end

local function addToSaveFile(saveElement)
    if fs.exists("saved.txt") then
        local id, name, color = saveElement[1], saveElement[2], saveElement[3]

        if color == colors.black then
            color = colors.white
        end

        local file = fs.open("saved.txt", "a")
        file.write(name .. "\n" .. color .. "\n" .. id .. "\n\n")
        file.close()

        return true
    else
        createSaveFile()

        return false
    end
end

local function getSaved()
    if fs.exists("saved.txt") then
        local file = fs.open("saved.txt", "r")
        local saved = {}

        local i = 1
        repeat
            local name = file.readLine()
            local color = file.readLine()
            local id = file.readLine()
            file.readLine()

            if id then
                saved[i] = { name, color, id }
            end
            i = i + 1
        until id == nil or name == nil or color == nil

        file.close()
        return saved
    else
        createSaveFile()

        return false
    end
end

-- custom dfpwm file sounds functions

local function createCustomSavesDir()
    if not fs.exists("custom") then
        fs.makeDir("custom")
    end
end

local function getCustomDFPWM()
    if fs.exists("custom") then
        local saved = fs.list("custom")

        for i, file in pairs(saved) do
            saved[i] = { file, colors.random() }
        end

        return saved
    else
        createCustomSavesDir()
    end
end

local function playCustomAudio(path)
    local decoder = dfpwm.make_decoder()

    for input in io.lines("custom/" .. path, 16 * 1024) do
        local decoded = decoder(input)

        for i, amp in pairs(decoded) do
            decoded[i] = math.min(math.max(decoded[i] * tonumber(volume), -127), 127)

            if math.abs(decoded[i]) < 2 then
                decoded[i] = decoded[i] / 2
            end
        end

        while not speaker.playAudio(decoded, tonumber(volume)) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

local function downloadDFPWM(link, name) -- you will need to change your config to download most DFPWM files
    if link and name then
        if not fs.exists("custom/" .. name) and http.checkURL(link) then
            shell.run(string.format("wget %s custom/%s", link, name)) -- wget, weburl, filename
        end
    end
end

-- custom records file functions

local function getCustomRecords()
    if fs.exists("records.save") then
        local records = {}

        local file = fs.open("records.save", "r")
        local index = 1

        repeat
            local name = file.readLine()
            local id = file.readLine()
            local color = file.readLine()
            local author = file.readLine()
            file.readLine() -- increment empty line

            if id then
                records[index] = { name = name, author = author, color = color, id = id }
            end
            index = index + 1
        until name == nil or id == nil or color == nil or author == nil

        file.close()

        return records
    end
end

local function addCustomRecord(id, name, author, color)
    if fs.exists("records.save") then
        if color == "black" then
            color = "white"
        end

        local file = fs.open("records.save", "a")
        file.write(name .. "\n" .. id .. "\n" .. color .. "\n" .. author .. "\n\n")
        file.close()

        return true
    else
        return false
    end
end

local function formatData(data)
    local newData = {}

    for i, save in pairs(data) do
        local name = save.name

        if save.author and string.len(save.author) > 2 then
            name = string.format("%s - %s", save.name, save.author)
        end

        newData[i] = { name, colors[save.color] or colors.random() }
    end

    return newData
end

-- ex list element; {text, color}

local function optionSelect(list, default, yoff, toptext, topcolor, exitkey, breakOnSelect, callback, keycallback)
    printcenter(1, toptext, topcolor)

    if exitkey then
        printcenter(h - 1, "press " .. exitkey .. " to exit.")
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
            playSound("block.lever.click", 1, 0.3)
            sleep(0.2)
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

local menuCurrent = 1
local savedCurrent = 1

if runMethod == "play" then
    local mode = args[2]
    local file = args[3]

    if mode and file then
        if mode == "dfpwm" then
            if fs.exists("custom/" .. file) then
                playCustomAudio(file)
            end
        elseif mode == "record" then
            printcenter(5, "not available")
        end
    end
else
    local active = true

    while active do
        optionSelect(MENU, menuCurrent, 2, "Menu Options", colors.pink, nil, true, function(selected, element)
            local button = element[1]
            menuCurrent = selected

            if button == "RECORDS" then
                optionSelect(RECORDS, 1, 2, "All Records", colors.green, "x", false, function(selected, element)
                    playSound("music_disc." .. element[1])
                end)
            elseif button == "SAVES" then
                if not fs.exists("saved.txt") then
                    createSaveFile()
                end

                local saved = getSaved()

                term.clear()
                term.setCursorPos(1, 1)

                if #saved == 0 then
                    printcenter(13, "No saves detected", colors.red)
                    printcenter(19, "press any key to exit.")
                end

                if saved ~= nil and #saved > 0 then
                    optionSelect(saved, 1, 2, "All Saves", colors.lime, "x", false, function(selected, element)
                        playSound(element[3])
                    end)
                end

                if #saved == 0 then
                    os.pullEvent("key")

                    term.clear()
                end
            elseif button == "ADD SAVE" then
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)

                local id = promptInput("Input json id: ")
                local name = promptInput("Input name: ")

                if isValidId(id) then
                    term.clear()

                    printcenter(5, "Saved", colors.lime)
                    printcenter(6, id, colors.green)
                    printcenter(7, "as", colors.lime)
                    printcenter(8, name, colors.green)

                    addToSaveFile({ id, name, colors.random() })

                    speaker.playNote("bit", 1, 16)
                    sleep(0.15)
                    speaker.playNote("bit", 2, 20)
                    sleep(0.1)
                    speaker.playNote("bit", 2, 24)

                    sleep(1)
                else
                    term.clear()

                    printcenter(6, "not a valid id!", colors.red)

                    speaker.playNote("bit", 2, 0.05)
                    sleep(0.2)
                    speaker.playNote("bit", 2, 0.05)

                    sleep(1)
                end
            elseif button == "VOLUME" then
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)

                volume = promptInput("Input volume: ")
            elseif button == "PITCH" then
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)

                pitch = promptInput("Input pitch: ")
            elseif button == "STOP" then
                speaker.stop()
            elseif button == "REMOVE ALL SAVES" then
                term.clear()
                optionSelect({ { "Yes", colors.green }, { "No", colors.red } }, 1, 3, "Are you sure?", colors.blue, nil,
                    true
                    , function(selected, element)
                    if selected == 1 then
                        clearSaveFile()

                        term.clear()
                        printcenter(7, "Wiped Save File", colors.red)

                        speaker.playNote("bit", 2, 24)
                        sleep(0.1)
                        speaker.playNote("bit", 2, 20)
                        sleep(0.11)
                        speaker.playNote("bit", 1, 16)

                        sleep(1)
                    end
                end)
            elseif button == "DFPWM FILES" then
                if not fs.exists("custom") then
                    createCustomSavesDir()
                end

                local saved = getCustomDFPWM()

                term.clear()
                term.setCursorPos(1, 1)

                if #saved == 0 then
                    printcenter(9, " No custom audios detected", colors.red)
                    printcenter(10, "inside directory", colors.red)
                    printcenter(18, "press any key to exit.")

                    os.pullEvent("key")
                    term.clear()
                end

                if #saved > 0 then
                    optionSelect(saved, 1, 2, "All Custom Saves", colors.purple, "x", false,
                        function(selected, element)
                            playCustomAudio(element[1])
                        end)
                end
            elseif button == "CUSTOM RECORDS" then
                if not fs.exists("records.save") then
                    createSaveFile()
                end

                term.clear()
                term.setCursorPos(1, 1)

                local saved = getCustomRecords()

                if #saved == 0 then
                    printcenter(13, "No saved detected", colors.red)
                    printcenter(19, "press any key to exit.")

                    os.pullEvent()
                    term.clear()
                else
                    optionSelect(formatData(saved), 1, 2, "Custom Records", colors.purple, "x", false,
                        function(selected)
                            playSound(saved[selected].id)
                        end)
                end
            elseif button == "ADD RECORD" then
                if not fs.exists("records.save") then
                    createSaveFile()
                end

                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)

                local id = promptInput("Id: ")
                local name = promptInput("Name: ")
                local author = promptInput("Author (optional): ")
                local color = promptInput("Color (optional): ")

                if isValidId(id) then
                    term.clear()

                    printcenter(6, "Added Record", colors.green)
                    printcenter(7, "Check \"CUSTOM RECORDS\"", colors.green)

                    addCustomRecord(id, name, author, color)

                    speaker.playNote("bit", 1, 16)
                    sleep(0.15)
                    speaker.playNote("bit", 2, 20)
                    sleep(0.1)
                    speaker.playNote("bit", 2, 24)

                    sleep(1)
                end
            elseif button == "ADD DFPWM" then
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)

                local link = promptInput("Link:")
                local name = promptInput("Name: ")

                if link and name then
                    downloadDFPWM(link, name)

                    term.clear()

                    printcenter(6, "Added DFPWM", colors.green)
                    printcenter(7, "Check \"DFPWM FILES\"", colors.green)

                    speaker.playNote("bit", 1, 16)
                    sleep(0.15)
                    speaker.playNote("bit", 2, 20)
                    sleep(0.1)
                    speaker.playNote("bit", 2, 24)

                    sleep(1)
                end
            elseif selected == #MENU - 1 then
                term.clear()
                term.setCursorPos(1, 1)

                active = false
            elseif button == "UPDATE" then
                if fs.exists("player") then
                    fs.delete("player")
                end

                shell.run("wget https://raw.githubusercontent.com/HappySunChild/ComputerCraftPrograms/main/jukebox.lua player")

                term.clear()
                term.setCursorPos(1, 1)

                printcenter(7, "Updating...", colors.green)
                printcenter(8, "Your saves will", colors.green)
                printcenter(9, "stay.", colors.green)

                sleep(1.5)

                term.clear()
                term.setCursorPos(1, 1)

                active = false
            end
        end)
    end
end
