-- Debug language strings for admin monitoring
DebugStrings = {
    karmaUpdated = '[DEBUG] Reputation changed: %last% → %player_karma%',
    karmaUpdatedReason = '[DEBUG] Reputation changed by %amount%: %last% → %player_karma%. Reason: %reason%',
    gatingTooLow = '[DEBUG] Karma gate blocked: reputation too low for event.',
    gatingTooHigh = '[DEBUG] Karma gate blocked: reputation too high for event.',
    regeneration = '[DEBUG] Karma regeneration applied (online).',
    regenerationOffline = '[DEBUG] Karma regeneration applied (offline).',
    adminSetKarma = '[DEBUG] Admin manually set karma for %player%: %last% → %player_karma%',
    adminAddKarma = '[DEBUG] Admin manually adjusted karma for %player%: %last% → %player_karma% by %amount%',
    adminCheckKarma = '[DEBUG] Checked karma for %player%: %player_karma%',
    adminResetKarma = '[DEBUG] Karma reset for %player%'
}
DebugExports = {
    PlayerName = '%player%',
    PlayerKarma = '%player_karma%',
    Amount = '%amount%',
    Reason = '%reason%',
    LastKarma = '%last%',
    Event = '%event%'
}
