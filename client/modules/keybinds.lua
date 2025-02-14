local KeyBinds = {}

local IsPauseMenuActive = IsPauseMenuActive
local GetControlInstructionalButton = GetControlInstructionalButton

local keybind_meta = {
    isDisabled = false,
    isPressed = false,
    key = '',
    mapper = 'keyboard',
}

function keybind_meta:__index(index)
    return index == 'key' and self:getKey() or keybind_meta[index]
end

function keybind_meta:getKey()
    return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

function keybind_meta:isPressed()
    return self.isPressed
end

function keybind_meta:disable(state)
    self.isDisabled = state
end

function KOJA.registerKeyBind(data)
    local bind = {
        name = data.name,
        description = data.description,
        hash = joaat('+' .. data.name) | 0x80000000,
        isPressed = false,
        isDisabled = false,
        key = data.key,
        onPress = data.onPress,
        onRelease = data.onRelease
    }

    KeyBinds[data.name] = setmetatable(bind, keybind_meta)

    RegisterCommand('+' .. data.name, function()
        if bind.isDisabled or IsPauseMenuActive() then return end
        bind.isPressed = true
        if bind.onPress then bind.onPress() end
    end)

    RegisterCommand('-' .. data.name, function()
        if bind.isDisabled or IsPauseMenuActive() then return end
        bind.isPressed = false
        if bind.onRelease then bind.onRelease() end
    end)

    RegisterKeyMapping('+' .. data.name, data.description, 'keyboard', data.key)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    return bind
end

return KOJA.registerKeyBind
