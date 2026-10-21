# Changelog

## [1.3.0] - 2026-10-21

### Security
- **Stashes:** client requests to open a stash (`KOJA.Client.OpenStash`) now check the stash's `groups` (job + grade) on the server. New `opts.coords` / `opts.distance` in `RegisterStash` limit where it can be opened from.
- **Sounds:** client-triggered sounds only accept built-in sound names or `nui://` files; remote `http(s)` URLs are refused.
- **Notifications:** notification descriptions are sanitised in the NUI; only simple formatting (`<b>`, `<i>`, `<u>`, `<br>`, coloured `<span>`) is kept.

### Added
- `KOJA.Server.GetPlayersByJob(job, onDuty)` - list of players with a job (or list of jobs).
- `KOJA.Server.NotifyJob(job, data, onDuty)` - notify every player with a job (dispatch / alerts).
- `KOJA.Server.ChargePlayer(src, amount, accounts, reason)` - charge cash first, then bank (or any account order); returns `success, account`.
- `KOJA.Server.Cooldown(key, src, seconds)` / `KOJA.Server.ResetCooldown(key, src)` - per-player (identifier based) or global cooldowns.
- `KOJA.Client.CancelProgress()` / `KOJA.Client.IsProgressActive()` and the `isProgressbarActive` export.
- `KOJA.Client.GetFuelResource()`.
- Server exports for all the new helpers.

### Fixed - integrations
- **qbx_core:** the core object is taken from `exports['qb-core']` (provided by qbx's bridge); `exports.qbx_core:GetCoreObject` does not exist.
- **qbx_core:** `SetJob` / offline job changes use `exports.qbx_core:SetJob` and return the real result.
- **qb-inventory v2:** `getInventoryItemCount` / `HasItem` no longer crash (`GetItemByName` was removed from qb-core).
- **qb-inventory v2:** adding items to saved stashes after a restart works again (capacity is restored with `CreateInventory`).
- **qb-banking:** society accounts are created when missing (`GetAccountBalance` returns 0 for missing accounts).
- **qb-vehiclekeys:** keys are given through the server `GiveKeys` export.
- **ESX:** server notifications use `esx:showNotification` (they never showed before).
- **ESX:** `HasLicense` uses `esx_license:checkLicense` and answers again.
- **jaksam_inventory:** player inventories are addressed by numeric server id.
- **codem-inventory:** `GetInventory` gets the player identifier; failing exports are no longer reported as success.

### Fixed - server
- `removeInventoryItem` (ESX / QB) returns `false` when the player doesn't have enough items; QB `addInventoryItem` returns the real result.
- QB money accepts ESX account names (`money`, `black`) and returns `false` instead of erroring when the balance is missing.
- Custom framework: `GetPlayers` no longer recurses into itself (stack overflow).
- `GeneratePlate` / `SaveVehicleToGarage` work again (wrong oxmysql calls), use the right table per framework and the stock qb `player_vehicles` columns; plate generation is capped at 50 tries.
- QB `getPlayerGroup` reads permissions from QBCore.
- Cop count skips off-duty officers.

### Fixed - client / UI
- TextUI: duplicate check works (no NUI spam in loops) and no error on the first call without a description.
- Vehicles: `checkVehicleType` no longer errors on bikes, `GetFuel` works and follows `Config.Fuel`, lights and lock state are reported correctly.
- Weapons: ammo in clip is a number, unarmed returns `nil`.
- `Config.Notify = "ox"` no longer errors without ox_lib loaded.
- `TriggerServerCallback`: concurrent calls with the same key no longer overwrite each other.
- Progress bar: no endless wait on a bad animation dict, cancelling really stops it (callback gets `false`), X works even when blocked in `inputBlock`.
- Keybinds: `bind:isPressed()` works, pressed state no longer sticks after the pause menu.
- Storage: event handlers are no longer duplicated, unknown keys don't error.
- Job getters don't error before the character is loaded.
- `/laser` prints coords on **E** instead of every frame.
- Notifications re-sent during their exit animation no longer stay on screen forever.

### CI
- Release workflow: plain version tags (`1.3.0`), changelog section used as release notes.

## [1.2.0]
- Bridge v2: jobs, items, stashes, usable items, target, clothing, vehicle keys, society, sound, await callbacks.
