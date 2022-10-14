local w, h = term.getSize()

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local function printCenter(y, text, slow, rate)
    if not slow then
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        term.write(text)
    else
        term.setCursorPos(math.floor((w - string.len(text)) / 2), y)
        textutils.slowPrint(text, rate or 7)
    end
end

local function optionSelect(options, selectCallback, keyCallback)
    local currentSelected = 0
    local startY = math.floor((h - #options) / 2)

    for i, option in pairs(options) do

    end
end

clear()

local mainMenu = {

}
