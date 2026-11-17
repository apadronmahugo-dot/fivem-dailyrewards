fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dailyrewards'
description 'Daily Rewards con rachas - ESX / QBCore / QBox / Standalone'
author 'TU CANAL'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/locales.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/main.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
