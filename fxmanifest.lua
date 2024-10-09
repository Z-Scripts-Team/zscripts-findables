fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'zscripts-findables'
author 'Z-Scripts Team'
version '1.0.0'
shared_script {
    'config.lua',
}
server_scripts {
    'server/main.lua',
    'server/arena.lua',
}
client_scripts {
    'client/main.lua',
}
ui_page {
    'html/index.html',
}
files {
    --Nui files
    'html/**',
    --Locales files
    'locales/*.lua',
}
