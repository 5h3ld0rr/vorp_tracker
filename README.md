# VORP Tracker

A Red Dead Redemption 2 (RedM) resource for VORP Core that provides real-time tracking of law enforcement and medical personnel on the map using blips.

## Description

VORP Tracker allows on-duty law enforcement and medical personnel to see each other's locations on the map through blips. Players with tracker items will appear as blips to other on-duty personnel, facilitating coordination and response times.

## Features

- **Real-time tracking**: Updates player positions every second
- **Job-specific tracking**: Supports Sheriff, Doctor, and Nurse roles
- **On-duty detection**: Only shows tracked players when they are on duty
- **Inventory integration**: Requires tracker item in inventory to be tracked
- **Customizable blips**: Different colors and styles for different job types
- **Automatic cleanup**: Removes blips when players go off duty or disconnect

## Dependencies

- **VORP Core**: Main framework
- **VORP Inventory**: For tracker item management

## Installation

1. Download the resource and place it in your `resources` folder
2. Add `ensure vorp_tracker` to your `server.cfg`
3. Restart your server

## Configuration

### Tracker Item

By default, the tracker item is named `"tracker"`. You can change this in `config.lua`:

```lua
Config.TrackerItem = "tracker"
```

### Update Interval

The tracking updates every 1000ms (1 second). Adjust as needed:

```lua
Config.UpdateInterval = 1000  -- in milliseconds
```

### Job Configuration

Configure blip appearance for each job type:

```lua
Config.Tracker = {
    Sheriff = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_BLUE"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_PULSE_FOREVER")
    },
    Doctor = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_RED"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_PULSE_FOREVER")
    },
    Nurse = {
        BlipSprite = GetHashKey("blip_ambient_law"),
        BlipModifier = GetHashKey("BLIP_MODIFIER_DEBUG_RED"),
        BlipStyle = GetHashKey("BLIP_MODIFIER_AREA_CLAMPED_PULSE")
    },
}
```

### Duty Detection

Customize how the system detects if a player is on duty:

```lua
Config.OnDuty = function(source, job)
    if job == "Sheriff" then
        return exports.outsider_policeman:IsOnPoliceDuty(source)
    elseif job == "Doctor" or job == "Nurse" then
        return exports.outsider_medicalman:IsOnMedicalDuty(source)
    end
    return false
end
```

## How It Works

1. **Server-side tracking**: The server continuously monitors all players with eligible jobs
2. **Inventory check**: Players must have the tracker item in their inventory to be tracked
3. **Duty verification**: Only on-duty personnel can see tracker blips
4. **Client updates**: On-duty players receive real-time updates of tracked personnel locations
5. **Blip management**: Client-side creates and manages blips for tracked players

## Supported Jobs

- **Sheriff**: Law enforcement with blue blips
- **Doctor**: Medical personnel with red blips
- **Nurse**: Medical personnel with red pulsing area blips

## Usage

1. Ensure players have the tracker item in their inventory
2. Go on duty using your respective duty system
3. Tracked personnel will appear as blips on your map
4. Blips show the player's name and job title

## Blip Reference

For customizing blip sprites and modifiers, refer to the [RDR3 Discoveries documentation](https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs).

## Contributing

We welcome contributions to improve VORP Tracker!

Feel free to open an issue first to discuss major changes or new features!
