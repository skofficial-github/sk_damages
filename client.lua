local coreType
local Core

if GetResourceState('qb-core') == 'started' then
    Core = exports['qb-core']:GetCoreObject()
    coreType = 'qb'
elseif GetResourceState('ox_core') == 'started' then
    Core = exports['ox_core']:getCoreObject()
    coreType = 'ox'
else
    print('[damageviewer] No framework found.')
    return
end

-- load weapons
local weapons = {}
if coreType == 'qb' then
    weapons = Core.Shared.Weapons
elseif coreType == 'ox' then
    weapons = exports.ox_inventory:Items()
end

local boneNames = {
    [31086] = "Head",
    [40269] = "Neck",
    [11816] = "Spine",
    [24816] = "Left Arm",
    [24817] = "Right Arm",
    [18905] = "Left Hand",
    [57005] = "Right Hand",
    [58271] = "Left Thigh",
    [63931] = "Right Thigh",
    [65129] = "Left Calf",
    [36864] = "Right Calf",
    [14201] = "Left Foot",
    [2108]  = "Right Foot",
}

Citizen.CreateThread(function()
    local lastHealth = GetEntityHealth(PlayerPedId())
    while true do
        Wait(100)
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            TriggerServerEvent('player:showInjuredText', GetPlayerServerId(PlayerId()))
            Wait(5000)
        else
            local currentHealth = GetEntityHealth(ped)
            if currentHealth < lastHealth then
                local weaponHash = GetPedCauseOfDeath(ped)
                local weaponLabel

                if coreType == 'qb' then
                    weaponLabel = weapons[weaponHash] and weapons[weaponHash].label or "Unknown Weapon"
                elseif coreType == 'ox' then
                    local item = weapons[weaponHash]
                    weaponLabel = item and item.label or "Unknown Weapon"
                end

                local hit, bone = GetPedLastDamageBone(ped)
                local boneLabel = boneNames[bone] or "Unknown Part"
                local damage = lastHealth - currentHealth
                TriggerServerEvent('player:receiveBulletDamage', GetPlayerServerId(PlayerId()), weaponLabel, boneLabel, damage)
            end
            lastHealth = currentHealth
        end
    end
end)

local injuredTexts = {}

RegisterNetEvent('client:showInjuredText', function(playerId)
    table.insert(injuredTexts, {time = GetGameTimer(), id = playerId})
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local now = GetGameTimer()
        for i = #injuredTexts, 1, -1 do
            local data = injuredTexts[i]
            if now - data.time < 10000 then
                local targetPlayer = GetPlayerFromServerId(data.id)
                if targetPlayer and NetworkIsPlayerActive(targetPlayer) then
                    local ped = GetPlayerPed(targetPlayer)
                    if DoesEntityExist(ped) then
                        local coords = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
                        Draw3DText(coords.x, coords.y, coords.z, 
                            "(( Has been injured /damages " .. data.id .. " to view the injured. ))", 
                            255, 0, 0)
                    end
                end
            else
                table.remove(injuredTexts, i)
            end
        end
    end
end)

function Draw3DText(x, y, z, text, r, g, b)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetFinalRenderedCamCoord()
    local dist = #(vector3(x, y, z) - camCoords)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.4, 0.4)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextOutline()
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

TriggerEvent('chat:addSuggestion', '/damages', 'Checks the damages of a person. This is only for bullet wounds.', {
    { name = 'ID', help = 'Player ID' }
})

