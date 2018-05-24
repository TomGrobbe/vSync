# vSync

### Simple weather and time sync script for FiveM servers.

**Current version:** 1.4.0
**Author:** Vespura
**Last update:** 05-24-2018

***

# Features
- Dynamic changing weather every 10 minutes (can be (temporarily or permanently) disabled. The weather will only change according to realistic patterns. Some types like snow, xmas, halloween and neutral have been disabled. This means that if the weather is currenlty one of those types, it won't be changed. It will also never change to those types.
- Blackout. Enable/disable this in the config or using /blackout ingame.
- Weather and Time synced across all players.
- Custom permissions for the commands.
- Adds corresponding menu entries to [Universal Menu](https://github.com/FiveM-Scripts/fivem-universal-menu) if installed (only for permitted players)

# Commands
`/weather <type>` Change the weather type (will fade to the new weather type within 15 seconds).
`/freezeweather` Enable/disable dynamic weather changes.
`/time <h> <m>` Set the time.
`/freezetime` Freeze/unfreeze time.
`/morning` Set the time to morning.
`/noon` Set the time to noon.
`/evening` Set the time to evening.
`/night` Set the time to night.
`/blackout` Enable/disable blackout mode.
