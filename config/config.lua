-- Main system configuration for the Karma / Reputation System
Config = {}
-- ============================================
-- BASE KARMA VALUES
-- ============================================
Config.BaseKarma = 450 -- Starting karma for every player
Config.MinKarma = 0 -- Minimum karma allowed
Config.MaxKarma = 1000 -- Maximum karma allowed
-- ============================================
-- KARMA REGENERATION SYSTEM
-- ============================================
Config.RegenTickUnit = 's' -- 's' seconds, 'm' minutes, 'h' hours, 'd' days, 'mo' months
Config.RegenTickValue = 120 -- The number for the unit, e.g., 10 minutes
Config.RegenAddPerTick = 30 -- Amount to add per tick when below base
Config.RegenRemovePerTick = 50 -- Amount to remove per tick when above base
Config.RegenAddWhenBelow = true -- Enable adding when below base
Config.RegenRemoveWhenAbove = true -- Enable removing when above base
-- ============================================
-- LOG & WEBHOOK SETTINGS
-- ============================================
Config.Webhook = nil -- Set to your Discord webhook URL for notifications
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
