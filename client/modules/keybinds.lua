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

function KOJA.registerKeyBind(name, description, key, onPress, onRelease)
    local bind = {
        name = name,
        description = description,
        hash = joaat('+' .. name) | 0x80000000,
        isPressed = false,
        isDisabled = false,
        key = key,
        onPress = onPress,
        onRelease = onRelease
    }

    KeyBinds[name] = setmetatable(bind, keybind_meta)

    RegisterCommand('+' .. name, function()
        if bind.isDisabled or IsPauseMenuActive() then return end
        bind.isPressed = true
        if bind.onPress then bind.onPress() end
    end)

    RegisterCommand('-' .. name, function()
        if bind.isDisabled or IsPauseMenuActive() then return end
        bind.isPressed = false
        if bind.onRelease then bind.onRelease() end
    end)

    RegisterKeyMapping('+' .. name, description, 'keyboard', key)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(name))
    end)

    return bind
end

return KOJA.registerKeyBind
