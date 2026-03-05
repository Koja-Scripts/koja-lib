local isOpen = false
local currentTextUI = nil

showTextUI = function(data)
    if currentTextUI == data.desc and currentTextUI.key == data.key then
        return 
    end
    local textUIData = {
        key = data.key or 'E',
        label = data.label or 'Action',
        description = data.desc or 'Press to perform action',
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
