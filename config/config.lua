-- Main system configuration for the Karma / Reputation System
Config = {}
-- ============================================
-- BASE KARMA VALUES
-- ============================================
Config.BaseKarma = 50 -- Starting karma for every player
Config.MinKarma = 0 -- Minimum karma allowed
Config.MaxKarma = 100 -- Maximum karma allowed
Config.AllowNegative = true -- Allow karma to go below 0
-- ============================================
-- KARMA REGENERATION SYSTEM
-- ============================================
Config.RegenToBaseMinutesOnline = 600 -- Minutes to regenerate to base while online
Config.RegenToBaseMinutesOffline = 150 -- Minutes to regenerate to base while offline
-- ============================================
-- LOG & WEBHOOK SETTINGS
-- ============================================
Config.Webhook = nil
Config.WebhookMessage = 'Karma │ %player% → %player_karma% │ %reason%'
-- ============================================
-- LANGUAGE SETTINGS
-- ============================================
Config.Language = 'en'
Config.DebugLanguage = 'en' -- Debug messages language
-- ============================================
-- DEBUG TOGGLE
-- ============================================
Config.Debug = true -- Set to false to disable debug logging entirely
-- ============================================
-- ADMIN WHITELIST
-- ============================================
Config.Admins = {}
-- ============================================
-- ADMIN COMMAND CONFIGURATION
-- ============================================
Config.Commands = {
    setKarma = 'setkarma',
    addKarma = 'addkarma',
    checkKarma = 'checkkarma',
    resetKarma = 'resetkarma',
    debugKarma = 'debugkarma'
}
-- ============================================
-- EVENT GATING CONFIGURATION
-- ============================================
Config.Gating = {
    event_help_civilian = { min = 10 },
    event_revived_player = { min = 15 },
    event_completed_job = { min = 5 },
    event_rescued_injured = { min = 12 },
    event_protected_store = { min = 20 },
    event_bank_robbery = { max = 50 },
    event_store_robbery = { max = 200 },
    event_player_killed = { max = 5 },
    event_police_attack = { max = 15 },
    event_hostage_taken = { max = 25 },
    -- Example for cop duty (add as needed)
    event_go_on_duty_cop = { min = 70 }
}
-- ============================================
-- POSITIVE KARMA EVENTS
-- ============================================
Config.AddKarmaEvents = {
    help_civilian = { amount = 10, reason = 'Helped a civilian' },
    revived_player = { amount = 15, reason = 'Revived a downed player' },
    completed_job = { amount = 5, reason = 'Completed legal job' },
    rescued_injured = { amount = 12, reason = 'Rescued an injured civilian' },
    protected_store = { amount = 20, reason = 'Helped stop a robbery' }
}
-- ============================================
-- NEGATIVE KARMA EVENTS
-- ============================================
Config.RemoveKarmaEvents = {
    bank_robbery = { amount = -50, reason = 'Bank robbery' },
    store_robbery = { amount = -10, reason = 'Store robbery' },
    player_killed = { amount = -5, reason = 'Killed a player' },
    police_attack = { amount = -15, reason = 'Attacked law enforcement' },
    hostage_taken = { amount = -25, reason = 'Took a hostage' }
}
