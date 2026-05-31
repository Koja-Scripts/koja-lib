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

---

<sub>Made by Koja Scripts</sub>
