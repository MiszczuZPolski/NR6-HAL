# HAL Modules Reference

Complete reference for all **45 HAL editor modules**, auto-generated from
`addons/missionmodules/CfgVehicles.hpp` and the English stringtable.

Place modules in Eden editor under **Systems → Modules → HAL - Modules**.

## Categories

- **[Core](core.md)** — 2 modules
- **[Leader (Commander)](leader.md)** — 16 modules
- **[Squad Modifiers](squad.md)** — 23 modules
- **[Big Boss (High Command)](bigboss.md)** — 4 modules

## Quick placement rules

1. **Every HAL-enabled mission needs exactly one `HAL Core` module per side**
   that should have an AI commander. Sync it to one unit on that side (usually
   a leader). Multiple Core modules (up to 8, letters A–H) create independent
   HQs that run in parallel.

2. **Groups are attached to an HQ via `HAL Leader Include`** synced to both
   the Core module and the group's leader. Without this, HAL doesn't know the
   group exists.

3. **Most other modules are optional** — they tune behavior, add restrictions,
   or define map-specific locations. Place them and sync to the HQ (or the
   specific group they target).

4. **CBA Settings are fallback defaults.** If you don't place a settings
   module (e.g. Leader Personality Settings), HAL reads the corresponding CBA
   setting instead. See `../cba-settings-vs-modules.md`.

## See also

- `../quickstart.md` — minimal working mission setup
- `../personality-guide.md` — what the 6 personality traits actually do
- `../cba-settings-vs-modules.md` — precedence rules and gotchas
- `../examples/` — concrete mission recipes
