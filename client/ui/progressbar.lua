local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

startProgressbar = function(data, callback)
    local progressData = {
        label = data.label or data.title or 'Loading...',
        description = data.description or data.text or 'Please wait...',
        duration = (data.duration or data.time or 5000) / 1000,
        theme = Config.UI.ProgressBar.theme,
        bottomOffset = Config.UI.ProgressBar.bottomOffset
    }

    KOJA.Client.SendReactMessage("koja-lib:nui:startProgressBar", progressData)
    
    local playerPed = PlayerPedId()
    local duration = (data.duration or data.time or 5000)
    
    if data.animation and data.animation.dict and data.animation.name then
        RequestAnimDict(data.animation.dict)
        while not HasAnimDictLoaded(data.animation.dict) do
            Wait(10)
        end
        local animFlag = data.animation.flag ~= nil and data.animation.flag or 1
        TaskPlayAnim(playerPed, data.animation.dict, data.animation.name, 8.0, -8.0, duration, animFlag, 0, false, false, false)
    end
    
    CreateThread(function()
        local startTime = GetGameTimer()
        local isCanceled = false
        
        while (GetGameTimer() - startTime) < duration do
            if data.inputBlock and data.inputBlock.keys then
                for _, key in ipairs(data.inputBlock.keys) do
                    if Keys[key] then
                        DisableControlAction(0, Keys[key], true)
                    end
                end
            end
            
            if data.cancelable and IsControlJustPressed(0, 73) then
                isCanceled = true
                break
            end
            
            Wait(5)
        end
        
        if isCanceled then
            cancelProgressbar()
            ClearPedTasks(playerPed)
            if callback then callback(false) end
        else
            ClearPedTasks(playerPed)
            if callback then callback(true) end
        end
    end)
end

cancelProgressbar = function()
    KOJA.Client.SendReactMessage("koja-lib:nui:hideProgressBar")
end

exports("startProgressbar", function(data, cb)
    startProgressbar(data, cb)
end)
exports("cancelProgressbar", cancelProgressbar)

