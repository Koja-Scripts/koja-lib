---@class PointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: CPoint)
---@field onExit? fun(self: CPoint)
---@field nearby? fun(self: CPoint)
---@field [string] any

---@class CPoint : PointProperties
---@field id number
---@field currentDistance number
---@field isClosest? boolean
---@field remove fun()

---@type table<number, CPoint>
local points = {}
---@type CPoint[]
local nearbyPoints = {}
local nearbyCount = 0
---@type CPoint?
local closestPoint
local tick

local intervals = {}
---@param callback function | number
---@param interval? number
---@param ... any
function SetInterval(callback, interval, ...)
    interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(json.encode(interval --[[@as unknown]])))
    end

    local cbType = type(callback)

    if cbType == 'number' and intervals[callback] then
        intervals[callback] = interval or 0
        return
    end

    if cbType ~= 'function' then
        return error(('Callback must be a function. Received %s'):format(cbType))
    end

    local gars, id = { ... }

    Citizen.CreateThreadNow(function(ref)
        id = ref
        intervals[id] = interval or 0
        repeat
            interval = intervals[id]
            Wait(interval)
            local ok, err = pcall(function()
                if gars and #gars > 0 then
                    callback(table.unpack(gars))
                else
                    callback()
                end
            end)
            if not ok then
                if Config.Debug then
                    print('SetInterval callback error:', err)
                end
            end
        until interval < 0
        intervals[id] = nil
    end)

    return id
end

---@param id number
function ClearInterval(id)
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id --[[@as unknown]])))
    end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
    end

    intervals[id] = -1
end

local function toVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

local function removePoint(self)
    if closestPoint?.id == self.id then
        closestPoint = nil
    end
    self.inside = nil
    self.currentDistance = nil
    self.onEnter = nil
    self.onExit = nil
    self.nearby = nil
    points[self.id] = nil
end

KOJA.Client.points = {
    new = function(...)
        local args = {...}
        local id = #points + 1
        local self

        if type(args[1]) == 'table' then
            self = args[1]
            self.id = id
            self.remove = function()
                removePoint(self)
            end
        else
            self = {
                id = id,
                coords = args[1],
                remove = function()
                    removePoint(self)
                end,
            }
        end

        self.coords = toVector(self.coords)
        self.distance = self.distance or args[2]
        self.resource = self.resource or GetInvokingResource() or GetCurrentResourceName()

        if args[3] then
            for k, v in pairs(args[3]) do
                self[k] = v
            end
        end

        points[id] = self

        return self
    end,

    getAllPoints = function()
        return points
    end,

    getNearbyPoints = function()
        return nearbyPoints
    end,

    getClosestPoint = function()
        return closestPoint
    end,
}

AddEventHandler('onResourceStop', function(resource)
    for _, point in pairs(points) do
        if point and point.resource == resource then
            removePoint(point)
        end
    end
end)

CreateThread(function()
    while true do
        if nearbyCount ~= 0 then
            table.wipe(nearbyPoints)
            nearbyCount = 0
        end

        local coords = GetEntityCoords(PlayerPedId())

        if closestPoint and #(coords - closestPoint.coords) > closestPoint.distance then
            closestPoint = nil
        end

        for _, point in pairs(points) do
            if point and point.resource and point.resource ~= GetCurrentResourceName() and GetResourceState(point.resource) ~= 'started' then
                removePoint(point)
                goto continue
            end
            local distance = #(coords - point.coords)

            if distance <= point.distance then
                point.currentDistance = distance

                if closestPoint then
                    if distance < closestPoint.currentDistance then
                        closestPoint.isClosest = nil
                        point.isClosest = true
                        closestPoint = point
                    end
                elseif distance < point.distance then
                    point.isClosest = true
                    closestPoint = point
                end

                if point.nearby then
                    nearbyCount += 1
                    nearbyPoints[nearbyCount] = point
                end

                if point.onEnter and not point.inside then
                    point.inside = true
                    local ok, err = pcall(function()
                        point:onEnter()
                    end)
                    if not ok then
                        point.inside = nil
                        point.onEnter = nil
                        if Config.Debug then
                            print('Point onEnter callback error:', err)
                        end
                    end
                end
            elseif point.currentDistance then
                if point.onExit then
                    local ok, err = pcall(function()
                        point:onExit()
                    end)
                    if not ok then
                        point.onExit = nil
                        if Config.Debug then
                            print('Point onExit callback error:', err)
                        end
                    end
                end
                point.inside = nil
                point.currentDistance = nil
            end
            ::continue::
        end

        if not tick then
            if nearbyCount ~= 0 then
                tick = SetInterval(function()
                    for i = 1, nearbyCount do
                        local point = nearbyPoints[i]
                        if point and point.nearby then
                            local ok, err = pcall(function()
                                point:nearby()
                            end)
                            if not ok then
                                point.nearby = nil
                                if Config.Debug then
                                    print('Point nearby callback error:', err)
                                end
                            end
                        end
                    end
                end)
            end
        elseif nearbyCount == 0 then
            tick = ClearInterval(tick)
        end

        Wait(300)
    end
end)