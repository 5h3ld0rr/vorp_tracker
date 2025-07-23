local DutyBlips = {}

RegisterNetEvent('police_tracker:update_blips', function(officers)
    local myServerId = GetPlayerServerId(PlayerId())
    local newTrackedIds = {}

    for _, officer in ipairs(officers) do
        if officer.serverId ~= myServerId then
            newTrackedIds[officer.serverId] = true
            local ped = GetPlayerPed(GetPlayerFromServerId(officer.serverId))
            local blip = GetBlipFromEntity(ped)
            if not DoesBlipExist(blip) then                
                blip = DutyBlips[officer.serverId]
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
                if NetworkIsPlayerActive(GetPlayerFromServerId(officer.serverId)) then
                    blip = BlipAddForEntity(Config.BlipSprite, ped)
                else
                    blip = BlipAddForCoords(Config.BlipSprite, officer.location.x, officer.location.y, officer.location.z)
                end
                SetBlipName(blip, (Config.BlipNameTemplate):format(officer.name))
                BlipAddStyle(blip, Config.BlipStyle)
                BlipAddModifier(blip, Config.BlipModifier)
                DutyBlips[officer.serverId] = blip
            end
        end
    end

    -- Remove blips for officers no longer tracked
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
