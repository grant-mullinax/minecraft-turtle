local facingDirs = {{x=0, z=1}, {x=-1, z=0}, {x=0, z=-1},  {x=1, z=0}}
local facingIdx = 0
pos = {x=0, y=0, z=0}

local directions = { forward=0 }

local getFacing = function()
    return facingDirs[facingIdx + 1]
end

getFuelLevel = function()
    return (turtle.getItemCount(1)-1) * 80 + turtle.getFuelLevel()
end

needFuel = function() return getFuelLevel() <= (math.abs(pos.x) + math.abs(pos.y) + math.abs(pos.z) + 40) or turtle.getFuelLevel() <= 0 end

--[[
    ########
    movement
    ########
]]

forward = function()
    while needFuel() do
        if turtle.getItemCount(1) >= 1 then
            turtle.select(1)
            turtle.refuel(1)
        else
            print("i need fuel! ", getFuelLevel())
            goToRelativeCoords(0, 0, 0)
            os.sleep(3)
        end
    end
    
    local b, reason = turtle.forward()
    if not b then
        print("failed,", reason)
        return false
    end

    local facing = getFacing()
    pos.x = pos.x + facing.x
    pos.z = pos.z + facing.z

    print("coords", pos.x, pos.y, pos.z)
    print("fuel", getFuelLevel())

    return true
end

up = function()
    if not turtle.up() then
        return false
    end
    pos.y = pos.y + 1

    return true
end

down = function()
    if not turtle.down() then
        return false
    end
    pos.y = pos.y - 1

    return true
end

turnLeft = function()
    facingIdx = (facingIdx - 1) % 4
    turtle.turnLeft()
end

turnRight = function()
    facingIdx = (facingIdx + 1) % 4
    turtle.turnRight()
end

local findDirIdx = function(idx)
    if facingIdx == idx then
        return
    end

    -- created from truth table
    if facingIdx-1 == idx or (facingIdx == 0 and idx == 3) then
        while facingIdx ~= idx do
            turnLeft()
        end
    else 
        while facingIdx ~= idx do
            turnRight()
        end
    end
end

goToRelativeCoords = function(x, y, z)
    local desiredXDir = pos.x > x and 1 or 3
    local desiredZDir = pos.z > z and 2 or 0

    while pos.x ~= x or pos.y ~= y or pos.z ~= z do
        if pos.x ~= x then
            findDirIdx(desiredXDir)
            while pos.x ~= x and forward() do end
        end
        
        if pos.z ~= z then
            findDirIdx(desiredZDir)
            while pos.z ~= z and forward() do end
        end

        while pos.y < y and up() do end

        while pos.y > y and down() do end
    end
end

goToChest = function(idx)
    local x, y, z
    local divIdx = idx

    local facing = divIdx % 2 == 0 and 1 or 3
    divIdx = math.floor(divIdx / 2)

    divIdxMod6 = divIdx % 6
    divIdx = math.floor(divIdx / 6)

    z = (divIdxMod6 + 1) * (divIdx % 2 == 0 and -1 or 1)
    divIdx = math.floor(divIdx / 2)

    x = (divIdx % 3 - 1) * 5
    divIdx = math.floor(divIdx / 3)

    y = ((divIdx + 5) % 13) - 6
    divIdx = math.floor(divIdx / 13)

    goToRelativeCoords(x,y,z)
    findDirIdx(facing)
end

turtle.refuel()
findDirIdx(0)

for i=900, 935 do
    goToChest(i)
    for i = 2, 16 do
        turtle.select(i)
        if turtle.place() then
            break
        end
    end

    goToRelativeCoords(0,pos.y,0)
end