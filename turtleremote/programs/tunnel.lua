local args = {...}

local MineDistance = args[1] or 1 --     How far the turtle will tunnel
local TorchFrequency = args[2] or 10 --  How often the turtle will place torches
local ICheckFrequency = args[3] or 10 -- How often the turtle will empty it's inventory

local ITEMS = { --   whitelist
    "minecraft:coal",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "minecraft:diamond",
    "minecraft:emerald",
    "minecraft:lapis_lazuli",
    "minecraft:redstone",
    "create:copper_ore",
    "create:zinc_ore",
    "minecraft:ancient_debris",
    "minecraft:quartz",
    "minecraft:torch" --  so it doesnt drop torches its supposed to place
}

local function hasEnoughFuel()
    local requiredFuel = MineDistance*2
    local currentFuel = turtle.getFuelLevel()

    if currentFuel < requiredFuel then
        term.write("Not enough fuel!")
        shell.run("refuel","all")
        return false
    else
        return true
    end
end

local function forward()
    while turtle.forward() == false do
        turtle.dig()
    end
end

local function inventoryCheck()
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item then
            local a = false
            for x = 1,#ITEMS do
                if item.name == ITEMS[x] then
                    a = true
                    break
                end
            end
            if not a then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
end

local function getTorchSlot()
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item then
            if item.name == "minecraft:torch" then
                return i
            end
        end
    end
    return false
end

local function tunnel()
    for i = 0,MineDistance-1 do
        forward()
        turtle.digDown()
        turtle.digUp()

        if i % TorchFrequency == 0 then
            local s = getTorchSlot()
            if s then
                turtle.select(s)
                turtle.placeDown()
            end
        end

        if i % ICheckFrequency == 0 then
            inventoryCheck()
        end
    end

    for i = 0,MineDistance-1 do
        turtle.back()
    end
end

if hasEnoughFuel() then
    rednet.broadcast("loaded")
    tunnel()
else
    rednet.broadcast(" 104; not enough fuel")
end
