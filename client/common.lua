AddEventHandler('koja:getSharedObject', function(cb)
	cb(KOJA)
end)

exports('getSharedObject', function()
	return KOJA
end)
