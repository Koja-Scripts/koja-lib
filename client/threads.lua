CreateThread(function()
    while KOJA.Framework == nil do
        KOJA.Framework = Misc.Utils.GetFramework()
        Wait(1000)
    end
end)
