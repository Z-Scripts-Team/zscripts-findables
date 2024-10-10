fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'zscripts-findables'
author 'Z-Scripts Team'
version '1.0.0'
shared_script {
    'config.lua',

    'modules/callback.lua',
    'modules/statebags.lua',
}
server_scripts {
    'server-config.lua',

    'server/main.lua',
}
client_scripts {
    'client/main.lua',
}
