AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        PlayerIsLoaded = true
    end
end)

