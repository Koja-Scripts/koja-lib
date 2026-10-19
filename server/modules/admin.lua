---@param src number # Player ID (0 = server console)
---@param groups table|nil # Allowed framework groups (defaults to Config.Admin.Groups)
---@param ace string|nil # ACE permission to check (defaults to Config.Admin.Ace)
---@param identifiers table|nil # Whitelisted identifiers (license:..., discord:..., citizenid/ESX identifier)
---@return boolean # Whether the player counts as an admin
KOJA.Server.IsAdmin = function(src, groups, ace, identifiers)
    src = tonumber(src)
    if not src then return false end
    if src == 0 then return true end
    if src < 0 then return false end

    local settings = Config.Admin or {}
    ace = ace or settings.Ace
    groups = groups or settings.Groups or {}
    identifiers = identifiers or settings.Identifiers or {}

    if ace and ace ~= '' and IsPlayerAceAllowed(src, ace) then
        return true
    end

    if #identifiers > 0 then
        local wanted = {}
        for _, identifier in ipairs(identifiers) do
            wanted[identifier] = true
        end
        for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
            if wanted[identifier] then return true end
        end
        local okId, character = pcall(KOJA.Server.GetPlayerIdentifier, src)
        if okId and character and wanted[character] then return true end
    end

    if #groups > 0 then
        local fn = _G.isGroupAdmin
        if type(fn) == 'function' then
            local ok, result = pcall(fn, src, groups)
            if ok and result then return true end
        end
        for _, group in ipairs(groups) do
            if IsPlayerAceAllowed(src, group) or IsPlayerAceAllowed(src, 'group.' .. group) then
                return true
            end
        end
    end

    return false
end
