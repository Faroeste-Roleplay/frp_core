fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	
	"data/allowlistRoles.lua",
	"data/permissions.lua",
	---------------------
	"@frp_lib/lib/utils.lua",
	"@frp_lib/modules/utils/i18n.lua",
	"@frp_lib/modules/utils/dataview.lua",

	"locale/*.lua"
}

client_scripts {
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
	"@frp_lib/modules/utils/deferalsCard.lua",

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
	"data/horses_components.json",
	"data/mp_overlay_layers.json",
	"data/mp_peds_components.json",
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