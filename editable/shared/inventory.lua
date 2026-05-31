-- Inventory detection (shared).
-- Resolves which inventory resource the server is running and exposes the
-- result through Misc.Utils.GetInventory(). The framework bridge (server &
-- client) uses this to pick the correct adapter, falling back to the active
-- framework's native item functions when no dedicated adapter is available.

-- Order matters: the first resource found in the "started" state wins.
-- ox_inventory is checked first because it is the most common and is the only
-- one of the group that does NOT keep the framework's native item functions.
Misc.Utils.SupportedInventories = {
    'ox_inventory',
    'qb-inventory',
    'codem-inventory',
    'jaksam_inventory',
}

---@return string # Inventory resource name, 'custom', or 'framework' when none is detected
Misc.Utils.GetInventory = function()
    local override = Config and Config.Inventory

    if override == 'custom' then
        return 'custom'
    end

    if override and override ~= '' and override ~= 'auto' then
        if GetResourceState(override) == 'started' then
            return override
        end
        print(('^3[koja-lib]^0 Config.Inventory is set to "%s" but that resource is not started — falling back to auto-detection.'):format(override))
    end

    for _, resource in ipairs(Misc.Utils.SupportedInventories) do
        if GetResourceState(resource) == 'started' then
            return resource
        end
    end

    return 'framework'
end
