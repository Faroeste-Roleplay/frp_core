
RegisterNetEvent("FRP:onCharacterLogout")

AddEventHandler("playerSpawned", function()
	local playerPed = PlayerPedId()

    SetEntityVisible(playerPed, false)
    SetEntityInvincible(playerPed, true)
    NetworkSetEntityInvisibleToNetwork(playerPed, true)
	
	TriggerServerEvent("FRP:onPlayerSpawned")


    if Config.EnablePlayerSelectLanguage then
        local kvpLang = GetExternalKvpString('frp_lib', 'frp_language')
        
        if not kvpLang or kvpLang == "" then
            TriggerEvent('FRP:OpenRequestMenuToChangeLanguage')
        end
    end
end)


function OpenRequestMenuToChangeLanguage()
    local input = lib.inputDialog(i18n.translate('info.select_language'), {
        { type = 'select', label = i18n.translate('info.language'), options = {
            { value = 'en', label = 'English' },
            { value = 'pt', label = 'Português' },
            { value = 'es', label = 'Español'}
        }},
    })

    local languageResult = input[1]

    if languageResult then
        TriggerEvent('FRP:SetLanguage', languageResult)
    end
end

RegisterNetEvent("FRP:OpenRequestMenuToChangeLanguage", OpenRequestMenuToChangeLanguage)

AddEventHandler("onClientResourceStart", function() -- Reveal whole map on spawn and enable pvp
    if Config.RevealMap then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end
end)

CreateThread( function()
    if Config.RevealMap then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end
end)

AddEventHandler("onClientMapStart",	function()
	-- print("client map initialized")
end)

AddEventHandler("onResourceStart",	function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, false)
    SetEntityInvincible(playerPed, true)
    NetworkSetEntityInvisibleToNetwork(playerPed, true)

	TriggerServerEvent("FRP:addReconnectPlayer")
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserId', function(serverid, userid)
	gServerToUser[serverid] = userid
	gServerToUserChanged    = true
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserIdPacked', function(r)
	gServerToUser        = r
	gServerToUserChanged = true
end)