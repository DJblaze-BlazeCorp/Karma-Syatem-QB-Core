-- Language strings for user-facing messages
Strings = {
    karmaUpdated = 'Reputation updated. New value: {player_karma}',
    karmaUpdatedReason = 'Reputation updated by {amount}. Reason: {reason}',
    gatingTooLow = 'Your reputation is too low to access this event.',
    gatingTooHigh = 'Your reputation is too high to access this event.',
    gatingBlocked = 'You do not have enough reputation to access this event.', -- Fallback, but now using specific too low/high
    regeneration = 'Reputation regeneration applied.',
    regenerationOffline = 'Offline reputation regeneration applied.',
    adminSetKarma = 'Admin set karma for ID {player} to {player_karma}.',
    adminAddKarma = 'Admin adjusted karma for ID {player} by {amount}.',
    adminCheckKarma = 'Karma for player {player} is {player_karma}.',
    adminResetKarma = 'Karma reset for player {player}.',
    webhook_message = 'Karma │ {player} → {player_karma} │ {reason}',
    -- Event reasons
    recycle_duty = 'Going on recycling duty',
    help_civilian = 'Helped a civilian',
    revived_player = 'Revived a downed player',
    completed_job = 'Completed legal job',
    rescued_injured = 'Rescued an injured civilian',
    protected_store = 'Helped stop a robbery',
    bank_robbery = 'Bank robbery',
    store_rob_register = "Robbed a store register",
    store_rob_safe = "Robbed a store safe",
    player_killed = 'Killed a player',
    police_attack = 'Attacked law enforcement',
    hostage_taken = 'Took a hostage',
}
-- Exports for dynamic placeholders
Exports = {
    PlayerName = '{player}',
    PlayerKarma = '{player_karma}',
    Amount = '{amount}',
    Reason = '{reason}',
    Event = '{event}',
    Min = '{min}',  -- Added for gating min value
    Max = '{max}'   -- Added for gating max value
}
