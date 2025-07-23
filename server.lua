VORP = exports.vorp_core:GetCore()
local onDutyOfficers = {}
local trackedOfficers = {}

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local _trackedOfficers = {}
        local _onDutyOfficers = {}
        local players = VORP.getUsers()

        for _, player in pairs(players) do   
            local isPolice = Player(player.source).state.IsPolice
            local hasTracker = exports.vorp_inventory:getItemCount(player.source,nil, Config.TrackerItem) > 0
            local isOnDuty = exports.outsider_policeman:IsOnPoliceDuty(player.source)

            if isPolice and hasTracker then                
                local playerPed = GetPlayerPed(player.source)
                local character = player.UsedCharacter()
                table.insert(_trackedOfficers, {
                    serverId = player.source,
                    name = character.firstname.." "..character.lastname,
                    location = GetEntityCoords(playerPed)
                })
            end
            if isOnDuty then
                _onDutyOfficers[player.source] = true
            elseif onDutyOfficers[player.source] then                
                TriggerClientEvent('police_tracker:update_blips', player.source, {})
            end
        end
        onDutyOfficers = _onDutyOfficers
        trackedOfficers = _trackedOfficers
    end
end)

CreateThread(function()
    Wait(3000) 
    while true do
        Wait(Config.UpdateInterval)

        for source in pairs(onDutyOfficers) do
            TriggerClientEvent('police_tracker:update_blips', source, trackedOfficers)
        end
    end
end)