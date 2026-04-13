# Example: Player as HAL Commander

**Time to build:** 10 minutes
**Complexity:** Intermediate
**What you'll see:** You play the role of the BLUFOR commander. Your AI
subordinates receive orders from you (via the HAL action menu), not from
a script-driven HAL HQ. HAL still provides the dispatch layer, fire
support coordination, and enemy tracking.

## Concept

HAL has a "player squad leader" mode where the human acts as the HQ
commander and HAL's action menus are attached to the player. You issue
commands via a menu ("Request Air Support", "Request Ammo Drop", "Request
Transport") and HAL dispatches AI squads to respond.

This is the hybrid mode — HAL makes fire-support and transport decisions,
but strategic choices (where to go, what to attack) are yours.

## Eden placement

### Player as BLUFOR leader

1. **BLUFOR → Men → Squad Leader** → place as the player
2. **Add subordinate AI units to the player's group** (F2, drag from the
   unit palette into your group, or place a pre-made squad and merge)
3. Your player unit is now the leader of a BLUFOR rifle squad

### HAL Core — player configuration

1. **HAL Core** module → sync to the player
   - Default attributes

2. **HAL General Settings** module → sync to Core
   - **Squad Leader Actions = True** (enables the HAL action menu on the player)
   - **Actions Menu = True** (uses a nested menu instead of flat actions)
   - **Only Use ACE Actions = False** (unless you're running ACE3; True uses
     ACE self-interaction wheel instead of addAction)
   - **Disable Withdraw For Players Squad Leader = True** (recommended —
     prevents HAL from force-retreating the player's group)
   - **Disable Cargo Players Squad Leaders = True** (prevents auto-lifts
     when the player should decide)

### HAL Leader Include + support groups

1. **HAL Leader Include** → sync to Core

2. **Support assets** that HAL can dispatch to you on request:
   - **2 helicopters** (Huron CH-67, Ghost Hawk) — place empty, sync to
     Include. HAL uses them for transport and medevac requests.
   - **2 ammo trucks** (Tempest Ammo or HEMTT Ammo) — same, crewed
   - **1 medical truck** (Tempest Medical)
   - **1 repair truck** (Tempest Repair)
   - **1 fuel truck** (Tempest Fuel)
   - **1 mortar team** (crew + Mk6) — fire support
   - **1 armored vehicle** (Slammer or Merkava) — CAS substitute

   Sync all leader/drivers to Include.

   These are **not your direct subordinates**. They're HAL-managed assets
   that respond to your support requests.

3. **HAL Leader Support Settings** → sync to Core
   - Enable all support types
   - Artillery Shells = 30 (ammo budget for mortar)
   - Support WP = True (HAL auto-pathfinds support vehicles)

### Enemy forces

1. **Second HAL Core** → sync to a CSAT unit (standard AI-driven enemy HQ)
2. **HAL Leader Include** → sync to this Core
3. **4 CSAT squads** → sync to OPFOR Include
4. **1 CSAT vehicle** of your choice → same

## What to watch for

Preview the mission.

**After ~15 seconds**, you should see new **action menu entries** when
pressing scroll wheel (vanilla) or ACE self-interact (F-key by default if
ACE3):

- **Request Air Support (CAS)** — HAL dispatches the armored vehicle / any
  CAS-capable asset
- **Request Transport (Air)** — the first available helicopter flies to
  your position, lands, waits for you to board
- **Request Transport (Ground)** — nearest drivable vehicle
- **Request Ammo Resupply** — ammo truck drives to you
- **Request Medical Support** — medical truck drives to you
- **Request Fuel** — fuel truck drives to you
- **Request Repairs** — repair truck drives to you
- **Request Airlift** — helicopter transport (vs ground)
- **Request CAS** — armed air asset, if available
- **Request Armored Support** — AFV dispatches to your location
- **Request Infantry Support** — additional rifle squad comes under temporary
  command
- **Request Artillery Fire Mission** — you designate a position, mortar fires
- **Request Ground Transport** — truck-based lift

### The action menu itself

If **Actions Menu = True**, all these requests nest under a single top-level
action **"HAL Command"** or similar (the exact name may vary). Scroll wheel
→ HAL Command → select the request.

If **Actions Menu = False**, each request is a flat top-level scroll-wheel
action (more cluttered but one fewer click).

If **Only Use ACE Actions = True**, the requests appear in the ACE self-
interaction wheel under an "HAL" branch.

### What HAL does behind the scenes

When you request (say) ammo resupply:
1. HAL finds the closest free ammo truck synced to the Include module
2. Dispatches it with waypoints to your current position
3. The truck drives to you (real pathfinding, not teleport)
4. When it arrives, the ammo crates are reachable from its cargo
5. If you walk away or die mid-request, HAL marks the truck available again

For artillery:
1. You request fire support, HAL opens a target-picking interface
2. Place a marker where you want rounds
3. HAL checks ammo, dispatches the fire mission
4. Mortar fires using the normal HAL artillery logic
5. Observation reports back after impact

## Tuning

**"The action menu is cluttered — I only want CAS and artillery":**
- Use **Tasking Actions = False** and **Support Actions = False** to disable
  the deprecated flat menus
- Use **Actions Menu = True** to nest everything

**"I want ACE3 self-interaction instead of scroll wheel":**
- **Only Use ACE Actions = True** in General Settings
- The actions now appear in the ACE wheel (F by default)

**"The helicopters are taking forever":**
- Reduce **Disembark Range** in General Settings (HAL won't try to land
  right on top of you — it picks a safe LZ; lower range = closer LZ)
- Consider **HAL Leader Support Settings → Support WP = False** (HAL
  delegates pathfinding to the engine instead of overriding)

## Limitations

- The player is only ONE squad's commander. HAL can't give you control of
  multiple squads simultaneously (it's a single action menu).
- You can't save custom fire mission presets — each request is ad hoc.
- The CSAT AI HAL on the other side doesn't know you're a human player; it
  treats your group like any other enemy squad.
- HAL's state is server-authoritative — in multiplayer, only the host has
  true HAL state. Clients see the effects but can't directly inspect HAL
  variables.

## Common pitfalls

**"No action menu appears":**
- Is **Squad Leader Actions = True** in General Settings?
- Are you actually the squad **leader** (not just a member)? HAL only
  attaches to leaders.
- Is there at least one Core module synced to the player side?

**"Actions appear but nothing happens when I click":**
- Check that the support assets are synced to the Include module
- Check that they're crewed (empty vehicles don't self-drive)
- Check that they have fuel/damage/ammo in working ranges
- Check HAL debug output via `systemChat` after enabling Debug

**"HAL withdrew my squad":**
- Set **Disable Withdraw For Players Squad Leader = True** in General
  Settings (it's the default, but worth double-checking)

## Next steps

- [`basic-battle.md`](basic-battle.md) — simpler 2-sides-autonomous example
- [`three-hq-with-arty.md`](three-hq-with-arty.md) — complex multi-HQ battles
- [`../modules/README.md`](../modules/README.md) — full module reference
