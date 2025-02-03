if not Config.CustomFramework then

    if GetResourceState('es_extended') == 'started' then     

        local ESX = exports['es_extended']:getSharedObject()

        local convertMoney = {
            ["cash"] = "money",
            ["bank"] = "bank"
        }

        GetPlayers = function()
            return ESX.GetPlayers()
        end

        getPlayer = function(src)
            return ESX.GetPlayerFromId(src)
        end

        getIdentifier = function(src)
            local Player = getPlayer(src)
            return Player.identifier
        end

        getPlayerJob = function(src)
            local Player = getPlayer(src)
            return Player.job.name, Player.job.grade
        end

        getMoney = function(src, mtype)
            local Player = getPlayer(src)
            if not Player then return end
            mtype = convertMoney[mtype] or mtype
            return Player.getAccount(mtype).money
        end

        removeMoney = function(src, amount, mtype, reason)
            local mtype = convertMoney[mtype] or mtype

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            if Player.getAccount(mtype).money < amount then
                return false
            end

            Player.removeAccountMoney(mtype, amount, reason)
            return true
        end

        addInventoryItem = function(src, name, count)

            local Player = getPlayer(src)
            if not Player then
                return false
            end

            Player.addInventoryItem(name, count)

            return true
        end

    elseif GetResourceState('ox_core') == 'started' then

        print('[^2KOJA_LIB^7] INITIALIZING FRAMEWORK: ^1OX^7')

        GetPlayers = function()
            return Ox.GetPlayers()
        end

        getPlayer = function(id)
            return Ox.GetPlayer(id)
        end
        
        getIdentifier = function(src)
            local player = getPlayer(src)
            return player.identifier
        end
        
        getPlayerJob = function(src)
            local player = getPlayer(src)
            return player.getGroup()
        end
        
        getMoney = function(src, mtype)
            if mtype == 'cash' then
                return exports.ox_inventory:GetItemCount(src, 'money')
            else
                return
            end
        end
        
        removeMoney = function(src, amount, mtype, reason)
            if mtype == 'cash' then
                return exports.ox_inventory:RemoveItem(src, 'money', amount)
            else
                return
            end
        end

        addInventoryItem = function(src, name, count)
            exports.ox_inventory:AddItem(src, name, count)
            return true
        end

    elseif GetResourceState('qb-core') == 'started' then

        local QBCore = exports['qb-core']:GetCoreObject()

        getPlayers = function()
            return QBCore.Functions.GetPlayers()
        end

        getPlayer = function(src)
            return QBCore.Functions.GetPlayer(src)
        end

        getIdentifier = function(src)
            local player = getPlayer(src)
            return player.PlayerData.citizenid
        end

        getPlayerJob = function(src)
            local player = getPlayer(src)
            return player.PlayerData.job.name, player.PlayerData.job.grade.level
        end

        getMoney = function(src, mtype)
            local player = getPlayer(src)
            if not player then return end
            return player.PlayerData.money[mtype]
        end

        removeMoney = function(src, amount, mtype, reason)
            local player = getPlayer(src)
            if not player then return end

            if player.PlayerData.money[mtype] < amount then
                return
            end

            return player.Functions.RemoveMoney(mtype, amount, reason or "unknown")
        end

        addInventoryItem = function(src, name, count)
            exports.ox_inventory:AddItem(src, name, count)
            return true
        end

    end
else

    GetPlayers = function()
        return --
    end

    getPlayer = function(src)
        return --
    end

    getIdentifier = function(src)
        return --
    end

    getPlayerJob = function(src)
        return --
    end

    getMoney = function(src, mtype)
        return --
    end

    removeMoney = function(src, amount, mtype, reason)
        return --
    end

end