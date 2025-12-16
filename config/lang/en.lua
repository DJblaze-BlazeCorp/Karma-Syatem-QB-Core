-- config/lang/en.lua
-- Language strings for user-facing messages
Strings = {
    karmaUpdated        = 'Reputation updated. New value: %player_karma%',
    karmaUpdatedReason  = 'Reputation updated by %amount%. Reason: %reason%',
    gatingBlocked       = 'You do not have enough reputation to access this event.',
    regeneration        = 'Reputation regeneration applied.',
    regenerationOffline = 'Offline reputation regeneration applied.',
    adminSetKarma       = 'Admin set karma for ID %player% to %player_karma%.',
    adminAddKarma       = 'Admin adjusted karma for ID %player% by %amount%.',
    adminCheckKarma     = 'Karma for player %player% is %amount%.',
    adminResetKarma     = 'Karma reset for player %player%.'
}

-- Exports for dynamic placeholders
Exports = {
    PlayerName    = '%player%',
    PlayerKarma   = '%player_karma%',
    Amount        = '%amount%',
    Reason        = '%reason%',
    Event         = '%event%'
}
