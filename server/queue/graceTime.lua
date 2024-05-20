local GRACE_TIME_LIFETIME_IN_SECONDS = 480 --[[ 8 minutos ]]

local gGraceTimeUsers = { }

local gHasCountdown = false

function StartGraceTimeLifetimeCountdown()
    gHasCountdown = true

    CreateThread(function()
        while gHasCountdown do
            Wait(1000)

            local timer = GetGameTimer()

            for userId, startedAt in pairs(gGraceTimeUsers) do

                local secondsPassed = (timer - startedAt) / 1000

                if secondsPassed >= GRACE_TIME_LIFETIME_IN_SECONDS then
                    gGraceTimeUsers[userId] = nil
                end
            end

            if table.type(gGraceTimeUsers) == 'empty' then
                break
            end
        end

        gHasCountdown = false
    end)
end

function EnsureGraceTimeLifetimeCountdown()
    if gHasCountdown then
        return
    end

    StartGraceTimeLifetimeCountdown()
end

AddEventHandler('FRP:playerDropped', function(user)
    local userId = user.GetId()

    gGraceTimeUsers[userId] = GetGameTimer()

    EnsureGraceTimeLifetimeCountdown()
end)

AddEventHandler('FRP:playerLoaded', function(playerId, user)
    local userId = user.GetId()

    gGraceTimeUsers[userId] = nil
end)

function IsUserGraceTimeActive(userId)
    return gGraceTimeUsers[userId] ~= nil
end