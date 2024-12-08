fx_version 'cerulean'
game 'gta5'

author 'Dijkslag'
description 'A Team Death Match Script'
version '1.0.0'

shared_script 'config.lua' 

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

dependencies {
    'qb-core',
    'qb-target'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
