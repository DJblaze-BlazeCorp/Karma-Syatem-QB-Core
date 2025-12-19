-- Modified server.lua for karma script
-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()
-- CONFIG LOAD (Globals from shared: Strings, DebugStrings, etc.)
local AddEvents = Config.AddKarmaEvents
local RemoveEvents = Config.RemoveKarmaEvents
local Commands = Config.Commands or {}
local Gating = Config.Gating or {}
local unit_multipliers = {
    s = 1,
    m = 60,
    h = 3600,
    d = 86400,
    mo = 2592000 -- approx 30 days
}
local tick_seconds = Config.RegenTickValue * (unit_multipliers[Config.RegenTickUnit] or 60)
-- DATABASE SETUP
MySQL.query.await([[
    CREATE TABLE IF NOT EXISTS player_karma (
        identifier VARCHAR(50) NOT NULL PRIMARY KEY,
        karma INT NOT NULL DEFAULT ]]..Config.BaseKarma..[[,
        last_update BIGINT NOT NULL DEFAULT 0
    );
]])
-- UTILITY FUNCTIONS
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
local function CalculateRegen(current, seconds_diff)
    if seconds_diff <= 0 then return current end
    local num_ticks = math.floor(seconds_diff / tick_seconds)
    if num_ticks <= 0 then return current end
    local base = Config.BaseKarma
    local diff = base - current
    if diff == 0 then return current end
    local amount_per_tick = 0
    local sign = 1
    if diff > 0 then
        if not Config.RegenAddWhenBelow then return current end
        amount_per_tick = Config.RegenAddPerTick
        sign = 1
    elseif diff < 0 then
        if not Config.RegenRemoveWhenAbove then return current end
        amount_per_tick = Config.RegenRemovePerTick
        sign = -1
    end
    local total_change = sign * (num_ticks * amount_per_tick)
    local new = current + total_change
    if diff > 0 then
        if new > base then new = base end
    else
        if new < base then new = base end
    end
    return new
end
local function GetKarma(sourceOrIdentifier)
    local is_src = type(sourceOrIdentifier) == "number"
    local src = is_src and sourceOrIdentifier or nil
    local id = is_src and Identifier(src) or sourceOrIdentifier
    if not id then return Config.BaseKarma end
    EnsureRow(id)
    local row = MySQL.single.await('SELECT karma, last_update FROM player_karma WHERE identifier = ?', { id })
    local current = tonumber(row.karma)
    local last = tonumber(row.last_update)
    local seconds = os.time() - last
    local new_karma = CalculateRegen(current, seconds)
    if new_karma ~= current then
        MySQL.update.await('UPDATE player_karma SET karma = ?, last_update = ? WHERE identifier = ?', { new_karma, os.time(), id })
        if is_src then
            TriggerClientEvent('karma:updated', src, new_karma, Strings.regenerationOffline)
        end
        if Config.Debug then
            print(('[DEBUG] Applied regeneration for %s: %d → %d (seconds: %d, ticks: %d)'):format(id, current, new_karma, seconds, math.floor(seconds / tick_seconds)))
        end
    end
    return new_karma
