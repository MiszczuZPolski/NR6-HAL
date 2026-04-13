# HAL Quickstart — Your First HAL Mission in 5 Minutes

This is the **absolute minimum** to get an AI commander running. If you follow
these steps literally, you'll have one BLUFOR HQ commanding three AI squads
against an enemy side, with HAL making all the tactical decisions.

## Prerequisites

- Arma 3 (2.14+)
- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997) enabled
- NR6-HAL enabled
- Any map (VR is fastest for testing)

## Step-by-step

### 1. Open Eden editor

New mission → pick a map → empty world.

### 2. Place a player unit

**Units → NATO → Men → Rifleman** → click somewhere on the map. Double-click
and check **"Player"** in the unit attributes so this is your slot.

*This unit won't be commanding anything — you just need something to spawn into.*

### 3. Place the HAL Core module

**Systems → Modules → HAL - Modules → HAL Core** → click to place.

Double-click the module and leave everything default. `Startup Delay = 15` is fine.

**Sync it to the player** (hold **F5**, click the module, drag to the player, release).

> The Core module creates an AI commander (the "HQ") that tracks whichever side
> the synced unit belongs to. One Core module per side you want HAL to run.

### 4. Place a HAL Leader Include module

**Systems → Modules → HAL - Modules → HAL Leader Include** → click to place.

Sync it to the **HAL Core module** (F5 + drag).

This module's job: "attach synced groups to this HQ as subordinates." Without
it, HAL sees no groups.

### 5. Place some friendly AI groups

**Units → NATO → Men → Squad** (or Infantry Team) → click to place 3 squads.
Not too far from the player — 100–300 m apart is fine.

Each squad must be synced to the **HAL Leader Include module** (F5 + drag the
group leader, or drag the entire group).

### 6. Place enemy groups

**Units → CSAT → Men → Squad** → 2 enemy squads, 500–1000 m away from your
forces. **Do NOT sync them to any HAL module** — they're targets, not your
subordinates.

### 7. (Optional) Place an artillery piece

**Units → NATO → Artillery → Mk6 Mortar** or howitzer → place it, sync its
group leader to the Leader Include module. HAL will recognize it as a fire
support asset.

### 8. Preview the mission

**Scenario → Play (Ctrl+Enter)** or **Preview in Multiplayer** (recommended for
real HAL behavior — HAL mostly does nothing noticeable in SP preview for the
first few seconds).

Wait 15–30 seconds. You'll see:
- Sidechat messages from "Command" with radio chatter
- Your AI squads moving into formation
- HAL assigning group waypoints toward enemies
- If you placed the mortar, it'll eventually fire on spotted threats

## That's it

This is enough for HAL to do its job. Everything below this line is
customization — tuning personality, restricting what HAL can do with specific
groups, placing map-specific objectives, setting up multi-HQ battles.

## Next steps

- **Tune personality:** place **HAL Leader Personality Settings** → see
  [`personality-guide.md`](personality-guide.md)
- **Restrict a group** (e.g. "this group never attacks"): place **HAL Squad
  NoAttack** synced to that group
- **Multi-HQ battle:** place more Core modules, each synced to a different side
  leader — see [`examples/three-hq-with-arty.md`](examples/three-hq-with-arty.md)
- **Full module list:** [`modules/README.md`](modules/README.md)

## Troubleshooting

**"HAL doesn't do anything":**
- Did you wait at least 15 seconds? (Startup Delay)
- Is the HAL Core module synced to a unit on the same side as the groups you
  want commanded?
- Is the HAL Leader Include module synced to BOTH the Core module AND the
  group leaders?
- Are you previewing in multiplayer? Some HAL logic is server-only and
  singleplayer preview may not trigger the full cycle.

**"HAL is doing weird things":**
- That's probably the personality system. Default personality is `COMPETENT`
  which has sensible behavior. Try `IDEAL` or `EAGER` for more aggressive play.
  See [`personality-guide.md`](personality-guide.md).

**"I want to see what HAL is doing":**
- Place a **HAL Leader Settings** module → double-click → enable **Debug**.
  Markers will appear showing HAL's decisions (enemy positions, waypoints,
  front lines, capture targets).
