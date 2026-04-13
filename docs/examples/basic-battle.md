# Example: Basic 2-Side Battle

**Time to build:** 5 minutes
**Complexity:** Beginner
**What you'll see:** BLUFOR HAL commander engaging CSAT forces autonomously

This is the simplest non-trivial HAL mission. One BLUFOR HQ with three
infantry squads, one mortar team, facing three CSAT squads with their own
HAL commander. Both sides run independently.

## Eden editor placement

Open Eden on a small map (Stratis "Camp Maxwell" area works well, or any VR
square).

### Player slot

- **BLUFOR → Men → Rifleman** → place somewhere safe (a hill, a base). Mark
  as **Player** in attributes. This is just your observation post.

### BLUFOR side (you'll command via HAL)

1. **HAL Core** (Systems → Modules → HAL - Modules)
   - Sync to the player
   - Leave all attributes default
2. **HAL Leader Include**
   - Sync to the HAL Core module
3. **3 BLUFOR infantry squads** (Men → Squad)
   - Place 100–300 m apart, roughly in a forward line
   - Sync each group leader to the **HAL Leader Include** module
4. **1 Mortar team** (Men → Mortar 82mm or Mk6 Mortar)
   - Place 400 m behind your infantry line
   - Sync the gunner to **HAL Leader Include**
   - This becomes HAL's fire support asset
5. **HAL Leader Personality Settings** *(optional)*
   - Sync to HAL Core
   - Set **Manual Personality = True**, **Select Personality = Competent**
   - Or try **Eager** for more aggressive play

### OPFOR side (enemy HAL)

1. **Second HAL Core** module
   - Sync to **any CSAT unit** (place a dummy CSAT leader if needed)
   - Leave defaults
2. **Second HAL Leader Include**
   - Sync to the second HAL Core
3. **3 CSAT infantry squads**
   - Place 600–1200 m from your BLUFOR line (far enough that each side has
     "maneuvering room")
   - Sync each leader to the second HAL Leader Include

### Triggers (optional — makes the battle trigger instead of starting on mission load)

- **Trigger** (Systems → Triggers → None)
  - Condition: `time > 30`
  - Activation: Anybody, Present, Once
  - On Activation: `hint "HAL engaged — battle commencing."`

## What to watch for

Launch via **Scenario → Play in Multiplayer** (server-side logic runs fully
in MP preview; SP preview is flakier for HAL).

**First 30 seconds:**
- Both HAL Core modules initialize
- "Command" sidechat messages from both sides (BLUFOR in blue, OPFOR in red)
- Squad leaders receive movement orders

**30–90 seconds:**
- Squads start moving toward each other
- HAL performs recon (one squad moves ahead of the others)
- First contact causes a flurry of radio messages ("enemy contact, grid...")

**90+ seconds:**
- Engagements begin
- Mortar fires when HAL designates an artillery target
- HAL redistributes groups — some withdraw if damaged, some reinforce the flank
- One side eventually wins as groups take casualties

**If nothing happens after 2 minutes:**
- Check that both Core modules are synced to units on their respective sides
- Confirm the Include modules are synced to BOTH the Core AND the squad leaders
- Enable Debug mode (via **HAL Leader Settings → Debug = True**) to see HAL's
  internal state as map markers

## Debug markers reference

When Debug is enabled, you'll see these markers on the map mid-mission:
- **Small colored circles** — known enemy positions HAL is tracking
- **Named waypoints** — groups under orders (squad ID + order type)
- **Ellipse "Front"** — where HAL thinks the front line is
- **"MARK_ES"** — enemies currently being scanned

## Tuning exercises

Try these variations to see HAL's behavior change:

1. **"Defensive BLUFOR":** set BLUFOR personality to `Hesitant`, OPFOR to
   `Eager`. Watch your HAL hold positions while OPFOR pushes.

2. **"Symmetric aggressive":** set both sides to `Aggressive`. The fight
   becomes a frontal clash with minimal flanking.

3. **"Asymmetric fineness":** set BLUFOR fineness to `1.0`, OPFOR fineness
   to `0.0`. BLUFOR will send flanking elements while OPFOR does frontal
   attacks only — you'll watch the flank maneuver form up.

4. **"Add artillery to OPFOR":** place a CSAT mortar team synced to the
   OPFOR Include. Suddenly you're on the receiving end of fire missions.

## Common mistakes

- **Syncing enemies to your HAL Include** — HAL will try to command them.
  Don't do this.
- **Placing Core on the wrong side** — the HAL Core module follows the side
  of whichever unit it's synced to. If you sync a BLUFOR Core to a CSAT
  unit, you get a BLUFOR HQ commanding OPFOR-side groups (confused behavior).
- **Forgetting the Include module** — the Core module alone doesn't track
  groups. You need Leader Include for HAL to know what exists.

## Next steps

- **Multi-HQ scenario:** [`three-hq-with-arty.md`](three-hq-with-arty.md) —
  three BLUFOR HQs coordinating
- **Player commander:** [`player-commander.md`](player-commander.md) — you
  play the role of BLUFOR commander, HAL runs your subordinates
- **Squad restrictions:** [`../modules/squad.md`](../modules/squad.md) — use
  Squad_NoAttack, Squad_NoDef, etc. to define specific group roles
