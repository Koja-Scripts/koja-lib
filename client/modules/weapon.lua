---@param PlayerPed number # Player Ped ID
---@return table|nil # Weapon information table or nil
KOJA.Client.getCurrentWeaponInfo = function(PlayerPed)
    local hasWeapon, weaponHash = GetCurrentPedWeapon(PlayerPed, true)

    if hasWeapon and weaponHash ~= `WEAPON_UNARMED` then
        local _, ammoInClip = GetAmmoInClip(PlayerPed, weaponHash)
        local totalAmmo = GetAmmoInPedWeapon(PlayerPed, weaponHash)

        return {
            weaponHash = weaponHash,
            ammoInClip = ammoInClip,
            totalAmmo = totalAmmo
        }
    else
        return nil
    end
end