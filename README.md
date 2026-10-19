# koja-lib

**A developer-first FiveM library built to take the boilerplate out of script development.**

koja-lib gives you a single, consistent API across ESX, QBCore, and QBX Core — so your scripts work everywhere without framework-specific branches. Inventory systems, money, players, notifications, sounds, UI components — all covered, all unified.

---

## What's inside

- **Multi-framework support** — ESX, QBCore, QBX Core, or your own custom implementation
- **Multi-inventory support** — ox_inventory, qb-inventory, codem-inventory, jaksam_inventory with full auto-detection
- **Unified API** — the same function calls regardless of what the server runs underneath
- **Sounds** — NUI-based audio player with distance falloff, supports files from any resource
- **UI components** — progress bar, Text UI, notifications, DUI dynamic textures
- **Points system** — coordinate-based trigger zones with enter/exit/nearby callbacks
- **Keybinds** — rebindable keys via the GTA V settings menu
- **Callbacks** — clean client ↔ server callback system
- **Storage** — reactive client-side key-value store with server-push updates
- **Webhooks** — built-in Discord logging

---

## Quick look

```lua
-- Works on ESX, QBCore, and QBX Core — no changes needed
local job   = KOJA.Server.GetPlayerJob(source)
local count = KOJA.Server.getInventoryItemCount(source, 'lockpick')

if job.name == 'police' and KOJA.Server.HasItem(source, 'handcuffs') then
    KOJA.Server.addMoney(source, 500, 'cash')
    KOJA.Server.SendNotify({ source = source, type = 'success', desc = 'Bonus paid.' })
end
```

```lua
-- Client side
KOJA.Client.points.new({
    coords   = vector3(100.0, 200.0, 30.0),
    distance = 2.0,
    onEnter  = function() showTextUI({ key = 'E', label = 'Interact' }) end,
    onExit   = function() hideTextUI() end,
})
```

---

## Getting started

Head over to the **[full documentation](https://docs.kojascripts.eu/)** for installation, configuration, and the complete API reference.

Need help or want to follow updates? Join the **[Discord](https://discord.gg/kojascripts)** — support tickets are open there.

## Bridge functions (v2)

Everything is available through `KOJA = exports['koja-lib']:getSharedObject()` (or `@koja-lib/init.lua`). All integrations are optional and wrapped in `pcall`; defaults live in `editable/shared/config.lua` (`Config.Inventory`, `Config.Banking`, `Config.Target`, ...). Inventory detection is shared with the inventory bridge (`Config.Inventory`, `editable/shared/inventory.lua`).

**Server**
- Jobs: `GetJobInfo`, `SetJob`, `SetOfflineJob`, `SetJobDuty`, `GetJobs`, `GetSourceByIdentifier`, `GetGender`, `IsAdmin(src, groups, ace, identifiers)`
- Items: `addInventoryItem(src, name, count, metadata)`, `removeInventoryItem(src, name, count, metadata, slot)`, `CanCarryItem`, `GetItemsByName`, `GetItemList`, `GetItemLabel`, `GetItemImage`, `RegisterUsableItem(name, fn(src, item, metadata, slot))`
- Stash: `RegisterStash` (optional `opts.clientOpen = true` to allow `KOJA.Client.OpenStash`; default server-side opening only), `OpenStash`, `AddStashItem`, `RemoveStashItem`, `GetStashItems`, `GetStashItemCount`
- Other: `SyncSocietyBalance(account, balance)`, `GiveVehicleKeys(src, plate, netId)`
- `LogMessage(data, hook)` accepts a raw https url as `hook`, `data.fields` and `data.color`

**Client**
- `AwaitServerCallback(key, payload, timeoutMs)` (request-id based, nil on timeout)
- `Progress(data)` (blocking, returns bool), `ShowTextUI(data)`, `HideTextUI()`
- `RequestModel`, `RequestAnimDict`, `GetVehicleProperties`, `SetVehicleProperties`, `GetClosestVehicle`, `SetFuel`, `GiveVehicleKeys`, `GetGender`
- `Target.Name`, `Target.GetName()`, `Target.AddSphere/AddBox/Remove/AddLocalEntity/RemoveLocalEntity`
- `Clothing.GetAppearance/ApplyOutfit/RestoreCivilian`
- `OpenStash(id)`
- `Sound.Available/PlayUrlPos/SetVolume/SetDistance/SetPosition/SetTimeStamp/Stop/Exists`

**Usable items with ox_inventory:** the item needs to be usable (`consume = 0` in the item definition) so ox fires `ox_inventory:usedItem`, or use `server = { export = 'koja-lib.useItem' }`.

**Custom framework / inventory:** the v2 helpers have optional override hooks in `editable/custom/framework_server.lua` (`GetJobInfo`, `SetJob`, `SetOfflineJob`, `SetJobDuty`, `GetJobs`, `GetSourceByIdentifier`, `GetGender`, `IsGroupAdmin`, `RegisterUsableItem`) and `editable/custom/inventory_server.lua` (`CanCarryItem`, `GetItemsByName`, `GetItemList`, optional stash hooks `RegisterStash` / `OpenStash` / `AddStashItem` / `RemoveStashItem` / `GetStashItems`).

**Sound:** `KOJA.Client.Sound.*` uses xsound when it is running and falls back to the built-in NUI sound player otherwise.

---

<sub>Made by Koja Scripts</sub>
