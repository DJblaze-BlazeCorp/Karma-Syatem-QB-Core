-- config/gating.lua
-- Event gating configuration
-- Specify the minimum and/or maximum karma required for specific events
Config.Gating = {
    event_help_civilian = { min = 10 },
    event_revived_player = { min = 15 },
    event_completed_job = { min = 5 },
    event_rescued_injured = { min = 12 },
    event_protected_store = { min = 20 },
    event_bank_robbery = { max = 50 },
    event_store_robbery = { max = 500 }, -- Players with karma >= 50 cannot rob
    event_player_killed = { max = 5 },
    event_police_attack = { max = 15 },
    event_hostage_taken = { max = 25 },
    -- Example for cop duty (add as needed)
    event_go_on_duty_cop = { min = 70 }
}
