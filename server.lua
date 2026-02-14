local VORP = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local TRACKED_PLAYERS = {}
local ONDUTY_PLAYERS = {}
local HAS_TRACKER = {}

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
                
                local isOnDuty = Config.OnDuty(source, character.job)

                if HAS_TRACKER[source] and (not Config.TrackOnlyOnDuty or isOnDuty) then
                    _trackedPlayers[source] = {
                        name = character.firstname .. " " .. character.lastname,
                        job = character.job
                    }
                end
                if isOnDuty then
                    _onDutyPlayers[source] = true
                elseif ONDUTY_PLAYERS[source] then
                    TriggerClientEvent('vorp_tracker:update_blips', source, {})
                end
            end
        end

        TRACKED_PLAYERS = _trackedPlayers
        ONDUTY_PLAYERS = _onDutyPlayers
        Wait(10000)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local currentTrackedData = {}

        for source, data in pairs(TRACKED_PLAYERS) do
            local playerPed = GetPlayerPed(source)
            if DoesEntityExist(playerPed) and HAS_TRACKER[source] then
                currentTrackedData[#currentTrackedData + 1] = {
                    serverId = source,
                    name = data.name,
                    job = data.job,
                    location = GetEntityCoords(playerPed)
                }
            end
        end

        for source, _ in pairs(ONDUTY_PLAYERS) do
            TriggerClientEvent('vorp_tracker:update_blips', source, currentTrackedData)
        end
    end
end)

CreateThread(function()
    if Config.DevMode then
        for _, source in pairs(GetPlayers()) do
            local hasTracker = VorpInv.getItemCount(source, Config.TrackerItem) > 0
            HAS_TRACKER[tonumber(source)] = hasTracker
            DebugPrint("Initial tracker state for player", source, hasTracker)
        end
    end
end)

AddEventHandler('vorp:SelectedCharacter', function(source, character)
    local hasTracker = VorpInv.getItemCount(source, Config.TrackerItem) > 0
    HAS_TRACKER[tonumber(source)] = hasTracker
    DebugPrint("Player has tracker:", source, hasTracker)
end)


AddEventHandler('vorp_inventory:Server:OnItemCreated', function(data, source)
    if data.name == Config.TrackerItem then
        HAS_TRACKER[tonumber(source)] = true
        DebugPrint("Tracker added to player", source)
    end
end)


AddEventHandler('vorp_inventory:Server:OnItemRemoved', function(data, source)
    if data.name == Config.TrackerItem then
        HAS_TRACKER[tonumber(source)] = nil
        DebugPrint("Tracker removed from player", source)
    end
end)


AddEventHandler('playerDropped', function()
    local source = tonumber(source)
    TRACKED_PLAYERS[source] = nil
    ONDUTY_PLAYERS[source] = nil
    HAS_TRACKER[source] = nil
end)


function DebugPrint(...)
    if Config.DevMode then
        print("^3[DEBUG]^7", ...)
    end
end