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

local playerDamageData = {}
local webhookUrl = "https://discord.com/api/webhooks/XXXXXXXXXX/XXXXXXXXXX" -- << Discord webhook

RegisterNetEvent('player:receiveBulletDamage', function(playerId, weapon, boneLabel, damage)
    if not playerDamageData[playerId] then
        playerDamageData[playerId] = {}
    end
    table.insert(playerDamageData[playerId], {
        weapon = weapon,
        bone = boneLabel,
        damage = damage
    })

    -- Discord log
    local srcName = GetPlayerName(source) or ("ID:"..source)
    local targetName = GetPlayerName(playerId) or ("ID:"..playerId)
    local log = string.format("**%s** shot **%s** in the **%s** with **%s** for **%d** damage.", 
        srcName, targetName, boneLabel, weapon, damage)

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({
        username = "SK Offcial",
        embeds = {{
            title = "Player Damage Log",
            description = log,
            color = 16711680
        }}
    }), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('player:showInjuredText', function(playerId)
    TriggerClientEvent('client:showInjuredText', -1, playerId)
end)

RegisterCommand('damages', function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        if coreType == 'qb' then
            TriggerClientEvent('QBCore:Notify', source, "Please specify the player ID.", "error")
        elseif coreType == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, { description = "Please specify the player ID.", type = "error" })
        end
        return
    end

    local history = playerDamageData[targetId]
    if not history or #history == 0 then
        if coreType == 'qb' then
            TriggerClientEvent('QBCore:Notify', source, "Damage data for this player was not found.", "error")
        elseif coreType == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, { description = "Damage data for this player was not found.", type = "error" })
        end
        return
    end

    for _, entry in ipairs(history) do
        local text = string.format(
            "You’ve been ^1shot^7 in the ^1%s^7 with a ^1%s^7 for ^1%d^7 damage.",
            entry.bone,
            entry.weapon,
            entry.damage
        )
        TriggerClientEvent('chat:addMessage', source, { args = {"", text} })
    end
end, false)

AddEventHandler('hospital:server:RevivePlayer', function(targetId)
    playerDamageData[targetId] = {}
end)

AddEventHandler('QBCore:Server:PlayerRevive', function(playerId)
    playerDamageData[playerId] = {}
end)

AddEventHandler('playerDropped', function()
    local id = source
    playerDamageData[id] = nil
end)
