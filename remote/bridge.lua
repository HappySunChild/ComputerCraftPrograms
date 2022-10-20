local args = { ... }

local distance = tonumber(args[1])

local function selectBlock()
    for i = 1, 16 do
        local count = turtle.getItemCount(i)

        if count > 1 then
            turtle.select(i)
            break
        end
    end
end

for i = 1, distance do
    if turtle.getItemCount(turtle.getSelectedSlot()) == 0 then
        selectBlock()
    end

    turtle.placeDown()
    turtle.dig()
    turtle.forward()
end

turtle.placeDown()
