local DutyBlips = {}

RegisterNetEvent('vorp_tracker:update_blips', function(players)
    local myServerId = GetPlayerServerId(PlayerId())
    local newTrackedIds = {}

    for _, player in ipairs(players) do
        if player.serverId ~= myServerId then
            newTrackedIds[player.serverId] = true
            local ped = GetPlayerPed(GetPlayerFromServerId(player.serverId))
            local blip = GetBlipFromEntity(ped)
            if not DoesBlipExist(blip) then                
                blip = DutyBlips[player.serverId]
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
                if NetworkIsPlayerActive(GetPlayerFromServerId(player.serverId)) then
                    blip = BlipAddForEntity(-214162151, ped)
                else
                    blip = BlipAddForCoords(-214162151, player.location.x, player.location.y, player.location.z)
                end
                SetBlipSprite(blip, Config.Tracker[player.job].BlipSprite, true)
                SetBlipScale(blip, 0.1)
                SetBlipName(blip, player.job..": "..player.name)
                BlipAddStyle(blip, Config.Tracker[player.job].BlipStyle)
                BlipAddModifier(blip, Config.Tracker[player.job].BlipModifier)
                DutyBlips[player.serverId] = blip
            end
        end
    end

    -- Remove blips for players no longer tracked
    for serverId, blip in pairs(DutyBlips) do
        if not newTrackedIds[serverId] then
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            DutyBlips[serverId] = nil
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, blip in pairs(DutyBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end)
