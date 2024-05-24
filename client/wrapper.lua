
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

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3)
		if IsControlJustPressed(0, 0xCEFD9220) then
			SendNUIMessage({ act = "event", event = "yes" })
		end
		if IsControlJustPressed(0, 0x4BC9DABB) then
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

