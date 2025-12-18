-- Negative karma events (removing or subtracting karma)
Config.RemoveKarmaEvents = {
    store_rob_register = { amount = -20, reason_key = 'store_rob_register' },
    store_rob_safe = { amount = -30, reason_key = 'store_rob_safe' },
    bank_robbery = { amount = -50, reason_key = 'bank_robbery' },
    store_robbery = { amount = -25, reason_key = 'store_robbery' },
    player_killed = { amount = -5, reason_key = 'player_killed' },
    police_attack = { amount = -15, reason_key = 'police_attack' },
    hostage_taken = { amount = -25, reason_key = 'hostage_taken' }
}
