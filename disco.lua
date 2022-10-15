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
local floorSize = { x = 6, z = 8 }
local floorStart = { x = 273, y = 59, z = -176 }

local function placeLamp(x, y, z, color)
    local lamp = string.format(lampBase, color)
    commands.execAsync(string.format("setblock %s %s %s %s[lit = true]", x, y, z, lamp))
end

local function updateFloor()
    for x = floorStart.x, floorStart.x + floorSize.x do
        for z = floorStart.z, floorStart.z + floorSize.z do
            local color = lamps[math.random(1, #lamps)]

            placeLamp(x, floorStart.y, z, color)
        end
    end
end

local function disco()

end

local function music()
    shell.run("player play dfpwm JELLY")

    sleep(153)
end

parallel.waitForAny(disco, music)
