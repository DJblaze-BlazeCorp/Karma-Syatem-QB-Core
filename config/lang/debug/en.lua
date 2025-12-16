-- config/lang/debug/en.lua
-- Debug language strings for admin monitoring
DebugStrings = {
    karmaUpdated        = '[DEBUG] Reputation changed: %last% → %player_karma%',
    karmaUpdatedReason  = '[DEBUG] Reputation changed by %amount%: %last% → %player_karma%. Reason: %reason%',
    gatingBlocked       = '[DEBUG] Karma gate blocked for event.',
    regeneration        = '[DEBUG] Karma regeneration applied (online).',
    regenerationOffline = '[DEBUG] Karma regeneration applied (offline).',
    adminSetKarma       = '[DEBUG] Admin manually set karma for %player%: %last% → %player_karma%',
    adminAddKarma       = '[DEBUG] Admin manually adjusted karma for %player%: %last% → %player_karma% by %amount%',
    adminCheckKarma     = '[DEBUG] Checked karma for %player%: %last% → %player_karma%',
    adminResetKarma     = '[DEBUG] Karma reset for %player%'
}

DebugExports = {
    PlayerName    = '%player%',
    PlayerKarma   = '%player_karma%',
    Amount        = '%amount%',
    Reason        = '%reason%',
    LastKarma     = '%last%',
    Event         = '%event%'
}
