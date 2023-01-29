fx_version 'cerulean'
game 'gta5'

author 'Cadburry#7547'
version '0.1'
description 'Metadata Vehicle Keys for QBCore'

shared_scripts {
	'config.lua'
}

client_scripts {
	'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

lua54 'yes'