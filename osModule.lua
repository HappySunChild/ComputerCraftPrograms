---@diagnostic disable: undefined-field
local mod = {}

local w, h = term.getSize()

function mod.clear()
    term.clear()
    term.setCursorPos(1, 1)
end

function mod.printCenter(y, text, color, slow, rate)
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
        term.clearLine()
        term.write(text)
    else
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        textutils.slowWrite(text, rate or 7)
    end
end

function mod.prompt(prompt)
    term.write(prompt)
    return read()
end

function mod.optionSelect(options, offset, exitOnSelect, selectCallback, keyCallback)
    local currentSelected = 1
    local lastSelected = 1
    local startY = math.floor((h - #options) / 2) + (offset or 0)

    for i, option in pairs(options) do
        local text, color = option[1], option[2]

        if i == currentSelected then
            text = string.format("[ %s ]", text)
        end

        mod.printCenter(startY + i, text, option[2])
    end

    while true do
        local _, keycode = os.pullEvent("key")
        local key = keys.getName(keycode)

        lastSelected = currentSelected

        if key == "up" or key == "down" then
            if key == "up" then
                currentSelected = currentSelected - 1

                if currentSelected < 1 then
                    currentSelected = #options
                end
            elseif key == "down" then
                currentSelected = currentSelected + 1

                if currentSelected > #options then
                    currentSelected = 1
                end
            end

            local currentElement = options[currentSelected]
            local lastElement = options[lastSelected]

            if currentElement and lastElement then
                local cOption = currentElement[1]
                local lOption, lColor = lastElement[1], lastElement[2]

                mod.printCenter(currentSelected + startY, string.format("[ %s ]", cOption))
                mod.printCenter(lastSelected + startY, lOption, lColor)
            end
        end

        if key == "enter" then
            pcall(selectCallback, currentSelected, options[currentSelected])

            if exitOnSelect then
                mod.clear()
                break
            end
        end

        if keyCallback then
            pcall(keyCallback, key, currentSelected)
        end
    end
end

return mod