end
local function SetKarma(srcOrId, value, reason)
    local is_src = type(srcOrId) == "number"
    local src = is_src and srcOrId or nil
    local id = is_src and Identifier(src) or srcOrId
    if not id then
        if Config.Debug then print('[DEBUG] SetKarma failed: invalid id') end
        return false
    end
    local current = GetKarma(srcOrId)
    local newVal = math.max(Config.MinKarma, math.min(value, Config.MaxKarma))
    if newVal == current then return true end
    MySQL.update.await('UPDATE player_karma SET karma = ?, last_update = ? WHERE identifier = ?', { newVal, os.time(), id })
    if is_src then
        TriggerClientEvent('karma:updated', src, newVal, reason)
    end
    if Config.Debug then
        print(('[DEBUG] Karma changed for %s: %d → %d (Reason: %s)'):format(id, current, newVal, reason or 'manual'))
    end
    if Config.Webhook then
        PerformHttpRequest(Config.Webhook, function() end, 'POST',
            json.encode({
                content = Strings.webhook_message
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
    if not e then
        if Config.Debug then print('[DEBUG] ApplyKarmaEvent failed: invalid event ' .. event) end
        return
    end
    local reason = Strings[e.reason_key] or e.reason_key
    local lastKarma = GetKarma(src)
    local updated = lastKarma + e.amount
    SetKarma(src, updated, reason)
    if Config.Debug then
        print(('[DEBUG] Applied karma event "%s" for player %s: %d → %d'):format(event, Identifier(src) or 'unknown', lastKarma, updated))
    end
end
local function HasKarmaForEvent(src, event)
    local gate = Gating[event]
    if not gate then return true, nil end
    local current = GetKarma(src)
    local allowed = true
    local message = nil
    if gate.min and current < gate.min then
        allowed = false
        message = Strings.gatingTooLow
    end
    if gate.max and current > gate.max then
        allowed = false
        message = Strings.gatingTooHigh
    end
    if Config.Debug then
        print(('[DEBUG] Karma gate check for player %s on event "%s": min=%s, max=%s, has=%d, allowed=%s'):format(
            Identifier(src) or 'unknown', event, tostring(gate.min or 'none'), tostring(gate.max or 'none'), current, tostring(allowed)
        ))
    end
    return allowed, message
end
local function ApplyOnlineRegen(src)
    local id = Identifier(src)
    if not id then return end
    local current = GetKarma(src)
    local base = Config.BaseKarma
    local diff = base - current
    if diff == 0 then return end
    local new = current
    if diff > 0 then
        if not Config.RegenAddWhenBelow then return end
        new = current + Config.RegenAddPerTick
        if new > base then new = base end
    elseif diff < 0 then
        if not Config.RegenRemoveWhenAbove then return end
        new = current - Config.RegenRemovePerTick
        if new < base then new = base end
    end
    if new ~= current then
        SetKarma(src, new, Strings.regeneration)
    end
end
-- EXPORTS
exports('GetKarma', GetKarma)
exports('SetKarma', SetKarma)
exports('ApplyKarmaEvent', ApplyKarmaEvent)
exports('HasKarmaForEvent', HasKarmaForEvent)
exports('GetLangStrings', function() return Strings end)
exports('GetLangExports', function() return Exports end)
exports('GetDebugStrings', function() return DebugStrings end)
exports('GetDebugExports', function() return DebugExports end)
-- CALLBACK
QBCore.Functions.CreateCallback('karma:getKarma', function(source, cb)
    cb(GetKarma(source))
end)
QBCore.Functions.CreateCallback('karma:hasKarmaForEvent', function(source, cb, event)
    local allowed, msg = HasKarmaForEvent(source, event)
    cb(allowed, msg)
end)
-- PLAYER LOADED EVENT
RegisterNetEvent('karma:onPlayerLoaded', function()
    local src = source
    local id = Identifier(src)
    if not id then return end
    EnsureRow(id)
    local row = MySQL.single.await('SELECT karma, last_update FROM player_karma WHERE identifier=?', {id})
    local current = tonumber(row.karma)
    local last = tonumber(row.last_update)
    local seconds = os.time() - last
    local new_karma = CalculateRegen(current, seconds)
    if new_karma ~= current then
        SetKarma(src, new_karma, Strings.regenerationOffline)
    end
    MySQL.update.await('UPDATE player_karma SET last_update = ? WHERE identifier = ?', {os.time(), id})
    if Config.Debug then print('[DEBUG] Ensured karma row and applied offline regen for player ' .. id) end
end)
-- EVENT ENFORCEMENT
AddEventHandler('karma:onEventTrigger', function(event)
    local src = source
    local allowed, message = HasKarmaForEvent(src, event)
    if not allowed then
        TriggerClientEvent('QBCore:Notify', src, message or Strings.gatingBlocked, 'error')
        if Config.Debug then print('[DEBUG] Event ' .. event .. ' blocked for source ' .. src) end
        CancelEvent()
    end
end)
-- ADMIN COMMANDS
QBCore.Commands.Add(Commands.setKarma, 'Set player karma', {
    { name='id', help='Player ID' },
    { name='value', help='New karma value' }
}, true, function(source, args)
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    local val = tonumber(args[2])
    if not val then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid karma value', 'error')
        return
    end
    local success = SetKarma(target, val, "Admin set")
    if success then
        TriggerClientEvent('QBCore:Notify', source, Strings.adminSetKarma
            :gsub(Exports.PlayerName or '%%player%%', args[1])
            :gsub(Exports.PlayerKarma or '%%player_karma%%', args[2]), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to set karma', 'error')
    end
end, 'admin')
QBCore.Commands.Add(Commands.addKarma, 'Add or subtract karma', {
    { name='id', help='Player ID' },
    { name='amount', help='Amount (+/-)' }
}, true, function(source, args)
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    local amt = tonumber(args[2])
    if not amt then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid amount', 'error')
        return
    end
    local lastValue = GetKarma(target)
    local success = SetKarma(target, lastValue + amt, "Admin modify")
    if success then
        TriggerClientEvent('QBCore:Notify', source, Strings.adminAddKarma
            :gsub(Exports.PlayerName or '%%player%%', args[1])
            :gsub(Exports.Amount or '%%amount%%', args[2]), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to add karma', 'error')
    end
end, 'admin')
QBCore.Commands.Add(Commands.checkKarma, 'See player karma', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    local lastValue = GetKarma(target)
    TriggerClientEvent('QBCore:Notify', source, Strings.adminCheckKarma
        :gsub(Exports.PlayerName or '%%player%%', args[1])
        :gsub(Exports.PlayerKarma or '%%player_karma%%', tostring(lastValue)), 'primary')
end, 'admin')
QBCore.Commands.Add(Commands.resetKarma, 'Reset player karma to base', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    local success = SetKarma(target, Config.BaseKarma, "Admin reset")
    if success then
        TriggerClientEvent('QBCore:Notify', source, Strings.adminResetKarma
            :gsub(Exports.PlayerName or '%%player%%', args[1]), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to reset karma', 'error')
    end
end, 'admin')
QBCore.Commands.Add(Commands.debugKarma, 'Debug karma values', {
    { name='id', help='Player ID' }
}, true, function(source, args)
    if not Config.Debug then
        TriggerClientEvent('QBCore:Notify', source, '[DEBUG] Debug mode is disabled.', 'error')
        return
    end
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    local value = GetKarma(target)
    TriggerClientEvent('QBCore:Notify', source, DebugStrings.adminCheckKarma
        :gsub(DebugExports.PlayerName or '%%player%%', args[1])
        :gsub(DebugExports.PlayerKarma or '%%player_karma%%', tostring(value)), 'primary')
end, 'admin')
-- ONLINE REGEN LOOP
CreateThread(function()
    while true do
        Wait(tick_seconds * 1000)
        for _, src in pairs(QBCore.Functions.GetQBPlayers()) do
            ApplyOnlineRegen(src)
        end
    end
end)
