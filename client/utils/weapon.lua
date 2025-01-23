KOJA.Client.getCurrentWeaponInfo = function(PlayerPed)
    local _, weaponHash = GetCurrentPedWeapon(PlayerPed, true)

    if weaponHash then
        local ammoInClip = GetAmmoInClip(PlayerPed, weaponHash)
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