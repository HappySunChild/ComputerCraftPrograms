local lamps = {
    "red",
    "orange",
    "yellow",
    "blue"
}

local lampBase = "projectred-illumination:%s_illumar_lamp"
local floorSize = { x = 6, z = 8 }
local floorStart = { x = 273, y = 59, z = -176 }

local function placeLamp(x, y, z, color, lit)
    local lamp = string.format(lampBase, color)
    commands.execAsync(string.format("setblock %s %s %s %s[lit = %s]", x, y, z, lamp, tostring(lit)))
end

local function updateFloor(lit)
    for x = floorStart.x, floorStart.x + floorSize.x do
        for z = floorStart.z, floorStart.z + floorSize.z do
            local color = lamps[math.random(1, #lamps)]

            placeLamp(x, floorStart.y, z, color, lit)
        end
    end
end

local function disco()
    while true do
        updateFloor(true)
        sleep(0.4)
    end
end

local function music()
    shell.run("player play dfpwm JELLY 4")

    updateFloor(false)
end

parallel.waitForAny(disco, music)
