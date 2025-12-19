-- Event gating configuration
-- Specify the minimum and/or maximum karma required for specific events
Config.Gating = {
    event_help_civilian   = { min = 10 },
    event_revived_player  = { min = 15 },
    event_completed_job   = { min = 5 },
    event_rescued_injured = { min = 12 },
    event_protected_store = { min = 20 },

    event_bank_robbery    = { max = 50 },
	store_rob_register    = { max = 500 },
    store_rob_safe        = { max = 400 },
    event_player_killed   = { max = 5 },
    event_police_attack   = { max = 15 },
    event_hostage_taken   = { max = 25 },

    -- 🔴 Recycling duty gate
    event_recycle_duty_toggle = { min = 450 }
}
