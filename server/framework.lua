if GetResourceState('es_extended') == 'started' then
    
    print('[^2KOJA_LIB^7] INITIALIZING FRAMEWORK: ^1ESX^7')

    local ESX = exports['es_extended']:getSharedObject()

    local convertMoney = {
        ["cash"] = "money",
        ["bank"] = "bank"
    }

    getPlayer = function(src)
        return ESX.GetPlayerFromId(src)
    end

    getCharID = function(src)
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

elseif GetResourceState('ox_core') == 'started' then

    print('[^2KOJA_LIB^7] INITIALIZING FRAMEWORK: ^1OX^7')

    function getPlayer(id)
        return Ox.GetPlayer(id)
    end
    
    function getCharID(src)
        local player = getPlayer(src)
        return player.charId
    end
    
    function getPlayerJob(src)
        local player = getPlayer(src)
        return player.getGroup()
    end
    
    function getMoney(src, mtype)
        if mtype == 'cash' then
            return exports.ox_inventory:GetItemCount(src, 'money')
        else
            return
        end
    end
    
    function removeMoney(src, amount, mtype, reason)
        if mtype == 'cash' then
            return exports.ox_inventory:RemoveItem(src, 'money', amount)
        else
            return
        end
    end

elseif GetResourceState('qb-core') == 'started' then

    print('[^2KOJA_LIB^7] INITIALIZING FRAMEWORK: ^1QB^7')

    local QBCore = exports['qb-core']:GetCoreObject()

    function getPlayer(src)
        return QBCore.Functions.GetPlayer(src)
    end

    function getCharID(src)
        local player = getPlayer(src)
        return player.PlayerData.citizenid
    end

    function getPlayerJob(src)
        local player = getPlayer(src)
        return player.PlayerData.job.name, player.PlayerData.job.grade.level
    end

    function getMoney(src, mtype)
        local player = getPlayer(src)
        if not player then return end
        return player.PlayerData.money[mtype]
    end

    function removeMoney(src, amount, mtype, reason)
        local player = getPlayer(src)
        if not player then return end

        if player.PlayerData.money[mtype] < amount then
            return
        end

        return player.Functions.RemoveMoney(mtype, amount, reason or "unknown")
    end

end
