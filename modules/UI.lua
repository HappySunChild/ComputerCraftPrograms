local termX, termY = term.getSize()

local ui = {}

function ui.prompt(prompt, color)
    term.setTextColor(color or colors.yellow)
    term.write(prompt)
    return read()
end

function ui.printCenter(y, text, color)
    local x = math.floor((termX - string.len(text)) / 2)

    if term.isColor() then
        term.setTextColor(color or colors.white)
    end

    term.setCursorPos(x, y)
    term.clearLine()
    term.write(text)
end

function ui.printAt(x, y, text, color)
    if term.isColor() then
        term.setTextColor(color or colors.white)
    end

    term.setCursorPos(x, y)
    term.write(text)
end

function ui.list(options, title, bos, callback, keycallback)
    term.clear()

    ui.printCenter(1, title or "Title")

    local selected = 1
    local last = 1

    for i, option in pairs(options) do
        local text = option[1]
        local color = option[2]
        local isSelected = selected == i

        ui.printCenter(i + 2, isSelected and ("> " .. text .. " <") or text, isSelected and colors.white or color)
    end

    while true do -- events
        local _, keycode = os.pullEvent("key")
        local key = keys.getName(keycode)

        last = selected

        if key == "down" then
            selected = selected + 1

            if selected > #options then
                selected = 1
            end
        elseif key == "up" then
            selected = selected - 1

            if selected < 1 then
                selected = #options
            end
        end

        if key == "down" or key == "up" then
            local selectedElement = options[selected]
            local lastElement = options[last]

            if lastElement and selectedElement then
                ui.printCenter(last + 2, lastElement[1], lastElement[2])
                ui.printCenter(selected + 2, "> " .. selectedElement[1] .. " <", colors.white)
            end
        end

        if keycallback then
            keycallback(key)
        end

        if key == "enter" then
            if callback then
                callback(selected, options[selected])
            end

            if bos then
                break
            end
        end
    end
end

function ui.interface(options, title, bos, callback)
    term.clear()

    ui.printCenter(1, title or "Title")
    ui.printCenter(termY - 1, "Press `x` to return.", colors.red)

    local selected = { x = 1, y = 1 }
    local last = { x = 1, y = 1 }

    for y, level in pairs(options) do
        for xi, option in pairs(level) do
            local text = option[1]
            local color = option[2]
            local x = option[3]

            local isSelected = selected.x == xi and selected.y == y

            ui.printAt(x - (isSelected and 2 or 0), y + 2, isSelected and "> " .. text .. " <" or text,
                isSelected and colors.white or color)
        end
    end

    while true do
        local _, keycode = os.pullEvent("key")
        local key = keys.getName(keycode)

        if key == "down" then
            selected.y = selected.y + 1
        elseif key == "up" then
            selected.y = selected.y - 1
        end

        if key == "left" then
            selected.x = selected.x - 1
        elseif key == "right" then
            selected.x = selected.x + 1
        end

        if key == "down" or key == "up" or key == "left" or key == "right" then
            if selected.y < 1 then
                selected.y = #options
            elseif selected.y > #options then
                selected.y = 1
            end

            if selected.x < 1 then
                selected.x = #options[selected.y]
            elseif selected.x > #options[selected.y] then
                selected.x = 1
            end

            if not options[selected.y][selected.x] then
                selected.x = 1
            end

            local selectedElement = options[selected.y][selected.x]
            local lastElement = options[last.y][last.x]

            if selectedElement and lastElement then
                ui.printAt(lastElement[3] - 2, last.y + 2, "  " .. lastElement[1] .. "  ", lastElement[2])
                ui.printAt(selectedElement[3] - 2, selected.y + 2, "> " .. selectedElement[1] .. " <")
            end

            last.x = selected.x
            last.y = selected.y
        end

        if key == "x" then
            break
        end

        if key == "enter" then
            callback(selected, options[selected.y][selected.x])

            if bos then
                break
            else
                term.clear()

                ui.printCenter(1, title or "Title")
                ui.printCenter(termY - 1, "Press `x` to return.", colors.red)

                for y, level in pairs(options) do
                    for xi, option in pairs(level) do
                        local text = option[1]
                        local color = option[2]
                        local x = option[3]

                        local isSelected = selected.x == xi and selected.y == y

                        ui.printAt(x - (isSelected and 2 or 0), y + 2, isSelected and "> " .. text .. " <" or text,
                            isSelected and colors.white or color)
                    end
                end
            end
        end
    end
end

return ui
