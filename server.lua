local VORP = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local trackedPlayers = {}
local onDutyPlayers = {}

local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords

CreateThread(function()
    while true do
        local _trackedPlayers = {}
        local _onDutyPlayers = {}
        local players = VORP.getUsers()

        for _, player in pairs(players) do
            local character = player.UsedCharacter()
            if character and Config.Tracker[character.job] then
                local source = player.source

                local hasTracker = VorpInv.getItemCount(source, Config.TrackerItem) > 0
                local isOnDuty = Config.OnDuty(source, character.job)

                if hasTracker then
                    _trackedPlayers[source] = {
                        name = character.firstname .. " " .. character.lastname,
                        job = character.job
                    }
                end
                if isOnDuty then
                    _onDutyPlayers[source] = true
                elseif onDutyPlayers[source] then
                    TriggerClientEvent('vorp_tracker:update_blips', source, {})
                end
            end
        end

        trackedPlayers = _trackedPlayers
        onDutyPlayers = _onDutyPlayers
        Wait(10000)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local currentTrackedData = {}

        for source, data in pairs(trackedPlayers) do
            local playerPed = GetPlayerPed(source)
            if DoesEntityExist(playerPed) then
                currentTrackedData[#currentTrackedData + 1] = {
                    serverId = source,
                    name = data.name,
                    job = data.job,
                    location = GetEntityCoords(playerPed)
                }
            end
        end

        for source, _ in pairs(onDutyPlayers) do
            TriggerClientEvent('vorp_tracker:update_blips', source, currentTrackedData)
        end
    end
end)
