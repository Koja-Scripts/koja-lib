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
    '@es_extended/imports.lua', -- ❗ Uncomment if you're using esx
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua',
}

client_scripts {
    -- '@ox_core/imports/client.lua', -- ❗ Uncomment if you're using ox core
    'client/cam.lua',
    'client/utils.lua',
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/nui.lua',
    'client/threads.lua'
}

server_scripts {
    -- '@ox_core/imports/server.lua', -- ❗ Uncomment if you're using ox core
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*',
    'web/build/**/**/*',
    'locales/en.json'
}