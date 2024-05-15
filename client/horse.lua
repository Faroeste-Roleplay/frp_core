
function cAPI.VaryHorseHealth(variation, variationTime)
    if cAPI.IsPlayerHorseActive() then
        cAPI.VaryPedHealth(cAPI.GetPlayerHorse(), variation, variationTime)
    end
end

function cAPI.VaryHorseStamina(variation, variationTime)
    if cAPI.IsPlayerHorseActive() then
        cAPI.VaryPedHealth(cAPI.GetPlayerHorse(), variation, variationTime)
    end
end

function cAPI.VaryHorseCore(core, variation, variationTime, goldenEffect)
    if cAPI.IsPlayerHorseActive() then
        cAPI.VaryPedCore(cAPI.GetPlayerHorse(), core, variation, variationTime, goldenEffect)
    end
end

local playerHorse = 0
local isHorseActivationBlocked = false
local horseActivationSeconds
local isHorseInWrithe = false

function cAPI.SetPlayerHorse(horse)
    playerHorse = horse
end

function cAPI.GetPlayerHorse()
    return playerHorse
end

function cAPI.IsPlayerHorseActive()
    return playerHorse ~= 0
end

function cAPI.IsPlayerHorseActivationBlocked()
    return isHorseActivationBlocked
end

function cAPI.DestroyPlayerHorse()
    if cAPI.GetPlayerHorse() ~= 0 then
        DeleteEntity(cAPI.GetPlayerHorse())
        cAPI.SetPlayerHorse(0)
    end
    isHorseActivationBlocked = false
    horseActivationSeconds = nil
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if cAPI.IsPlayerHorseActive() then
            if not isHorseActivationBlocked then
                if IsPedInjured(playerHorse) then
                    cAPI.Notify("error", "Seu cavalo foi ferido, você não poderá chama-lo nos proximos 2 minutos")
                    isHorseActivationBlocked = true
                    horseActivationSeconds = 120
                end

                if PromptHasHoldModeCompleted(prompt_inventory) then
                    PromptSetEnabled(prompt_inventory, false)
                    Citizen.CreateThread(
                        function()
                            Citizen.Wait(250)
                            PromptSetEnabled(prompt_inventory, true)
                        end
                    )

                    TriggerServerEvent("FRP:HORSE:OpenInventory")
                end

                -- Flee
                if IsControlJustPressed(0, 0x4216AF06) then -- F
                    TaskAnimalFlee(playerHorse, PlayerPedId(), -1)
                    Citizen.CreateThread(
                        function()
                            Citizen.Wait(10000)
                            cAPI.DestroyPlayerHorse()
                        end
                    )
                end
            else
                if not IsPedInjured(playerHorse) then
                    isHorseActivationBlocked = false
                    horseActivationSeconds = nil
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if playerHorse ~= 0 and not DoesEntityExist(playerHorse) then -- and DoesEntityExist(playerHorse) then
            cAPI.DestroyPlayerHorse()
        end

        if isHorseActivationBlocked then
            horseActivationSeconds = horseActivationSeconds - 1
            if horseActivationSeconds <= 0 then
                cAPI.DestroyPlayerHorse()
            end
        end

        if isHorseInWrithe then
            if not IsPedInWrithe(playerHorse) then
                isHorseInWrithe = false
            end
        else
            if IsPedInWrithe(playerHorse) then
                cAPI.Notify("alert", "Seu cavalo foi ferido, reanime-o")
                isHorseInWrithe = true
            else
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(playerHorse)) > 500.0 then
                    cAPI.DestroyPlayerHorse()
                end
            end
        end
    end
end)