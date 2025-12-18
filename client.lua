-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- KARMA UPDATE DISPLAY
RegisterNetEvent('karma:updated', function(newKarma, reason)
    local text
    if reason then
        text = Strings.karmaUpdatedReason
            :gsub(Exports.Amount or '%%amount%%', tostring(newKarma))
            :gsub(Exports.PlayerKarma or '%%player_karma%%', tostring(newKarma))
            :gsub(Exports.Reason or '%%reason%%', reason)
    else
        text = Strings.karmaUpdated:gsub(Exports.PlayerKarma or '%%player_karma%%', tostring(newKarma))
    end
    QBCore.Functions.Notify(text, 'success', 7000)
end)

-- GET LOCAL KARMA
function GetLocalKarma(cb)
    QBCore.Functions.TriggerCallback('karma:getKarma', function(k)
        cb(k)
    end)
end

-- PLAYER LOADED
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('karma:onPlayerLoaded')
end)

-- EVENT TRIGGER
function TriggerKarmaEvent(event)
    TriggerServerEvent('karma:onEventTrigger', event)
    if Config.Debug then
        print(('[DEBUG] Triggered karma event from client: %s'):format(event))
    end
end
