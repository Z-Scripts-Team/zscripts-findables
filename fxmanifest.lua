fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'zscripts-findables'
author 'Z-Scripts Team'
version '1.0.0'
shared_script {
    --Config
    'config.lua',
    --Callback
    'modules/callback.lua',
    --StateBags
    'modules/statebags.lua',
}
server_scripts {
    --Mysql
    '@oxmysql/lib/MySQL.lua',
    --Config
    'server-functions.lua',
    'server-config.lua',
    --Script
    'server/main.lua',
}
client_scripts {
    --Config
    'client-functions.lua',
    --Script
    'client/main.lua',
}
files {
    --Locales
    'locales/*.lua',
}
dependencies {
    'oxmysql',
}
escrow_ignore {
    'server-functions.lua',
    'server-config.lua',
    'config.lua',
    'config.lua',
    'stream/**',
    'locales/**',
}
