-- config/lang/en.lua
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
    adminResetKarma = 'Karma reset for player {player}.'
}
-- Exports for dynamic placeholders
Exports = {
    PlayerName = '{player}',
    PlayerKarma = '{player_karma}',
    Amount = '{amount}',
    Reason = '{reason}',
    Event = '{event}'
}
