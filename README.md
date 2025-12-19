# QBCore Karma / Reputation System  
Version **1.8.0** — Full Modular Configuration, Event Gating Only, Admin Tools, SQL Tracking, Language Exports, Debug Language Support

---

## Table of Contents
1. [Overview](#overview)  
2. [Features](#features)  
3. [Installation](#installation)  
4. [Configuration](#configuration)  
5. [File Structure](#file-structure)  
6. [Usage](#usage)  
7. [Language & Debug System](#language--debug-system)  
8. [Admin Commands](#admin-commands)  
9. [Events & Exports](#events--exports)  
10. [Performance & Safety](#performance--safety)  
11. [Contributing](#contributing)  
12. [Notes](#notes)  

---

## Overview
The **QBCore Karma / Reputation System** introduces a persistent **reputation score** for each player in your FiveM server.  
This score is influenced by player actions, admin commands, and automated events.  

Key concepts:
- **Karma/ Reputation**: Tracks how "good" or "bad" a player’s actions are, shaping gameplay experiences.  
- **SQL Tracking**: Each player’s karma is stored permanently using `oxmysql`. This ensures persistence across sessions.  
- **Event Gating**: Specific server events are only accessible when a player has sufficient karma, defined in `gating.lua`.  
- **Admin Tools**: Full control over player karma, including debug checks, event triggers, and direct setting of values.  
- **Language Support**: Configurable language files for messages and debug outputs, supporting internationalization.

---

## Features

* Positive and negative karma events with reason tracking
* Configurable karma min, max, base, and regeneration timers
* Event gating system based on `gating.lua` with min/max thresholds
* Admin commands: set, add, reset, check, and debug karma
* Webhook notifications for karma changes
* Modular language support including debug logs

---

## Installation

1. Place the resource folder (e.g., `karma-system`) in your server’s `resources` directory.
2. Add `ensure karma-system` to your `server.cfg` (replace with actual folder name).
3. Ensure dependencies:
   - qb-core (v1.1+)
   - oxmysql
4. Restart the server. Karma tables will auto-generate in your database.

---

## Configuration

### `config/config.lua`

* Base karma values, min/max
* Karma regeneration timers and units
* Webhook URL (set to a valid Discord webhook for notifications)
* Language and debug selection
* Debug toggle

### `config/gating.lua`

* Assign minimum and/or maximum karma values for server events:

```
Config.Gating = {
    event_help_civilian = { min = 10 },
    event_bank_robbery = { max = 50 },
    recycle_duty_toggle = { min = 10 },
}
```

### `config/adding.lua` & `config/removing.lua`

* Define events, karma impact, and reason keys (mapped to Strings in lang files):

```
Config.AddKarmaEvents = {
    help_civilian = { amount = 10, reason_key = 'help_civilian' },
}
Config.RemoveKarmaEvents = {
    bank_robbery = { amount = -50, reason_key = 'bank_robbery' },
}
```

### `config/commands.lua`

* Customize command names for admin tools.

---

## File Structure

```
karma-system/
├─ fxmanifest.lua
├─ server.lua
├─ client.lua
├─ config/
│  ├─ config.lua
│  ├─ commands.lua
│  ├─ gating.lua
│  ├─ adding.lua
│  ├─ removing.lua
│  └─ lang/
│     ├─ en.lua
│     └─ debug/
│        └─ en.lua
├─ README.md
```

---

## Usage

### Server-Side (Exports)

```
exports['karma-system']:ApplyKarmaEvent('help_civilian', playerId)
exports['karma-system']:SetKarma(playerId, 75, "Manual adjustment")
local karma = exports['karma-system']:GetKarma(playerId)
local canAccess, msg = exports['karma-system']:HasKarmaForEvent(playerId, 'event_bank_robbery')
```

### Client-Side

To check gating before triggering a gated event:

```
TriggerKarmaEvent('some_gated_event')  -- Triggers server check; cancels if not allowed
```

To get local karma:

```
GetLocalKarma(function(k) print("Your Karma: " .. k) end)
```

---

## Language & Debug System

* **Main Language**: `config/lang/en.lua` - User notifications and reasons.
* **Debug Language**: `config/lang/debug/en.lua` - Admin/debug logs.

Placeholders use gsub for dynamic values (e.g., `{player}`, `{player_karma}`).

---

## Admin Commands

| Command     | Description                      | Args       |
| ----------- | -------------------------------- | ---------- |
| /setkarma   | Sets a player’s karma            | id, value  |
| /addkarma   | Adds/subtracts karma             | id, amount |
| /checkkarma | Checks a player’s current karma  | id         |
| /resetkarma | Resets karma to base             | id         |
| /debugkarma | Debug output of a player’s karma | id         |

---

## Events & Exports

**Exports**

- `GetKarma(sourceOrIdentifier)`
- `SetKarma(sourceOrIdentifier, value, reason)`
- `ApplyKarmaEvent(eventName, source)`
- `HasKarmaForEvent(source, eventName)`
- `GetLangStrings()`
- `GetDebugStrings()`

**Events**

- `karma:updated` (client) - Triggered on karma change with new value and reason.
- `karma:onPlayerLoaded` (server) - Ensures player data on load.
- `karma:onEventTrigger` (server) - Checks gating for events.

---

## Performance & Safety

* Uses prepared statements with `oxmysql` for security.
* Optimized regeneration to minimize DB writes.
* Event gating prevents unauthorized access.
* Admin commands include validation checks.
* Debug mode for detailed logging (toggle in config).

---

## Contributing

* Fork the repository for fixes or features.
* Maintain modular config structure and language support.

---

## Notes

* Ensure `oxmysql` is properly configured.
* Test events, gating, and karma changes in a staging environment.
* Debug language provides verbose outputs for monitoring.
* Resource name in exports may vary based on folder name.

---
