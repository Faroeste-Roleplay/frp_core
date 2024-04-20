fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	
	"data/allowlistRoles.lua",
	"data/permissions.lua",
	---------------------
	"lib/utils.lua",
	"lib/i18n.lua",

	"locale/*.lua"
}

client_scripts {
	"data/components.lua",
	"data/overlays.js",
	---------------------
	"lib/ReadDataFiles.lua",
	---------------------
	"client/_main.lua",
	"client/functions.lua",
	---------------------
	"client/ped.lua",
	"client/player.lua",
	"client/shared.lua",
	"client/events.lua",
	"client/wrapper.lua",
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	"lib/deferalsCard.lua",

    '@logs/import.lua',
	---------------------
	"server/database.lua",
	"server/_main.lua",
	"server/auth.lua",
	"server/events.lua",
	"server/functions.lua",
	"server/gui.lua",
	-----------------------
	"server/services/user.lua",
	-----------------------
	"server/queue/graceTime.lua",
	"server/queue/onPlayerConnecting.lua",
	"server/queue/priority.lua",
	"server/queue/helper/*.lua",
	"server/queue/repository/*.lua",
	-----------------------
	"server/class/character.lua",
	"server/class/user.lua",
}

files {
	"data/horses_components.json",
	"data/mp_overlay_layers.json",
	"data/mp_peds_components.json",
	-----------------------
	"lib/utils.lua",
	"lib/Tunnel.lua",
	"lib/Proxy.lua",
	"lib/Tools.lua",
	-----------------------
	"html/*",
	"html/img/*",
	"html/fonts/*"
}

ui_page "html/index.html"

exports {	
	'setOverlayData',
	'colorPalettes',
	'textureTypes',
	'overlaysInfo',
	'clothOverlayItems',
	'overlayAllLayers',
	'setOverlaySelected',
	'getDataCreator'
}

lua54 'yes'