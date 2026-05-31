fx_version 'cerulean'
name 'koja-lib'
author 'Koja Scripts'
version '1.1.0'
description 'Library to scripts'
use_fxv2_oal 'true'
lua54 'yes'
games {
    'gta5'
}
shared_scripts {
    '@es_extended/imports.lua',
    'editable/shared/config.lua',
    'editable/shared/utils.lua',
    'editable/shared/inventory.lua',
}
client_scripts {
    'editable/custom/framework_client.lua',
    'editable/custom/inventory_client.lua',
    'client/functions.lua',
    'client/threads.lua',
    'client/callbacks.lua',
    'client/modules/*.lua',
    'client/utils/*.lua',
    'client/storage/init.lua',
    'client/storage/storage.lua',
    'client/ui/*.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'editable/custom/framework_server.lua',
    'editable/custom/inventory_server.lua',
    'server/framework.lua',
    'server/functions.lua',
    'server/callbacks.lua',
    'server/webhook.lua',
    'server/modules/*.lua',
}
files {
    'init.lua',
}
ui_page 'web/build/index.html'
files {
    'web/build/index.html',
    'web/build/**/*',
    'web/build/**/**/*',
    'web/build/sounds/*.mp3',
}
