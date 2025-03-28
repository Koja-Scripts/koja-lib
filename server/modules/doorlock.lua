local doorState = {}

RegisterServerEvent('koja-lib:setdoorlockstate', function(name, state)
	if Config.Doorlocksystem == 'ox' then
		local doorlock = exports.ox_doorlock:getDoorFromName(name)
		if doorlock then
			TriggerEvent('ox_doorlock:setState', doorlock.id, state)
		end
	elseif Config.Doorlocksystem == 'standalone' then
		doorState[name] = state
		TriggerClientEvent('koja-lib:setDoorState', -1, name, state)
	end
end)

--'koja-lib:getDoorState'
--	cb(doorState[name])