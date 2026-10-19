local function loadDict(dict)
    if not dict or HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(10) end
    return HasAnimDictLoaded(dict)
end

local function attachProp(ped, prop)
    local model = type(prop.model) == 'string' and joaat(prop.model) or prop.model
    if not model or not IsModelInCdimage(model) then return nil end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(10) end
    if not HasModelLoaded(model) then return nil end

    local coords = GetEntityCoords(ped)
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    local pos, rot = prop.pos or {}, prop.rot or {}
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, prop.bone or 60309),
        (pos.x or 0.0) + 0.0, (pos.y or 0.0) + 0.0, (pos.z or 0.0) + 0.0,
        (rot.x or 0.0) + 0.0, (rot.y or 0.0) + 0.0, (rot.z or 0.0) + 0.0,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
    return object
end

---Blocking progress bar built on top of the startProgressbar export.
---@param data table # { label, description, duration(ms), cancelable, animation = { dict, name }, scenario, prop = { model, bone, pos, rot }, inputBlock }
---@return boolean # true when finished, false when cancelled
KOJA.Client.Progress = function(data)
    data = data or {}
    local ped = PlayerPedId()
    local anim = data.animation or data.anim
    local animation

    if type(anim) == 'table' and anim.dict then
        animation = { dict = anim.dict, name = anim.name or anim.clip or anim.anim, flag = anim.flag or 49 }
    end

    local scenario = data.scenario or (type(anim) == 'table' and anim.scenario) or nil
    if scenario then
        ClearPedTasks(ped)
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end

    local object
    if type(data.prop) == 'table' and data.prop.model then
        if animation then loadDict(animation.dict) end
        object = attachProp(ped, data.prop)
    end

    local barData = {
        label = data.label or data.title,
        description = data.description or data.text,
        duration = data.duration or data.time or 5000,
        cancelable = data.cancelable == true or data.canCancel == true,
        animation = animation,
        inputBlock = data.inputBlock,
    }

    local p = promise.new()
    startProgressbar(barData, function(finished)
        p:resolve(finished == true)
    end)
    local result = Citizen.Await(p)

    if scenario then ClearPedTasks(ped) end
    if object and DoesEntityExist(object) then DeleteEntity(object) end

    return result
end

---@param data table # { key, label, desc }
KOJA.Client.ShowTextUI = function(data)
    data = data or {}
    -- showTextUI compares desc with the current UI, keep it non nil
    data.desc = data.desc or data.description or data.label or ''
    return showTextUI(data)
end

KOJA.Client.HideTextUI = function()
    return hideTextUI()
end
