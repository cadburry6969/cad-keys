fx_version 'cerulean'
game 'gta5'

author 'Cadburry#7547'
version '0.1.0'
description 'NUI Vehicle Keys for QBCore Based Servers'

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

escrow_ignore {
	'config.lua',
	'client/cl_customise.lua',
	'server/sv_customise.lua',
}

lua54 'yes'