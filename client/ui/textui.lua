local isOpen = false
local currentTextUI = nil

showTextUI = function(data)
    local key = data.key or 'E'
    local label = data.label or 'Action'
    local description = data.desc or data.description or 'Press to perform action'

    if currentTextUI and currentTextUI.key == key and currentTextUI.label == label and currentTextUI.description == description then
        return
    end

    local textUIData = {
        key = key,
        label = label,
        description = description,
        theme = Config.UI.TextUI.theme,
        bottomOffset = Config.UI.TextUI.bottomOffset
    }
    
    KOJA.Client.SendReactMessage('koja-lib:nui:startTextUI', textUIData)
    currentTextUI = textUIData
    isOpen = true
end

hideTextUI = function()
    KOJA.Client.SendReactMessage('koja-lib:nui:closeTextUI')
    isOpen = false
    currentTextUI = nil
end

isTextUIOpen = function()
    return isOpen, currentTextUI
end

exports('showTextUI', showTextUI)
exports('hideTextUI', hideTextUI)
exports('isTextUIOpen', isTextUIOpen)
