local args = { ... }

local maxFuel = tonumber(args[1]) or 5000

local hasbucket = false
local hasmultiplebuckets = false

for i = 1, 16 do
    local data = turtle.getItemDetail(i)
    if data and data.name == "minecraft:bucket" then
        hasbucket = true
        if data.count > 1 then
            hasmultiplebuckets = true
        end
        break
    end
end

if hasbucket then
    repeat
        local hasBlock, data = turtle.inspectDown()

        if hasBlock and data.name == "minecraft:lava" then
            break
        end

        turtle.digDown()
        turtle.down()
    until hasBlock and data.name == "minecraft:lava"

    while turtle.getFuelLevel() < maxFuel do
        local _, data = turtle.inspectDown()

        if data and data.name == "minecraft:lava" and data.state.level == 0 then
            local y = 0
            repeat
                local _, data = turtle.inspectDown()
                turtle.placeDown()
                turtle.refuel()
                turtle.down()
                y = y - 1
            until data and data.name ~= "minecraft:lava" or data == nil

            y = y + 1

            repeat
                turtle.digUp()
                turtle.up()
                y = y + 1
            until y == 0
        elseif data and data.name ~= "minecraft:lava" then
            turtle.back()
            turtle.turnRight()
        end

        if turtle.detect() then
            turtle.turnRight()
            if turtle.detect() then
                turtle.turnLeft()
                turtle.turnLeft()
            end
            if turtle.detect() then
                turtle.turnLeft()
            end
        end

        turtle.forward()
    end

    print(os.getComputerLabel() .. " has more fuel than " .. maxFuel)
end
