KOJA.Server.Banner = {}
KOJA.Server.Banner.notes = {}

local resourceName = GetCurrentResourceName()
local RULE = '^9' .. string.rep('─', 64) .. '^0'

local FRAMEWORKS = {
    { resource = 'qbx_core', label = 'Qbox' },
    { resource = 'es_extended', label = 'ESX' },
    { resource = 'qb-core', label = 'QBCore' },
}

local function version(resource)
    local value = GetResourceMetadata(resource, 'version', 0)
    return value and value:match('%d+%.%d+%.?%d*') or nil
end

local function frameworkLabel()
    for _, entry in ipairs(FRAMEWORKS) do
        if GetResourceState(entry.resource) == 'started' then
            local number = version(entry.resource)
            return number and ('%s %s'):format(entry.label, number) or entry.label
        end
    end
    return KOJA.Framework == 'custom' and 'custom bridge' or 'not detected'
end

local function kojaResources()
    local count = 0
    for index = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(index)
        if name and name ~= resourceName and GetResourceState(name) == 'started' then
            local author = (GetResourceMetadata(name, 'author', 0) or ''):lower()
            if author:find('koja', 1, true) or GetResourceMetadata(name, 'koja_resource', 0) then count = count + 1 end
        end
    end
    return count
end

local function notifyLabel()
    local names = { esx = 'esx', qb = 'qb-core', ox = 'ox_lib', lib = 'koja-lib', okok = 'okokNotify', mythic = 'mythic_notify', pnotify = 'pNotify' }
    return names[tostring(Config.Notify)] or tostring(Config.Notify or 'custom')
end

local function inventoryLabel()
    local name = KOJA.Inventory or Misc.Utils.GetInventory()
    return name == 'framework' and 'framework items' or name
end

local function cell(label, value)
    local shown = value == 'none' and '^9—^0' or ('^0' .. value)
    local width = value == 'none' and 1 or #value
    return ('^9%-10s%s%s'):format(label, shown, string.rep(' ', math.max(1, 22 - width)))
end

KOJA.Server.Banner.Note = function(message)
    KOJA.Server.Banner.notes[#KOJA.Server.Banner.notes + 1] = message
end

KOJA.Server.Banner.Print = function()
    local items = {
        { 'inventory', inventoryLabel() },
        { 'target', Misc.Utils.ResolveIntegration('target') },
        { 'notify', notifyLabel() },
        { 'fuel', Misc.Utils.ResolveIntegration('fuel', 'native') },
        { 'keys', Misc.Utils.ResolveIntegration('keys') },
        { 'banking', Misc.Utils.ResolveIntegration('banking') },
        { 'clothing', Misc.Utils.ResolveIntegration('clothing') },
        { 'dispatch', Misc.Utils.ResolveIntegration('dispatch') },
        { 'phone', Misc.Utils.ResolveIntegration('phone') },
    }

    local count = kojaResources()
    print(RULE)
    print(('^5  KOJA LIB  ^0v%s   ^9%s   ·   %d Koja resource%s^0'):format(version(resourceName) or '?', frameworkLabel(), count, count == 1 and '' or 's'))
    for index = 1, #items, 3 do
        local row = { '  ' }
        for offset = 0, 2 do
            local item = items[index + offset]
            if item then row[#row + 1] = cell(item[1], item[2]) end
        end
        print(table.concat(row) .. '^0')
    end
    for _, note in ipairs(KOJA.Server.Banner.notes) do
        print(('  ^3%s^0'):format(note))
    end
    print(RULE)
end

CreateThread(function()
    Wait(1500)
    KOJA.Server.Banner.Print()
end)
