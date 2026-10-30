Misc.Integrations = {
    fuel = { 'ox_fuel', 'Renewed-Fuel', 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'lc_fuel', 'qs-fuelstations', 'okokGasStation', 'lj-fuel', 'ti_fuel' },
    keys = { 'qbx_vehiclekeys', 'qb-vehiclekeys', 'wasabi_carlock', 'mk_vehiclekeys', 'MrNewbVehicleKeys', 'qs-vehiclekeys', 'Renewed-Vehiclekeys', 'cd_garage', 'okokGarage' },
    target = { 'ox_target', 'qb-target', 'qtarget' },
    clothing = { 'illenium-appearance', 'fivem-appearance', 'qb-clothing', 'skinchanger' },
    banking = { 'Renewed-Banking', 'okokBanking', 'qb-banking', 'qb-management', 'esx_society' },
    dispatch = { 'koja-mdt', 'koja-dispatch', 'ps-dispatch', 'cd_dispatch', 'core_dispatch', 'rcore_dispatch', 'qs-dispatch' },
    phone = { 'lb-phone', 'qs-smartphone', 'qs-smartphone-pro', 'gksphone', 'qb-phone' },
    notify = { 'okokNotify', 'mythic_notify', 'pNotify', 'ox_lib' },
    progress = { 'ox_lib', 'progressbar', 'mythic_progbar', 'rprogress' },
}

Misc.IntegrationConfig = {
    fuel = 'Fuel',
    keys = 'VehicleKeys',
    target = 'Target',
    clothing = 'Clothing',
    banking = 'Banking',
    dispatch = 'Dispatch',
    phone = 'Phone',
}

Misc.Utils.IsStarted = function(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

Misc.Utils.ResolveIntegration = function(kind, fallback)
    local key = Misc.IntegrationConfig[kind]
    local wanted = key and Config[key]
    if type(wanted) == 'table' then wanted = wanted.system end
    wanted = tostring(wanted or 'auto')
    if wanted == 'none' or wanted == 'false' then return 'none' end
    if wanted ~= 'auto' then return wanted end
    for _, resource in ipairs(Misc.Integrations[kind] or {}) do
        if Misc.Utils.IsStarted(resource) then return resource end
    end
    return fallback or 'none'
end
