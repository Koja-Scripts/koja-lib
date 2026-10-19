---Positional sound API. Uses xsound when it is running; otherwise it falls back to koja-lib's own NUI sound
---player (client/modules/sounds.lua, 'koja-lib:nui:createSound'): one-shot volume attenuated by the distance at play time.
KOJA.Client.Sound = KOJA.Client.Sound or {}
local Sound = KOJA.Client.Sound

local function safe(fn)
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

local function toVector(coords)
    coords = coords or {}
    return vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0)
end

---@return boolean # Whether xsound is running and enabled
Sound.Available = function()
    if tostring(Config.Sound or 'auto') == 'none' then return false end
    local state = GetResourceState('xsound')
    return state == 'started' or state == 'starting'
end

---@param id string # Sound id
---@return boolean
Sound.Exists = function(id)
    if not Sound.Available() or not id then return false end
    return safe(function() return exports.xsound:soundExists(id) end) == true
end

local nuiFallbackIds = {}

local function nuiEnabled()
    return tostring(Config.Sound or 'auto') ~= 'none'
end

---@param id string # Sound id
---@param url string # Audio url
---@param volume number # 0.0 - 1.0
---@param coords vector3 # Sound position
---@param loop boolean|nil # Loop the sound
---@return boolean
Sound.PlayUrlPos = function(id, url, volume, coords, loop)
    if not id or not url then return false end

    if Sound.Available() then
        return safe(function()
            exports.xsound:PlayUrlPos(id, url, tonumber(volume) or 0.5, toVector(coords), loop == true)
            return true
        end) == true
    end

    if not nuiEnabled() then return false end

    -- koja-lib NUI player fallback
    local maxDistance = 20.0
    local gap = #(GetEntityCoords(PlayerPedId()) - toVector(coords))
    local base = tonumber(volume) or KOJA.Client.Sounds.defaultSoundVolume or 0.5
    local vol = base * math.max(0.0, 1.0 - (gap / maxDistance))
    nuiFallbackIds[id] = true
    KOJA.Client.SendReactMessage('koja-lib:nui:createSound', {
        type = 'playSound',
        file = url,
        volume = vol,
        soundId = id,
        loop = loop == true,
    })
    return true
end

---@param id string # Sound id
---@param volume number # 0.0 - 1.0
Sound.SetVolume = function(id, volume)
    if not Sound.Exists(id) then return end
    safe(function() exports.xsound:setVolume(id, tonumber(volume) or 0.5) end)
end

---@param id string # Sound id
---@param distance number # Hearing distance
Sound.SetDistance = function(id, distance)
    if not Sound.Exists(id) then return end
    safe(function() exports.xsound:Distance(id, tonumber(distance) or 20.0) end)
end

---@param id string # Sound id
---@param coords vector3 # New position
Sound.SetPosition = function(id, coords)
    if not Sound.Exists(id) then return end
    safe(function() exports.xsound:Position(id, toVector(coords)) end)
end

---@param id string # Sound id
---@param seconds number # Time stamp in seconds
Sound.SetTimeStamp = function(id, seconds)
    if not Sound.Exists(id) then return end
    safe(function() exports.xsound:setTimeStamp(id, tonumber(seconds) or 0) end)
end

---@param id string # Sound id
Sound.Stop = function(id)
    if Sound.Exists(id) then
        safe(function() exports.xsound:Destroy(id) end)
        return
    end
    if id and nuiFallbackIds[id] then
        nuiFallbackIds[id] = nil
        KOJA.Client.SendReactMessage('koja-lib:nui:createSound', {
            type = 'stopSound',
            soundId = id,
        })
    end
end
