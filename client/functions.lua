
function cAPI.GetPosition()
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
	return x, y, z
end

-- return vx,vy,vz
function cAPI.GetSpeed()
	local vx, vy, vz = table.unpack(GetEntityVelocity(PlayerPedId()))
	return math.sqrt(vx * vx + vy * vy + vz * vz)
end

function cAPI.GetCoordsFromCam(distance)
	local rot = GetGameplayCamRot(2)
	local coord = GetGameplayCamCoord()

	local tZ = rot.z * 0.0174532924
	local tX = rot.x * 0.0174532924
	local num = math.abs(math.cos(tX))

	newCoordX = coord.x + (-math.sin(tZ)) * (num + distance)
	newCoordY = coord.y + (math.cos(tZ)) * (num + distance)
	newCoordZ = coord.z + (math.sin(tX) * 8.0)
	return newCoordX, newCoordY, newCoordZ
end

function cAPI.Target(Distance, Ped)
	local Entity = nil
	local camCoords = GetGameplayCamCoord()
	local farCoordsX, farCoordsY, farCoordsZ = cAPI.GetCoordsFromCam(Distance)
	local RayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, farCoordsX, farCoordsY, farCoordsZ, -1,
		Ped, 0)
	local A, B, C, D, Entity = GetShapeTestResult(RayHandle)
	return Entity, farCoordsX, farCoordsY, farCoordsZ
end

function cAPI.SetHealth(amount)
	SetEntityHealth(PlayerPedId(), math.floor(amount))
end

function cAPI.GetHealth()
	return GetEntityHealth(PlayerPedId())
end

local Invinsible

function cAPI.ToggleInvinsible()
	Invinsible = not Invinsible
	if Invinsible then
		SetEntityInvincible(PlayerPedId(), true)
	else
		SetEntityInvincible(PlayerPedId(), false)
	end
end

function cAPI.PlaySkyCameraAnimationAtCoords(coords)
	local vecPosition = vec3(coords[1], coords[2], coords[3])

	RequestCollisionAtCoord(vecPosition)

	local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 621.67, 374.08, 873.24, 300.00, 0.00, 0.00, 100.00, false, 0) -- CAMERA COORDS
	PointCamAtCoord(cam, vecPosition.xy, vecPosition.z + 200)
	SetCamActive(cam, true)

	local cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", vecPosition.xy, vecPosition.z + 200, 300.00, 0.00, 0.00, 100.00, false, 0)
	PointCamAtCoord(cam3, vecPosition.xy, vecPosition.z + 200)
	SetCamActiveWithInterp(cam3, cam, 8000, true, true)
	Citizen.Wait(8000)
	cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords[1], coords[2], coords[3] + 200, 300.00, 0.00, 0.00, 100.00, false, 0)
	PointCamAtCoord(cam2, vecPosition.xy, vecPosition.z + 2)
	SetCamActiveWithInterp(cam2, cam3, 5000, true, true)
	RenderScriptCams(false, true, 500, true, true)

	local _, groundZ, normal = GetGroundZAndNormalFor_3dCoord(vecPosition.x, vecPosition.y, vecPosition.z)

	if _ then
		vecPosition = vec3(vecPosition.xy, groundZ)
	end

	SetEntityCoords(PlayerPedId(), vecPosition)

	Citizen.Wait(5000)

	DestroyAllCams(true)
end

function cAPI.IsPlayingAnimation(dict, anim)
	local ped = PlayerPedId()
	return IsEntityPlayingAnim(ped, dict, anim, 3)
end

function cAPI.ClientConnected(bool)
	if bool then
		ShutdownLoadingScreenNui()
		ShutdownLoadingScreen()
	end
end

function cAPI.GetUserIdFromServerId(serverid)
	return gServerToUser[serverid] or 0
end

function cAPI.GetServerIdFromUserId(userid)
	for serverid, _userid in pairs(gServerToUser) do
		if _userid == userid then
			return serverid
		end
	end

	return 0
end

function cAPI.DrawText(x, y, width, height, scale, r, g, b, a, text)
	SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function cAPI.DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function cAPI.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        a = heading
    }
end

function cAPI.SpawnVehicle(model, cb, coords, isnetworked)
    local model = (type(model)=="number" and model or GetHashKey(model))
    local coords = coords ~= nil and coords or cAPI.GetCoords(PlayerPedId())
    local isnetworked = isnetworked ~= nil and isnetworked or true

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.a, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)

	SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
	SetNetworkIdCanMigrate(netid, true)
    --SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")

    SetModelAsNoLongerNeeded(model)

    if cb ~= nil then
        cb(veh)
    end
end

function cAPI.Notify(type, text, quantity)
    if type ~= nil and text == nil and quantity == nil then
        text = type
        type = "dev"
    end

    TriggerEvent("FRP:TOAST:New", type, text, quantity)
end

-- function cAPI.Notify(text, textype, length) -- [text] = message, [type] = primary | error | success, [length] = time till fadeout.
--     local ttype = textype ~= nil and textype or "primary"
--     local length = length ~= nil and length or 5000
--     SendNUIMessage({
--         action = "show",
--         type = ttype,
--         length = length,
--         text = text,
--     })
-- end

function cAPI.HasItem(source, cb, item)
	local retval = false
	cAPI.TriggerCallback('FRPCore:HasItem', function(result)
		if result then
			retval = true
		end
		return retval
	end, item)
	return retval
end

function cAPI.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
    }, function(cancelled)
        if not cancelled then
            if onFinish ~= nil then
                onFinish()
            end
        else
            if onCancel ~= nil then
                onCancel()
            end
        end
    end)
end

function cAPI.NotifyToast(type, text, quantity)
    if type ~= nil and text == nil and quantity == nil then
        text = type
        type = "dev"
    end

    TriggerEvent("FRP:TOAST:New", type, text, quantity)
end



local function GetCollisionBetweenPoints(pointFrom, pointTo, flags)
    -- StartExpensiveSynchronousShapeTestLosProbe
    local handle 

    if IS_GTAV then
        handle = StartExpensiveSynchronousShapeTestLosProbe(pointFrom.x, pointFrom.y, pointFrom.z, pointTo.x, pointTo.y, pointTo.z, flags, 0, 7)
    elseif IS_RDR3 then
        handle = Citizen.InvokeNative(0x377906D8A31E5586, pointFrom.x, pointFrom.y, pointFrom.z, pointTo.x, pointTo.y, pointTo.z, flags, 0, 7)
    end

    local _, hit, hitPos = GetShapeTestResult(handle)

    return hit == 1, hitPos
end

function cAPI.getFromCoordsFromPlayer(position, ped, radius)
	local r = radius or 0.8

	local Cx = position.x
	local Cy = position.y
	local z = position.z

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

	local h = GetEntityHeading(ped or playerPed)

	local i = math.rad(h + 90)
	local X_deg0 = Cx + (r * math.cos(i))
	local Y_deg0 = Cy + (r * math.sin(i))

    local startPos = vec3(X_deg0, Y_deg0, z)
    local hit, hitPos = GetCollisionBetweenPoints(position or playerCoords, startPos, 1 | 16)
    local coords = hit and hitPos or startPos
    
    local _, groundZ, _ = GetGroundZAndNormalFor_3dCoord(coords.x ,coords.y, coords.z)
    
    local endCoords = vec3(coords.x, coords.y, groundZ + 0.10)

	return endCoords
end