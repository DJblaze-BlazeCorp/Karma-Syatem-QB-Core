-- config/removing.lua
-- Negative karma events (removing or subtracting karma)
Config.RemoveKarmaEvents = {
    bank_robbery     = { amount = -50, reason = 'Bank robbery' },
    store_robbery    = { amount = -10, reason = 'Store robbery' },
    player_killed    = { amount = -5,  reason = 'Killed a player' },
    police_attack    = { amount = -15, reason = 'Attacked law enforcement' },
    hostage_taken    = { amount = -25, reason = 'Took a hostage' }
}