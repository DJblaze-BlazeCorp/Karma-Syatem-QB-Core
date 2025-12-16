-- Server.lua

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
    if not read then
        error(('Missing language file: %s'):format(path))
    end
    local env = {}
    assert(load(read, '@' .. path, 't', env))()
    Strings = env.Strings or {}
    Exports = env.Exports or {}
end

-- Load debug language
do
    local path = ('config/lang/debug/%s.lua'):format(Config.DebugLanguage or 'en')
    local read = LoadResourceFile(GetCurrentResourceName(), path)
    if not read then
        error(('Missing debug language file: %s'):format(path))
    end
    local env = {}
    assert(load(read, '@' .. path, 't', env))()
    DebugStrings = env.DebugStrings or {}
    DebugExports = env.DebugExports or {}
end

---------------------------------------------------------------------
-- CONFIG LOAD
---------------------------------------------------------------------
local AddEvents = Config.AddKarmaEvents
local RemoveEvents = Config.RemoveKarmaEvents
local Commands  = Config.Commands or {}
local Gating    = Config.Gating or {}

---------------------------------------------------------------------
-- DATABASE SETUP
---------------------------------------------------------------------
MySQL.query.await([[
    CREATE TABLE IF NOT EXISTS player_karma (
        identifier VARCHAR(50) NOT NULL PRIMARY KEY,
        karma INT NOT NULL DEFAULT ]]..Config.BaseKarma..[[,
        last_update BIGINT NOT NULL DEFAULT 0
    );
]])

---------------------------------------------------------------------
-- UTILITY FUNCTIONS
---------------------------------------------------------------------
local function Identifier(src)
    local player = QBCore.Functions.GetPlayer(src)
    return player and player.PlayerData.citizenid or nil
end

local function EnsureRow(id)
    MySQL.insert.await(
        'INSERT IGNORE INTO player_karma (identifier, karma, last_update) VALUES (?, ?, ?)',
        { id, Config.BaseKarma, os.time() }
    )
end

local function GetKarma(sourceOrIdentifier)
    local id = type(sourceOrIdentifier) == "number" and Identifier(sourceOrIdentifier) or sourceOrIdentifier
    if not id then return Config.BaseKarma end
    local result = MySQL.scalar.await('SELECT karma FROM player_karma WHERE identifier=?', { id })
    if result then return tonumber(result) end
    EnsureRow(id)
    return Config.BaseKarma
end

local function SetKarma(srcOrId, value, reason)
    local id = type(srcOrId) == "number" and Identifier(srcOrId) or srcOrId
    if not id then return false end

    local lastValue = GetKarma(id)
    local newVal = math.max(Config.MinKarma, math.min(value, Config.MaxKarma))

    MySQL.update.await(
        'INSERT INTO player_karma (identifier, karma) VALUES (?, ?) ON DUPLICATE KEY UPDATE karma=?',
        { id, newVal, newVal }
    )

    if type(srcOrId) == "number" then
        TriggerClientEvent('karma:updated', srcOrId, newVal, reason)
    end

    if Config.Debug then
        print(('[DEBUG] Karma changed for %s: %d → %d (Reason: %s)'):format(id, lastValue, newVal, reason or 'manual'))
    end

    if Config.Webhook then
        PerformHttpRequest(Config.Webhook, function() end, 'POST',
            json.encode({
                content = Config.WebhookMessage
                    :gsub(Exports.PlayerName or '%%player%%', id)
                    :gsub(Exports.PlayerKarma or '%%player_karma%%', tostring(newVal))
                    :gsub(Exports.Reason or '%%reason%%', reason or 'manual')
            }),
            { ['Content-Type'] = 'application/json' }
        )
    end

    return true
end

local function ApplyKarmaEvent(event, src)
    local e = AddEvents[event] or RemoveEvents[event]
    if not e then return end
    local lastKarma = GetKarma(src)
    local updated = lastKarma + e.amount
    SetKarma(src, updated, e.reason)

    if Config.Debug then
        print(('[DEBUG] Applied karma event "%s" for player %s: %d → %d'):format(event, Identifier(src) or src, lastKarma, updated))
    end
end

local function HasKarmaForEvent(src, event)
    local required = Gating[event]
    if not required then return true end
    local current = GetKarma(src)
    local result = current >= required

    if Config.Debug then
        print(('[DEBUG] Karma gate check for player %s on event "%s": required=%d, has=%d, allowed=%s'):format(
            Identifier(src) or src, event, required, current, tostring(result)
        ))
    end

    return result
