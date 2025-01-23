fx_version 'cerulean'

name 'KOJA_LIB'
author 'Koja Scripts'
version '1.0.0'
description 'Library to scripts'

lua54 'yes'

games {
    'gta5',
    'rdr3'
}

shared_scripts {
    '@ox_core/lib/init.lua',  -- ❗ Uncomment if you're using ox core
    -- "@es_extended/imports.lua", -- ❗ Uncomment if you're using esx
    --'@ox_lib/init.lua', -- ❗ Comment if you're using ox core
    'editable/shared/config.lua',
    'editable/shared/utils.lua',
}

client_scripts {
    'client/functions.lua',
    'client/threads.lua',
    'client/callbacks.lua',
    'client/utils/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/framework.lua',
    'server/functions.lua',
    'server/callbacks.lua'
}

files {
	'init.lua',
}