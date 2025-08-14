local requests = {}

function cAPI.Request(text, time)
	local id = math.random(999999)
	SendNUIMessage({ act = "request", id = id, text = tostring(text), time = time })

	-- !!! OPTIMIZATION
	-- Stop the loop while the time has passed

	while requests[id] == nil do
		Citizen.Wait(10)
	end

	local _temp = requests[id] or false
	requests[id] = nil
	return _temp
end

RegisterNUICallback("request", function(data, cb)
	if data.act == "response" then
		requests[data.id] = data.ok
	end
end)

RegisterNetEvent("core:client:responseRequest", function( accepted )
	SendNUIMessage({ act = "event", event = "no" })
end)

Citizen.CreateThread(function()
	while true do

		Wait(3)

		if IsControlJustPressed(0, 0xF3830D8E) then
			SendNUIMessage({ act = "event", event = "yes" })
		end

		if IsControlJustPressed(0, 0x80F28E95) then
			SendNUIMessage({ act = "event", event = "no" })
		end

	end
end)

local prompResult = nil

function cAPI.Prompt(title, default_text)
	SendNUIMessage({ act = "prompt", title = title, text = tostring(default_text) })
	SetNuiFocus(true)
	while prompResult == nil do
		Citizen.Wait(10)
	end
	local _temp = prompResult
	prompResult = nil
	return _temp
end

RegisterNUICallback("prompt", function(data, cb)
	if data.act == "close" then
		SetNuiFocus(false)
		prompResult = data.result
	end
end)

function cAPI.RequestModel(hash)
	hash = tonumber(hash)

	if not IsModelValid(hash) then
		return
	end

	if not HasModelLoaded(hash) then
		RequestModel(hash)
		while not HasModelLoaded(hash) do
			Citizen.Wait(10)
		end
	end
end

function cAPI.RequestAnimDict(dictionary)
	if not HasAnimDictLoaded(dictionary) then
		RequestAnimDict(dictionary)
		while not HasAnimDictLoaded(dictionary) do
			Citizen.Wait(10)
		end
	end
end

function cAPI.StartFade(timer, effect)
	DoScreenFadeOut(timer)

	if effect then
		AnimpostfxPlay("SkyTL_2100_04Storm_nofade");
	end

	while IsScreenFadingOut() do
		Citizen.Wait(1)
	end
end

function cAPI.EndFade(timer, effect)
	ShutdownLoadingScreen()
	DoScreenFadeIn(timer)

	if effect or AnimpostfxIsRunning("SkyTL_2100_04Storm_nofade") then
		AnimpostfxStop("SkyTL_2100_04Storm_nofade")
	end

	while IsScreenFadingIn() do
		Citizen.Wait(1)
	end
end

function cAPI.PlayAnim(dict, anim, speed)
	if not IsEntityPlayingAnim(PlayerPedId(), dict, anim) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(100)
		end
		TaskPlayAnim(PlayerPedId(), dict, anim, speed, 1.0, -1, 0, 0, 0, 0, 0, 0, 0)
	end
end


--
-- Newly Discovered Natives
--

-- Returns 1 or false depending if the ped's audio bank contains the specified speech line
-- Example: CanPlayAmbientSpeech(ped, "WHATS_YOUR_PROBLEM") = false when using as mary linton
-- IMPORTANT: Not reliable on remote clients when used on a player ped
function CanPlayAmbientSpeech(ped, soundName) -- ped:int, soundName:str
	return Citizen.InvokeNative(0x9D6DEC9791A4E501, ped, soundName, 0, 1)
end

-- Gets the hash for the currently playing speech line
function GetCurrentAmbientSpeech(ped) -- ped:int
	return Citizen.InvokeNative(0x4A98E228A936DBCC, ped)
end
	
-- Gets the hash for the last played speech line
function GetLastAmbientSpeech(ped) -- ped:int
	return Citizen.InvokeNative(0x6BFFB7C276866996, ped)
end

-- Seems to return horse ped when really close (facing, directly riding, etc)
function GetNearByHorse()
	return Citizen.InvokeNative(0x0501D52D24EA8934, 1, Citizen.ResultAsInteger())
end

-- Returns the selected item in the weapon wheel. Only works while the wheel is open. 
-- Use in conjunction with IsControlJustReleased(0, `INPUT_OPEN_WHEEL_MENU`) to detect item selection/usage.
function GetItemInWheel()
	return N_0x9c409bbc492cb5b1()
end

-- Sets the third person gameplay camera zoom level and blends in.
-- Must be called every frame to interpolate.
-- Important: offset and distance permanently affects subtle zoom in weapon wheel and possibly in menus too.
-- Seems to be used by internal ui animation: Radial_Menu_Slot_Granular_Focus_Transition.ymt
function SetGameplayCamGranularFocusThisFrame(fAlpha, iUnk0, fOffset, iUnk1, fDistance)
	return N_0x066167c63111d8cf(fAlpha, iUnk0, fOffset, iUnk1, fDistance)
end

-- Original code from https://github.com/femga/rdr3_discoveries/
function PlayAmbientSpeechFromEntity(entity_id, sound_ref_string, sound_name_string, speech_params_string, speech_line)
	local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string,Citizen.ResultAsLong())
	local sound_ref  = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING",sound_ref_string,Citizen.ResultAsLong())
	local speech_params = GetHashKey(speech_params_string)
	
	local sound_name_BigInt =  DataView.ArrayBuffer(16) 
	sound_name_BigInt:SetInt64(0,sound_name)
	
	local sound_ref_BigInt =  DataView.ArrayBuffer(16)
	sound_ref_BigInt:SetInt64(0,sound_ref)
	
	local speech_params_BigInt = DataView.ArrayBuffer(16)
	speech_params_BigInt:SetInt64(0,speech_params)
	
	local struct = DataView.ArrayBuffer(128)
	struct:SetInt64(0, sound_name_BigInt:GetInt64(0)) -- speechName
	struct:SetInt64(8, sound_ref_BigInt:GetInt64(0)) -- voiceName
	struct:SetInt32(16, speech_line) -- variation
	struct:SetInt64(24, speech_params_BigInt:GetInt64(0)) -- speechParamHash
	struct:SetInt32(32, 0) -- listenerPed
	struct:SetInt32(40, 1) -- syncOverNetwork
	struct:SetInt32(48, 1) -- v7
	struct:SetInt32(56, 1) -- v8
	
	return Citizen.InvokeNative(0x8E04FEDD28D42462, entity_id, struct:Buffer());
end

--
---------------------------------------------------------------------------------------------
--