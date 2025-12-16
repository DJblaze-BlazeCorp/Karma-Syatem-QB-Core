# README.md: Karma / Reputation System for QBCore (FiveM)

![Karma System Banner](https://via.placeholder.com/800x200?text=Karma+System) <!-- Placeholder for a banner image; replace with actual if available -->

## Overview

The Karma / Reputation System is a comprehensive Lua-based script designed for FiveM servers using the QBCore framework. It introduces a dynamic reputation (karma) mechanic where players start with a configurable base karma score (default: 50). Karma fluctuates based on in-game actions—positive actions increase it (e.g., reviving a player grants +15), while negative ones decrease it (e.g., killing a player deducts -5). The system includes event gating to restrict access to certain activities based on karma levels, preventing "good" players from committing crimes or "bad" players from heroic deeds. It integrates seamlessly with QBCore's notification and command systems, uses MySQL for persistent storage, and supports debugging, webhooks, and modular configurations.

This system enhances roleplay by enforcing consequences for actions, encouraging balanced gameplay. It's modular, extensible, and developer-friendly, allowing easy integration with other scripts via exports.

### Key Features
- **Base Karma Management**: Configurable starting (50), minimum (0), and maximum (100) values. Optional negative karma support.
- **Regeneration System**: Karma regenerates toward the base over time—600 minutes online or 150 minutes offline (implementation pending; see Customization section).
- **Event-Based Karma Changes**: Pre-defined positive and negative events with customizable amounts and reasons.
- **Event Gating**: Min/max karma requirements for events (e.g., bank robbery requires karma ≤ 50).
- **Admin Commands**: Secure commands for managing karma (set, add, check, reset, debug) with admin permissions.
- **Notifications**: Uses QBCore's notify system for real-time feedback on karma updates.
- **Database Integration**: Stores data in a `player_karma` MySQL table (auto-created on startup).
- **Logging & Webhooks**: Debug console logs and optional Discord webhooks for karma changes.
- **Language Support**: Modular language files for user messages and debug outputs (default: English).
- **Exports for Integration**: Server-side functions to get/set karma, apply events, and check gating from other scripts.
- **Debug Mode**: Extensive console logging for troubleshooting.

This script is ideal for RP servers aiming to add depth to player interactions without overcomplicating core mechanics.

## Installation

1. **Prerequisites**:
   - FiveM server with QBCore framework installed.
   - MySQL database (compatible with oxmysql or similar).
   - Admin permissions configured in QBCore for commands.

2. **Setup Steps**:
   - Download the script and extract it to your server's `resources` folder (e.g., `resources/karma`).
   - Add the following to your `server.cfg`:
     ```
     ensure karma
     ```
   - Restart the server. The script will automatically create the `player_karma` table in your database:
     ```sql
     CREATE TABLE IF NOT EXISTS player_karma (
         identifier VARCHAR(50) NOT NULL PRIMARY KEY,
         karma INT NOT NULL DEFAULT 50,
         last_update BIGINT NOT NULL DEFAULT 0
     );
     ```
   - Verify installation: Join the server and check console for language load/debug messages (if `Config.Debug = true`).

If issues arise (e.g., missing dependencies), check server console for errors like "Missing language file".

## Configuration

All configurations are modular for easy editing. Primary file: `config/config.lua`.

### Base Settings (`config/config.lua`)
- `Config.BaseKarma = 50`: Starting karma for new players.
- `Config.MinKarma = 0`: Lowest karma (unless `Config.AllowNegative = true`).
- `Config.MaxKarma = 100`: Highest karma.
- `Config.RegenToBaseMinutesOnline = 600`: Time (minutes) to regen to base while online.
- `Config.RegenToBaseMinutesOffline = 150`: Time for offline regen.
- `Config.Webhook = nil`: Discord webhook URL for logs (set to a string URL to enable).
- `Config.WebhookMessage = 'Karma │ %player% → %player_karma% │ %reason%'`: Customizable webhook format.
- `Config.Language = 'en'`: User-facing language.
- `Config.DebugLanguage = 'en'`: Debug language.
- `Config.Debug = true`: Enable console debug logs.
- `Config.Admins = {}`: Whitelist for admins (currently unused; extend if needed).

### Commands (`config/commands.lua`)
Customize command names:
```lua
Config.Commands = {
    setKarma = 'setkarma',
    addKarma = 'addkarma',
    checkKarma = 'checkkarma',
    resetKarma = 'resetkarma',
    debugKarma = 'debugkarma'
}
```
These integrate with QBCore's command system in `server.lua`.

### Positive Events (`config/adding.lua`)
Add or modify events that increase karma:
```lua
Config.AddKarmaEvents = {
    help_civilian = { amount = 10, reason = 'Helped a civilian' },
    revived_player = { amount = 15, reason = 'Revived a downed player' },
    -- Add custom: my_custom_event = { amount = 25, reason = 'Custom good deed' }
}
```

### Negative Events (`config/removing.lua`)
Events that decrease karma (use negative amounts):
```lua
Config.RemoveKarmaEvents = {
    bank_robbery = { amount = -50, reason = 'Bank robbery' },
    -- Add custom: my_bad_event = { amount = -30, reason = 'Bad action' }
}
```

### Event Gating (`config/gating.lua`)
Define min/max requirements for events:
```lua
Config.Gating = {
    event_help_civilian = { min = 10 },
    event_bank_robbery = { max = 50 },
    -- Custom: my_event = { min = 20, max = 80 }
}
```
Events prefixed with `event_` for clarity.

### Language Files
- `config/lang/en.lua`: User messages (e.g., notifications).
  ```lua
  Strings = {
      karmaUpdatedReason = 'Reputation updated by %amount%. Reason: %reason%',
      -- Customize or add new strings
  }
  Exports = { -- Placeholders for string gsub
      Amount = '%amount%',
      Reason = '%reason%'
  }
  ```
- `config/lang/debug/en.lua`: Debug-specific messages.

Add new languages by creating files like `fr.lua` and updating `Config.Language`.

## Usage

### In-Game Player Experience
- **On Join**: Karma loads automatically via `QBCore:Client:OnPlayerLoaded` and `karma:onPlayerLoaded`.
- **Karma Updates**: When an event triggers (e.g., reviving), karma changes, and a notification appears: "Reputation updated by 15. Reason: Revived a downed player".
- **Gating**: Attempting a gated event (e.g., bank robbery with high karma) shows an error: "Your reputation is too high to access this event."
- **Regeneration**: (Pending full implementation) Karma drifts back to base over time.

### Admin Commands
Run as admin (QBCore permission: 'admin'):
- `/setkarma [playerID] [value]`: Set to exact value.
- `/addkarma [playerID] [amount]`: Add positive/negative amount.
- `/checkkarma [playerID]`: View current karma.
- `/resetkarma [playerID]`: Reset to base.
- `/debugkarma [playerID]`: Detailed debug info (if debug enabled).

Commands validate inputs and log to console.

### Integrating with Other Scripts
Use exports for seamless integration.

#### Server-Side Exports
- `exports['karma']:GetKarma(sourceOrIdentifier)`: Retrieve karma.
  ```lua
  local karma = exports['karma']:GetKarma(source)
  print("Player karma: " .. karma)
  ```
- `exports['karma']:SetKarma(srcOrId, value, reason)`: Set karma and notify.
  ```lua
  exports['karma']:SetKarma(source, 75, 'Admin adjustment')
  ```
- `exports['karma']:ApplyKarmaEvent(event, src)`: Apply configured event.
  ```lua
  exports['karma']:ApplyKarmaEvent('revived_player', source)  -- +15 karma
  ```
- `exports['karma']:HasKarmaForEvent(src, event)`: Check gating.
  ```lua
  local allowed, message = exports['karma']:HasKarmaForEvent(source, 'event_bank_robbery')
  if not allowed then
      TriggerClientEvent('QBCore:Notify', source, message, 'error')
      return
  end
  -- Proceed with robbery logic
  ```
- Language Exports: `GetLangStrings()`, `GetLangExports()`, etc., for custom UIs.

#### Client-Side
- `GetLocalKarma(cb)`: Callback for local karma.
  ```lua
  GetLocalKarma(function(karma)
      print("My karma: " .. karma)
  end)
  ```
- `TriggerKarmaEvent(event)`: Trigger server gating check.
  ```lua
  TriggerKarmaEvent('event_my_custom')
  ```

Hook into events like `karma:updated` for custom UI.

## Debugging and Troubleshooting

- **Enable Debug**: Set `Config.Debug = true` in `config/config.lua`. This prints detailed logs:
  - "[DEBUG] Karma changed for [id]: 50 → 65 (Reason: Revived a downed player)"
  - "[DEBUG] Applied karma event 'revived_player' for player [id]: 50 → 65"
  - Command executions, gating checks, etc.
- **Common Issues**:
  - **No Notifications**: Ensure `QBCore.Functions.Notify` works. Test with `/addkarma`. Check if `karma:updated` triggers (add print in client.lua).
  - **Database Errors**: Verify MySQL connection. Table auto-creates; check for SQL errors in console.
  - **Invalid IDs/Events**: Commands/exports validate and log failures (e.g., "[DEBUG] setkarma failed: invalid target ID").
  - **Gating Not Working**: Confirm event names match (e.g., 'event_bank_robbery'). Test with `HasKarmaForEvent`.
- **Testing**: Use `/debugkarma [id]` for verbose output. Monitor console during actions.

If notifications fail, add more prints in `SetKarma` or `karma:updated`.

## Customization and Advanced Editing

### Adding Regeneration
The config has regen times, but implementation is partial. Add in `server.lua`:
```lua
-- Online Regen Thread (example)
CreateThread(function()
    while true do
        Wait(60000)  -- Every minute
        for _, player in pairs(QBCore.Functions.GetPlayers()) do
            local id = Identifier(player)
            local current = GetKarma(id)
            if current ~= Config.BaseKarma then
                local adjust = (current > Config.BaseKarma) and -1 or 1
                SetKarma(player, current + adjust, 'Regeneration')
                if Config.Debug then print('[DEBUG] Regen for ' .. id .. ': ' .. current .. ' → ' .. (current + adjust)) end
            end
        end
    end
end)

-- Offline Regen: On load in EnsureRow or GetKarma
local function CalculateOfflineRegen(id)
    local lastUpdate = MySQL.scalar.await('SELECT last_update FROM player_karma WHERE identifier=?', {id})
    local timeDiff = os.time() - lastUpdate
    local minutesOffline = timeDiff / 60
    local regenSteps = math.floor(minutesOffline / (Config.RegenToBaseMinutesOffline / (Config.MaxKarma - Config.MinKarma)))
    -- Adjust karma toward base by regenSteps
    -- Update last_update on save
end
```
Call in `GetKarma` before returning.

### Adding New Events
1. Add to `adding.lua` or `removing.lua`.
2. Add gating to `gating.lua` if needed.
3. In other scripts, call `ApplyKarmaEvent` or trigger `karma:onEventTrigger` for gating.

### Extending Languages
Create `config/lang/fr.lua` with translated `Strings` and `Exports`. Set `Config.Language = 'fr'`.

### Webhook Customization
Format uses placeholders from `Exports`. Add more in language files.

### Allowing Negative Karma
In `SetKarma`, modify:
```lua
local newVal = Config.AllowNegative and value or math.max(Config.MinKarma, math.min(value, Config.MaxKarma))
```

### Best Practices
- **Modularity**: Keep custom events in separate configs for easy updates.
- **Performance**: Avoid heavy loops; use threads sparingly.
- **Security**: Commands are admin-only; add checks if extending.
- **Testing**: Use a dev server. Simulate events with commands.
- **Contributions**: Fork and PR for features like full regen or UI integration.

For questions, check console debugs or community forums. Last updated: [Insert Date].
