local lamps = {
    "orange",
    "magenta",
    "light_blue",
    "yellow",
    "lime",
    "pink",
    "purple",
    "blue",
    "red",
    "green"
}

local lampBase = "projectred-illumination:%s_illumar_lamp"
local floorSize = { x = 7, z = 9 }
local floorStart = { x = 273, y = 59, z = -176 }

local function placeLamp(x, y, z, color)
    local lamp = string.format(lampBase, color)
    commands.exec(string.format("setblock %s %s %s %s", x, y, z, lamp))
end

for x = floorStart.x, floorStart.x + floorSize.x do
    for z = floorStart.z, floorStart.z + floorSize.z do
        local color = lamps[math.random(1, #lamps)]
        placeLamp(x, floorStart.y, z, color)
    end
end
