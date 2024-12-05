CreateThread(function()
    while Koja.Framework == nil do
        Koja.Framework = Misc.Utils.GetFramework()
        Wait(1000)
    end
end)
