local facingDirs = {{x=0, z=1}, {x=-1, z=0}, {x=0, z=-1},  {x=1, z=0}}
local facingIdx = 0
pos = {x=0, y=0, z=0}

local fluid = peripheral.wrap("left")

local directions = { forward=0 }

local getFacing = function()
    return facingDirs[facingIdx + 1]
end
--[[
    ########
    movement
    ########
]]

forward = function()
    local b, reason = turtle.forward()
    if not b then
        return false
    end

    local facing = getFacing()
    pos.x = pos.x + facing.x
    pos.z = pos.z + facing.z

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


goHomeAndDeposit = function()
    goToRelativeCoords(0, 0, 0)
    findDirIdx(2) -- turn backward
    while (fluid.getFluid() != nil or fluid.getFluid()["amount"] > 0) do 
        fluid.place()
    end
    goToRelativeCoords(0,-1,2)
end

suckUntilFull = function()
    local isNotAir, type = turtle.inspect()

    if isNotAir then
        print(type.name, type.state.level)
        if type.name == "minecraft:lava" then
            if turtle.getFuelLevel() < 900 then
                turtle.place()
                turtle.refuel()
            else
                local suckResult = fluid.suck() or fluid.suckDown()
                if suckResult == 0 then
                    local oldFacingIdx = facingIdx
                    local oldPos = {x=pos.x, y=pos.y, z=pos.z}

                    goHomeAndDeposit()

                    goToRelativeCoords(oldPos.x, oldPos.y, oldPos.z)
                    findDirIdx(oldFacingIdx)
                end
                print(suckResult)
            end
        end
    end

    return true
end

goToRelativeCoords = function(x, y, z, preFunc)

    local desiredXDir = pos.x > x and 1 or 3
    local desiredZDir = pos.z > z and 2 or 0

    -- could minimize turning by looping actions until failure
    while pos.x ~= x or pos.y ~= y or pos.z ~= z do
        if pos.x ~= x then
            findDirIdx(desiredXDir)
        elseif pos.z ~= z then
            findDirIdx(desiredZDir)
        end

        -- do it after to not dig towards the wrong location
        if preFunc ~= nil then
            preFunc()
        end

        if pos.x ~= x or pos.z ~= z then
            forward()
        end

        if pos.y < y then
            up()  
        end

        if pos.y > y then 
            down() 
        end
    end
end


findDirIdx(0)

turtle.refuel()
goToRelativeCoords(0,-1,2)

while true do
    local rn = math.random()
    if rn < .34 then
        turnLeft()
    elseif rn > .67 then
        turnRight()
    end
    suckUntilFull()
    forward()
end