fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	
	"data/allowlistRoles.lua",
	---------------------
	"@frp_lib/lib/utils.lua",
	"@frp_lib/lib/i18n.lua",
	"@frp_lib/lib/dataview.lua",

	"locale/*.lua"
}

client_scripts {
	"client/_main.lua",
	"client/functions.lua",
	---------------------
	"client/ped.lua",
	"client/player.lua",
	"client/events.lua",
	"client/wrapper.lua",

	"data/horses_components.lua",
	"data/mp_overlay_layers.lua",
	"data/mp_peds_components.lua",
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	"@frp_lib/lib/deferalsCard.lua",

    '@frp_logs/import.lua',
	---------------------
	"server/database.lua",
	"server/_main.lua",
	"server/auth.lua",
	"server/events.lua",
	"server/functions.lua",
	"server/gui.lua",
	-----------------------
	"server/queue/graceTime.lua",
	"server/queue/onPlayerConnecting.lua",
	"server/queue/priority.lua",
	"server/queue/helper/*.lua",
	"server/queue/repository/*.lua",
	-----------------------
	"server/class/character.lua",
	"server/class/user.lua",
	"server/class/group.lua",
	"server/class/groupSystem.lua",
	-----------------------
	"server/services/acl.lua",
	"server/services/user.lua",
	"server/services/group.lua",
}

files {
	"web/*",
	"web/img/*",
	"web/fonts/*",
	-----------------------
	-- "lib/utils.lua",
	-- "lib/Tunnel.lua",
	-- "lib/Proxy.lua",
	-- "lib/Tools.lua",
}

ui_page "web/index.html"

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