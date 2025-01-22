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
    '@ox_lib/init.lua',
    'editable/shared/config.lua',
    'editable/shared/utils.lua',
}

client_scripts {
    'client/functions.lua',
    'client/threads.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/framework.lua',
    'server/functions.lua',
}

files {
	'init.lua',
}