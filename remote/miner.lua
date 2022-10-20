local args = { ... }

local X_Size = tonumber(args[1] or 10)
local Y_Size = tonumber(args[2] or 1)
local Z_Size = tonumber(args[3] or X_Size)

local requiredFuel = math.abs(X_Size * Z_Size * Y_Size)

term.clear()
term.setCursorPos(1, 1)

print("An area of " .. X_Size .. " by " .. Y_Size .. " by " .. Z_Size .. " requires " .. requiredFuel .. " fuel.")
print("Currently there is " ..
    (turtle.getFuelLevel() >= requiredFuel and "enough" or "not enough") .. " fuel to dig this area out.")
print("Current Fuel level: " .. turtle.getFuelLevel())
print("After Fuel Level: " .. turtle.getFuelLevel() - requiredFuel)
print("")

function math.sign(x)
    return (x > 0) and 1 or (x < 0) and -1 or 0
end

function math.divisibleBy(x, m)
    return (x % m == 0)
end

function math.even(x)
    return (x % 2 == 0)
end

if turtle.getFuelLevel() >= requiredFuel then
    for y = 1, math.abs(Y_Size) do
        local z_start = 1

        for z = z_start, Z_Size do
            for x = math.even(z) and X_Size or 1, math.even(z) and 1 or X_Size, math.even(z) and -1 or 1 do
                --print(string.format("X: %s\nY: %s\nZ: %s",x,y,z))
                turtle.dig()
                turtle.digDown()
                turtle.digUp()
                repeat turtle.dig() until turtle.forward()
            end

            turtle.digUp()
            turtle.digDown()

            if z ~= Z_Size then
                if z % 2 == 0 then
                    turtle.turnLeft()
                    turtle.dig()
                    turtle.forward()
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                    turtle.dig()
                    turtle.forward()
                    turtle.turnRight()
                end
            end
        end

        if y ~= Y_Size then
            if math.sign(Y_Size) == 1 then
                for i = 1, 3 do
                    turtle.digUp()
                    turtle.up()
                end
            elseif math.sign(Y_Size) == -1 then
                for i = 1, 3 do
                    turtle.digDown()
                    turtle.down()
                end
            end

            turtle.turnRight()
            turtle.turnRight()
        end
    end
end
