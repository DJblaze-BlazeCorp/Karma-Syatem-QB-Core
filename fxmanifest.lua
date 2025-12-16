-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
author 'Generated for Jesse'
description 'QBCore Karma / Reputation System (v1.8.0) - Modular Config System, Event Gating Only, Language Exports, Debug Lang Support, SQL Handler, Command Config, Admin Tools'
version '1.8.0'
shared_scripts {
    'config/config.lua',
    'config/commands.lua',
    'config/gating.lua',
    'config/adding.lua',
    'config/removing.lua',
    'config/lang/*.lua',
    'config/lang/debug/*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
client_scripts {
    'client.lua'
}
lua54 'yes'
