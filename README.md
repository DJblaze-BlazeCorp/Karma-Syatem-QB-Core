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

```


## Features

* Positive and negative karma events with reason tracking
* Configurable karma min, max, base, and regeneration timers
* Event gating system based on `gating.lua`
* Admin commands: set, add, reset, check, and debug karma
* Webhook notifications for karma changes
* Modular language support including debug logs

---

## Installation

1. Place the `karma_system` folder in your server’s `resources` directory.
2. Add `ensure karma_system` to your `server.cfg`.
3. Ensure dependencies:

   ```
   qb-core (v1.1+)
   oxmysql
   ```
4. Restart the server. Karma tables will auto-generate in your database.

---

## Configuration

### `config/config.lua`

* Base karma values, min/max, negative permission
* Karma regeneration timers
* Webhook configuration
* Admin whitelist
* Language and debug selection

### `config/gating.lua`

* Assign minimum karma values for server events:

```lua
Config.Gating = {
    event_help_civilian      = 10,
    event_revived_player     = 15,
    event_completed_job      = 5,
}
```

### `config/adding.lua` & `config/removing.lua`

* Define events and karma impact:

```lua
help_civilian = { amount = 10, reason = "Helped a civilian" }
bank_robbery  = { amount = -50, reason = "Bank robbery" }
```

---

## File Structure

```
karma_system/
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
```

---

## Usage

### Server-Side

```lua
exports['karma_system']:ApplyKarmaEvent('help_civilian', playerId)
exports['karma_system']:SetKarma(playerId, 75, "Manual adjustment")
local karma = exports['karma_system']:GetKarma(playerId)
local canAccess = exports['karma_system']:HasKarmaForEvent(playerId, 'event_bank_robbery')
```

### Client-Side

```lua
TriggerKarmaEvent('help_civilian')
GetLocalKarma(function(k) print("Your Karma: "..k) end)
```

---

## Language & Debug System

* **Main Language**: `config/lang/en.lua`
* **Debug Language**: `config/lang/debug/en.lua`

Example placeholders:

```lua
Strings.karmaUpdated         -- "Reputation updated. New value: %player_karma%"
DebugStrings.karmaUpdated    -- "[DEBUG] Reputation set: %player_karma%"
```

---

## Admin Commands

| Command    | Description                      | Args       |
| ---------- | -------------------------------- | ---------- |
| setkarma   | Sets a player’s karma            | id, value  |
| addkarma   | Adds/subtracts karma             | id, amount |
| checkkarma | Checks a player’s current karma  | id         |
| resetkarma | Resets karma to base             | id         |
| debugkarma | Debug output of a player’s karma | id         |

---

## Events & Exports

**Exports**

```lua
GetKarma(sourceOrIdentifier)
SetKarma(sourceOrIdentifier, value, reason)
ApplyKarmaEvent(eventName, source)
HasKarmaForEvent(source, eventName)
GetLangStrings()
GetDebugStrings()
```

**Events**

* `karma:updated` → Triggered on karma change
* `karma:onPlayerLoaded` → Ensures player row exists on load

---

## Performance & Safety

* Uses prepared statements with `oxmysql`
* Optimized regeneration to reduce DB writes
* Event gating prevents unauthorized access based on karma
* Admin commands include safety checks

---

## Contributing

* Fork repository for fixes or features
* Maintain modular config structure and language support

---

## Notes

* Ensure `oxmysql` is installed
* Test events and karma in staging before production
* Debug language provides verbose outputs for monitoring

---

**End of README.md**