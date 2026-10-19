---Client side of the stash API.
---Every inventory is opened by the server (KOJA.Server.OpenStash). A client request is only honoured for stashes
---registered with KOJA.Server.RegisterStash(..., { clientOpen = true }).
---Without any inventory resource a small native menu (arrows / enter / backspace) is shown.

---@param id string # Stash identifier (must be registered with KOJA.Server.RegisterStash and opts.clientOpen = true)
---@return boolean
KOJA.Client.OpenStash = function(id)
    if not id then return false end
    id = tostring(id)
    TriggerServerEvent('koja:Server:OpenStash', id)
    return true
end

-- Legacy qb-inventory (ps / lj) stash opening
RegisterNetEvent('koja:Client:OpenLegacyStash', function(id, label, slots, weight)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', id, { maxweight = weight, slots = slots })
    TriggerEvent('inventory:client:SetCurrentStash', id)
end)

-- Fallback menu --------------------------------------------------------------------------------------

local menu = nil -- { data, page = 'main'|'deposit', index = 1 }

local function drawText(text, x, y, scale, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r or 255, g or 255, b or 255, a or 255)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

local function currentRows()
    local rows = {}
    if menu.page == 'main' then
        rows[#rows + 1] = { label = 'Deposit items', page = 'deposit' }
        for _, entry in ipairs(menu.data.items or {}) do
            rows[#rows + 1] = { label = ('%s  x%d'):format(entry.label or entry.name, entry.count or 0), direction = 'take', item = entry.name, max = entry.count or 0 }
        end
    else
        rows[#rows + 1] = { label = 'Back', page = 'main' }
        for _, entry in ipairs(menu.data.inventory or {}) do
            rows[#rows + 1] = { label = ('%s  x%d'):format(entry.label or entry.name, entry.count or 0), direction = 'put', item = entry.name, max = entry.count or 0 }
        end
    end
    return rows
end

local function closeMenu()
    if not menu then return end
    menu = nil
    TriggerServerEvent('koja:Server:StashClose')
end

local function runMenu()
    CreateThread(function()
        local amount = 1
        local lastIndex = 0
        while menu do
            local rows = currentRows()
            if menu.index > #rows then menu.index = #rows end
            if menu.index < 1 then menu.index = 1 end
            if menu.index ~= lastIndex then amount = 1 lastIndex = menu.index end

            DisableAllControlActions(0)
            local x, y = 0.04, 0.2
            DrawRect(x + 0.1, y + 0.2, 0.22, 0.46, 10, 10, 10, 200)
            drawText(menu.data.label or 'Stash', x + 0.01, y - 0.015, 0.55)
            drawText(('Slots %d / %d'):format(menu.data.used or 0, menu.data.slots or 0), x + 0.01, y + 0.025, 0.32, 180, 180, 180)

            local first = math.max(1, math.min(menu.index - 6, #rows - 11))
            for i = first, math.min(#rows, first + 11) do
                local row = rows[i]
                local selected = i == menu.index
                local text = row.label
                if selected and row.direction then text = ('%s   [< %d >]'):format(text, amount) end
                drawText(text, x + 0.01, y + 0.06 + (i - first) * 0.028, 0.34, selected and 255 or 200, selected and 220 or 200, selected and 90 or 200)
            end
            drawText('Arrows: move / amount   Enter: confirm   Backspace: close', x + 0.01, y + 0.41, 0.26, 150, 150, 150)

            if IsDisabledControlJustPressed(0, 172) then menu.index = menu.index - 1
            elseif IsDisabledControlJustPressed(0, 173) then menu.index = menu.index + 1
            elseif IsDisabledControlJustPressed(0, 174) then amount = math.max(1, amount - (IsDisabledControlPressed(0, 21) and 10 or 1))
            elseif IsDisabledControlJustPressed(0, 175) then
                local row = rows[menu.index]
                amount = math.min(row and row.max or 1, amount + (IsDisabledControlPressed(0, 21) and 10 or 1))
            elseif IsDisabledControlJustPressed(0, 191) then
                local row = rows[menu.index]
                if row and row.page then
                    menu.page = row.page
                    menu.index = 1
                elseif row and row.direction then
                    TriggerServerEvent('koja:Server:StashMove', menu.data.id, row.direction, row.item, math.min(amount, row.max))
                end
            elseif IsDisabledControlJustPressed(0, 177) then
                closeMenu()
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('koja:Client:FallbackStash', function(data)
    if type(data) ~= 'table' then return end
    if menu then
        menu.data = data
        return
    end
    menu = { data = data, page = 'main', index = 1 }
    runMenu()
end)