end

---------------------------------------------------------------------
-- EXPORTS
---------------------------------------------------------------------
exports('GetKarma', GetKarma)
exports('SetKarma', SetKarma)
exports('ApplyKarmaEvent', ApplyKarmaEvent)
exports('HasKarmaForEvent', HasKarmaForEvent)
exports('GetLangStrings', function() return Strings end)
exports('GetLangExports', function() return Exports end)
exports('GetDebugStrings', function() return DebugStrings end)
exports('GetDebugExports', function() return DebugExports end)

---------------------------------------------------------------------
-- CALLBACK
---------------------------------------------------------------------
QBCore.Functions.CreateCallback('karma:getKarma', function(source, cb)
    cb(GetKarma(source))
end)

---------------------------------------------------------------------
-- PLAYER LOADED EVENT
---------------------------------------------------------------------
RegisterNetEvent('karma:onPlayerLoaded', function()
    local src = source
    local id = Identifier(src)
    if id then
        EnsureRow(id)
    end
end)

---------------------------------------------------------------------
-- EVENT ENFORCEMENT
---------------------------------------------------------------------
AddEventHandler('karma:onEventTrigger', function(src, event)
    if not HasKarmaForEvent(src, event) then
        TriggerClientEvent('QBCore:Notify', src, Strings.gatingBlocked, 'error')
        CancelEvent()
    end
end)

---------------------------------------------------------------------
-- ADMIN COMMANDS
---------------------------------------------------------------------
QBCore.Commands.Add(Commands.setKarma, 'Set player karma', {
    { name='id', help='Player ID' },
    { name='value', help='New karma value' }
}, true, function(source, args)
    local target = tonumber(args.id)
    local val = tonumber(args.value)
    SetKarma(target, val, "Admin")
    TriggerClientEvent('QBCore:Notify', source, Strings.adminSetKarma
        :gsub(Exports.PlayerName or '%%player%%', args.id)
        :gsub(Exports.PlayerKarma or '%%player_karma%%', args.value), 'success')
end, 'admin')

QBCore.Commands.Add(Commands.addKarma, 'Add or subtract karma', {
    { name='id', help='Player ID' },
    { name='amount', help='Amount (+/-)' }
}, true, function(source, args)
    local target = tonumber(args.id)
    local amt = tonumber(args.amount)
    local lastValue = GetKarma(target)
    SetKarma(target, lastValue + amt, "Admin modify")
    TriggerClientEvent('QBCore:Notify', source, Strings.adminAddKarma
        :gsub(Exports.PlayerName or '%%player%%', args.id)
        :gsub(Exports.Amount or '%%amount%%', args.amount), 'success')
end, 'admin')

QBCore.Commands.Add(Commands.checkKarma, 'See player karma', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    local lastValue = GetKarma(tonumber(args.id))
    TriggerClientEvent('QBCore:Notify', source, Strings.adminCheckKarma
        :gsub(Exports.PlayerName or '%%player%%', args.id)
        :gsub(Exports.Amount or '%%amount%%', tostring(lastValue)), 'primary')
end, 'admin')

QBCore.Commands.Add(Commands.resetKarma, 'Reset player karma to base', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    local lastValue = GetKarma(tonumber(args.id))
    SetKarma(tonumber(args.id), Config.BaseKarma, "Reset to base")
    TriggerClientEvent('QBCore:Notify', source, Strings.adminResetKarma
        :gsub(Exports.PlayerName or '%%player%%', args.id), 'success')
end, 'admin')

QBCore.Commands.Add(Commands.debugKarma, 'Debug karma values', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    if not Config.Debug then
        TriggerClientEvent('QBCore:Notify', source, '[DEBUG] Debug mode is disabled.', 'error')
        return
    end
    local lastValue = GetKarma(tonumber(args.id))
    TriggerClientEvent('QBCore:Notify', source, DebugStrings.adminCheckKarma
        :gsub(DebugExports.PlayerName or '%%player%%', args.id)
        :gsub(DebugExports.Amount or '%%amount%%', tostring(lastValue))
        :gsub(DebugExports.LastKarma or '%%last%%', tostring(lastValue)), 'primary')
end, 'admin')
