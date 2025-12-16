-- Client.lua

local QBCore = exports['qb-core']:GetCoreObject()

---------------------------------------------------------------------
-- LANGUAGE LOAD
---------------------------------------------------------------------
local Strings, Exports = {}, {}
local DebugStrings, DebugExports = {}, {}

-- Load main language
do
    local path = ('config/lang/%s.lua'):format(Config.Language or 'en')
    local read = LoadResourceFile(GetCurrentResourceName(), path)
    if read then
        local env = {}
        assert(load(read, '@' .. path, 't', env))()
        Strings = env.Strings or {}
        Exports = env.Exports or {}
    end
end

-- Load debug language
do
    local path = ('config/lang/debug/%s.lua'):format(Config.DebugLanguage or 'en')
    local read = LoadResourceFile(GetCurrentResourceName(), path)
    if read then
        local env = {}
        assert(load(read, '@' .. path, 't', env))()
        DebugStrings = env.DebugStrings or {}
        DebugExports = env.DebugExports or {}
    end
end

---------------------------------------------------------------------
-- KARMA UPDATE DISPLAY
---------------------------------------------------------------------
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

    if Config.Debug then
        print(('[DEBUG] Client received karma update: %s'):format(text))
    end

    QBCore.Functions.Notify(text, 'success', 7000)
end)

---------------------------------------------------------------------
-- GET LOCAL KARMA
---------------------------------------------------------------------
function GetLocalKarma(cb)
    QBCore.Functions.TriggerCallback('karma:getKarma', function(k)
        cb(k)
    end)
end

---------------------------------------------------------------------
-- PLAYER LOADED
---------------------------------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('karma:onPlayerLoaded')
end)

---------------------------------------------------------------------
-- EVENT TRIGGER
---------------------------------------------------------------------
function TriggerKarmaEvent(event)
    local src = PlayerId()
    TriggerServerEvent('karma:onEventTrigger', src, event)
    if Config.Debug then
        print(('[DEBUG] Triggered karma event from client: %s'):format(event))
    end
end
