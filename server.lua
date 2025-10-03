VORP = exports.vorp_core:GetCore()
local onDutyPlayers = {}
local trackedPlayers = {}

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local _trackedPlayers = {}
        local _onDutyPlayers = {}
        local players = VORP.getUsers()

        for _, player in pairs(players) do
            local character = player.UsedCharacter()
            if Config.Tracker[character.job] then
                local hasTracker = exports.vorp_inventory:getItemCount(player.source, nil, Config.TrackerItem) > 0
                local isOnDuty = Config.OnDuty(player.source, character.job)

                if hasTracker then
                    local playerPed = GetPlayerPed(player.source)
                    table.insert(_trackedPlayers, {
                        serverId = player.source,
                        name = character.firstname .. " " .. character.lastname,
                        job = character.job,
                        location = GetEntityCoords(playerPed)
                    })
                end
                if isOnDuty then
                    _onDutyPlayers[player.source] = true
                elseif onDutyPlayers[player.source] then
                    TriggerClientEvent('vorp_tracker:update_blips', player.source, {})
                end
            end
        end
        onDutyPlayers = _onDutyPlayers
        trackedPlayers = _trackedPlayers
    end
end)

CreateThread(function()
    Wait(3000)
    while true do
        Wait(Config.UpdateInterval)

        for source in pairs(onDutyPlayers) do
            TriggerClientEvent('vorp_tracker:update_blips', source, trackedPlayers)
        end
    end
end)
