Citizen.CreateThread(function()
    local updatePath = "Koja-Scripts/koja-lib"
    local resourceName = GetInvokingResource() or GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
    
    if currentVersion then
        currentVersion = currentVersion:match('%d+%.%d+%.%d+')
    end

    if not currentVersion then 
        return print(("^1[ERROR] Unable to determine the current version of '%s' ^0"):format(resourceName)) 
    end

    SetTimeout(1000, function()
        PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(updatePath), function(status, response)
            if status ~= 200 then 
                return print(("^1[ERROR] Failed to fetch version info for '%s' ^0"):format(resourceName))
            end

            response = json.decode(response)
            if response.prerelease then return end

            local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
            if not latestVersion or latestVersion == currentVersion then 
                return print(("^2✅ %s is up to date! Version: ^3%s^2 | Framework: ^3"..string.upper(KOJA.Framework).."^0"):format(resourceName, currentVersion)) 
            end

            local cv = { string.strsplit('.', currentVersion) }
            local lv = { string.strsplit('.', latestVersion) }

            for i = 1, #cv do
                local current, minimum = tonumber(cv[i]), tonumber(lv[i])

                if current ~= minimum then
                    if current < minimum then
                        return print(("^3🚀 Update available for %s! (Current version: %s) \r\n📥 Download the latest version: %s^0"):format(resourceName, currentVersion, response.html_url))
                    else 
                        break 
                    end
                end
            end
        end, 'GET')
    end)
end)
