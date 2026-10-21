<div align="center">

# 🧩 koja-lib

**A developer-first FiveM library built to take the boilerplate out of script development.**

[![Latest release](https://img.shields.io/github/v/release/Koja-Scripts/koja-lib?style=for-the-badge&color=B8DBF4&labelColor=0d1117&label=release)](https://github.com/Koja-Scripts/koja-lib/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Koja-Scripts/koja-lib/total?style=for-the-badge&color=B1FEA1&labelColor=0d1117)](https://github.com/Koja-Scripts/koja-lib/releases)
[![Stars](https://img.shields.io/github/stars/Koja-Scripts/koja-lib?style=for-the-badge&color=FFDA60&labelColor=0d1117)](https://github.com/Koja-Scripts/koja-lib/stargazers)
[![Views](https://hits.sh/github.com/Koja-Scripts/koja-lib.svg?style=for-the-badge&label=views&color=c792ea&labelColor=0d1117)](https://hits.sh/github.com/Koja-Scripts/koja-lib/)

[![Release workflow](https://img.shields.io/github/actions/workflow/status/Koja-Scripts/koja-lib/release.yml?style=flat-square&label=build&labelColor=0d1117)](https://github.com/Koja-Scripts/koja-lib/actions/workflows/release.yml)
[![Last commit](https://img.shields.io/github/last-commit/Koja-Scripts/koja-lib?style=flat-square&labelColor=0d1117)](https://github.com/Koja-Scripts/koja-lib/commits/main)
![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat-square&logo=lua&logoColor=white&labelColor=0d1117)
![FiveM](https://img.shields.io/badge/FiveM-cerulean-F40552?style=flat-square&labelColor=0d1117)

![ESX](https://img.shields.io/badge/ESX-supported-success?style=flat-square&labelColor=0d1117)
![QBCore](https://img.shields.io/badge/QBCore-supported-success?style=flat-square&labelColor=0d1117)
![QBX](https://img.shields.io/badge/QBX_Core-supported-success?style=flat-square&labelColor=0d1117)

<br>

<a href="https://github.com/Koja-Scripts/koja-lib/releases/latest/download/koja-lib.zip"><img src="https://img.shields.io/badge/⬇_Download_koja--lib.zip-B8DBF4?style=for-the-badge&labelColor=0d1117" alt="Download koja-lib.zip" height="40"></a>

<br>

[📖 Documentation](https://docs.kojascripts.eu/) · [💬 Discord](https://discord.gg/kojascripts) · [🐛 Report a bug](https://github.com/Koja-Scripts/koja-lib/issues) · [📦 All releases](https://github.com/Koja-Scripts/koja-lib/releases)

</div>

---

koja-lib gives you a single, consistent API across **ESX**, **QBCore** and **QBX Core** — so your scripts work everywhere without framework-specific branches. Inventory systems, money, players, notifications, sounds, UI components — all covered, all unified.

## ✨ What's inside

| | Feature | Description |
|---|---|---|
| 🧱 | **Multi-framework** | ESX, QBCore, QBX Core, or your own custom implementation |
| 🎒 | **Multi-inventory** | ox_inventory, qb-inventory, codem-inventory, jaksam_inventory with full auto-detection |
| 🔗 | **Unified API** | The same function calls regardless of what the server runs underneath |
| 🔊 | **Sounds** | NUI-based audio player with distance falloff, supports files from any resource |
| 🖥️ | **UI components** | Progress bar, Text UI, notifications, DUI dynamic textures |
| 📍 | **Points system** | Coordinate-based trigger zones with enter/exit/nearby callbacks |
| ⌨️ | **Keybinds** | Rebindable keys via the GTA V settings menu |
| 🔁 | **Callbacks** | Clean client ↔ server callback system (incl. awaitable) |
| 🗄️ | **Storage** | Reactive client-side key-value store with server-push updates |
| 📨 | **Webhooks** | Built-in Discord logging |

## 🔌 Auto-detected integrations

Everything is set to `'auto'` by default in `editable/shared/config.lua` — koja-lib picks up whatever your server runs.

| Category | Supported |
|---|---|
| Framework | `es_extended` · `qb-core` · `qbx_core` · custom |
| Inventory | `ox_inventory` · `qb-inventory` · `codem-inventory` · `jaksam_inventory` · custom |
| Target | `ox_target` · `qb-target` |
| Banking / society | `Renewed-Banking` · `okokBanking` · `qb-banking` · `qb-management` · `esx_society` |
| Vehicle keys | `qbx_vehiclekeys` · `qb-vehiclekeys` · `wasabi_carlock` · `mk_vehiclekeys` |
| Clothing | `illenium-appearance` · `fivem-appearance` · `qb-clothing` · `esx_skin` |
| Fuel | `ox_fuel` · `LegacyFuel` · `cdn-fuel` · `ps-fuel` · `lc_fuel` · native |
| Sound | `xsound` · built-in NUI player |

## 📥 Installation

1. Download **[koja-lib.zip](https://github.com/Koja-Scripts/koja-lib/releases/latest/download/koja-lib.zip)** from the latest release — the UI is already built.
2. Extract it into your server's `resources` folder (the folder must be named `koja-lib`).
3. Add it to `server.cfg` after your framework and `oxmysql`:

```cfg
ensure oxmysql
ensure es_extended   # or qb-core / qbx_core
ensure koja-lib
```

> [!WARNING]
> Don't use *Code → Download ZIP* / *Source code (zip)* — that's the raw source without the built UI (`web/build`).

## ⚡ Quick look

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

## 🧰 Bridge functions (v2)

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

<details>
<summary><b>🚀 Publishing a release (maintainers)</b></summary>

1. Bump `version` in `fxmanifest.lua` and push to `main`.
2. Either push a matching tag (`git tag v1.2.1 && git push origin v1.2.1`) or run the **Release** workflow manually from the Actions tab — it builds the NUI, packages `koja-lib.zip` and publishes the release.

</details>

## 💬 Support

Head over to the **[full documentation](https://docs.kojascripts.eu/)** for configuration and the complete API reference.
Need help or want to follow updates? Join the **[Discord](https://discord.gg/kojascripts)** — support tickets are open there.

If koja-lib saves you time, consider leaving a ⭐ — it really helps!

---

<div align="center">
<sub>Made with ❤️ by <b>Koja Scripts</b></sub>
</div>
