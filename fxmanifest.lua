fx_version 'cerulean'
game 'gta5'
description 'Multiple leveling robberies for QBCore'
version '1.0.0'
client_scripts {
    'client/client.lua',
    'client/fleeca.lua',
    'client/vangelico.lua',
    'client/paleto.lua',
    'client/pacific.lua',
}
server_scripts {
    'server/server.lua',
    'server/fleeca.lua',
    'server/vangelico.lua',
    'server/paleto.lua',
    'server/pacific.lua',
    '@oxmysql/lib/MySQL.lua'
}
shared_script {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locations.lua',
    'shared/missions.lua',
    'locale/en.lua'
}
escrow_ignore {
    "images/**",
    "shared/**.lua",
    "locale/**.lua",
    "README.md",
}
lua54 'yes'