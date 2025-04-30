fx_version 'cerulean'
name 'koja-lib'
author 'Koja Scripts'
version '1.0.5'
description 'Library to scripts'
use_fxv2_oal 'true'
lua54 'yes'
games {
    'gta5'
}
shared_scripts {
-- -- -- -- '@es_extended/imports.lua',
'@ox_core/lib/init.lua',
    'editable/shared/config.lua',
    'editable/shared/utils.lua',
}
client_scripts {
    'client/functions.lua',
    'client/threads.lua',
    'client/callbacks.lua',
    'client/modules/*.lua',
    'client/utils/*.lua',
    'client/storage/init.lua',
    'client/storage/storage.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/framework.lua',
    'server/functions.lua',
    'server/callbacks.lua',
    'server/webhook.lua',
    'server/modules/*.lua'
}
files {
	'init.lua',
}