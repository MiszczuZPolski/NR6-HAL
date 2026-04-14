# Example: Three-HQ Battle with Combined Arms

**Time to build:** 15–20 minutes
**Complexity:** Intermediate
**What you'll see:** Three independent BLUFOR HQs (A, B, C) with different
roles, coordinated fire support, and OPFOR counter-attacks.

This is where HAL gets interesting. Each HQ runs its own AI commander with
its own personality, can be restricted in different ways, and together they
produce combined-arms behavior that looks almost hand-scripted.

## Concept

| HQ | Role | Composition | Personality |
|---|---|---|---|
| **Alpha** | Main assault | 4 infantry squads, 2 APCs | Eager, Recklessness 0.7 |
| **Bravo** | Recon/flanking | 2 recon teams, 1 light vehicle | Schemer, Fineness 0.9 |
| **Charlie** | Fire support | 2 mortar teams + 1 howitzer | Hesitant, Activity 0.3 |
| **OPFOR** | Defender | 5 squads + 1 tank + 1 mortar | Competent |

All BLUFOR HQs share the same side but run independent command cycles —
they don't directly communicate with each other in-engine, but their groups
won't interfere with each other because Leader Include scopes groups per HQ.

## Eden placement

### Player slot
- BLUFOR rifleman at a safe overwatch position (hill, tower). Mark as Player.

### HQ Alpha — main assault

1. **HAL Core** module (let's call it Core_A)
   - Sync to the player. Alpha becomes the "main" HQ.
   - Attributes: Startup Delay = 15 (default)

2. **HAL Leader Personality Settings** → sync to Core_A
   - Manual Personality = True
   - Recklessness = 0.7
   - Consistency = 0.5
   - Activity = 0.7
   - Reflex = 0.6
   - Circumspection = 0.3
   - Fineness = 0.4

3. **HAL Leader Behaviour Settings** → sync to Core_A
   - Withdraw threshold = higher (e.g. 1.5) — Alpha pushes hard
   - Smoke = True (HAL uses smoke cover)

4. **HAL Leader Include** (Include_A) → sync to Core_A

5. **4 BLUFOR rifle squads** → sync each leader to Include_A
6. **2 BLUFOR APCs** (IFV-6C Panther or M2A1 Slammer) → sync to Include_A
   - HAL will use them for infantry transport and cargo recon

### HQ Bravo — recon/flanking

1. **Second HAL Core** module (Core_B)
   - Sync to **a different BLUFOR unit** — create a dummy BLUFOR soldier
     near your HQ area, hide them (`this hideObjectGlobal true` in init)
     and sync Core_B to them

   > Why a dummy? Each HAL Core needs a unique side-anchor unit. The player
   > is already used by Core_A. Dummies are just bookkeeping — they don't
   > need to exist visibly.

2. **HAL Leader Personality Settings** → sync to Core_B
   - Select Personality = Schemer (preset)
   - This gives high fineness + circumspection automatically

3. **HAL Leader Include** (Include_B) → sync to Core_B

4. **2 BLUFOR Recon teams** → sync to Include_B
5. **1 BLUFOR Prowler / Hunter** (light vehicle) → sync to Include_B

6. **HAL Squad NoAttack** *(one module per recon team)*
   - Why: recon teams should spot, not engage. NoAttack tells HAL to avoid
     sending them into combat unless directly threatened.
   - Sync each NoAttack module to its respective recon team

### HQ Charlie — fire support

1. **Third HAL Core** module (Core_C)
   - Sync to another dummy BLUFOR unit

2. **HAL Leader Personality Settings** → sync to Core_C
   - Select Personality = Hesitant
   - Activity = 0.3 (manual override: these groups shouldn't patrol)

3. **HAL Leader Support Settings** → sync to Core_C
   - Artillery Shells = 50 (or more, per piece)
   - This governs how much ammo HAL considers available for fire missions

4. **HAL Leader Include** (Include_C) → sync to Core_C

5. **2 Mortar teams** (Mk6 Mortar crews) → sync to Include_C
6. **1 Howitzer** (M4 Scorcher or similar) → sync to Include_C

7. **HAL Squad NoDef** *(per artillery crew)*
   - Prevents HAL from assigning defensive positions to artillery crews
     (they'd leave their guns)

8. **HAL Squad Garrison** *(per artillery crew)*
   - Tells HAL to keep them at their firing position instead of maneuvering

### OPFOR side — the defender

1. **Fourth HAL Core** (Core_OPFOR)
   - Sync to a CSAT unit
   - Personality preset = Competent

2. **HAL Leader Include** → sync to Core_OPFOR

3. **5 CSAT infantry squads** spread along a defensive line 800–1500 m from
   BLUFOR positions
   - Sync all to Include_OPFOR

4. **1 CSAT tank** (T-100 Varsuk or similar) → sync to Include_OPFOR

5. **1 CSAT mortar team** → sync to Include_OPFOR

6. **HAL Leader Objective** module
   - Sync to Core_OPFOR
   - This tells OPFOR HAL "defend this area" instead of "go attack BLUFOR"
   - Place the module in the center of the OPFOR position

## What to watch for

Preview in multiplayer. First minute is HAL initialization and group sorting.

**HQ Alpha behavior:**
- Infantry mount the APCs for transport
- Alpha moves the whole formation toward OPFOR, faster than the other HQs
- First contact → immediate engagement, reckless push into enemy fire

**HQ Bravo behavior:**
- Recon teams split off and take wide routes around the OPFOR flank
- They *observe* OPFOR positions instead of engaging
- Their spot reports feed into the shared enemy-knowledge pool that all
  three BLUFOR HQs read (see `_HQ getVariable [QEGVAR(core,knEnemies), []]`
  in the code — it's shared per side via `publicVariable`)
- Result: Alpha has better situational awareness because Bravo is spotting

**HQ Charlie behavior:**
- Mortars and howitzer stay in place
- When Alpha engages, Charlie's HAL receives fire mission requests via the
  shared state and starts lobbing shells on spotted positions
- Charlie's groups never move (Garrison module locks them)

**OPFOR behavior:**
- Defender holds the Objective position
- Counter-attacks BLUFOR probes but doesn't leave the defensive perimeter
- Tank engages APCs at range
- Mortar fires on concentrated BLUFOR groups

## Observing with debug

Enable **HAL Leader Settings → Debug = True** on all four HQs. On the map
you'll see:

- **4 front-line ellipses** — one per HQ, showing where each thinks the
  front is
- **Colored movement arrows** per group
- **"markFlank1..4"** for Bravo's flanking routes
- **Artillery target markers** for Charlie's fire missions

## Customization ideas

- **Give HQ Charlie more reflex** (0.9) — fire missions will respond faster
  to Alpha's contacts
- **Lower Bravo's circumspection** to 0.2 — recon teams will push closer to
  OPFOR before reporting, higher risk / higher intel value
- **Add a HAL Withdraw Decoy** sync'd to Alpha — if Alpha withdraws, it
  leaves a decoy group behind to distract OPFOR
- **Replace the OPFOR Objective with a Leader Front** module — OPFOR becomes
  aggressive and pushes instead of defending

## Common pitfalls

**"Charlie's artillery never fires":**
- Is the artillery piece crewed? HAL needs the gunner to be the group leader
- Is the artillery type in HAL's `RYD_WS_Arty` weapon class list? Check
  `addons/hal_data/functions/fnc_initWeaponClasses.sqf` — if the ammo type
  isn't registered, HAL won't dispatch fire missions
- Is there an active enemy contact? Artillery fires on *known* enemies, not
  speculative targets. Wait for Alpha to make contact.

**"Bravo's recon teams are getting wiped:**
- That's what NoAttack doesn't prevent — it just tells HAL not to send them
  INTO combat. If OPFOR finds them, they fight. Add a Squad_AlwaysUnKnownU
  module to keep them below OPFOR's radar until discovered.

**"All three HQs are fighting over the same groups":**
- Each group can only be in ONE Include module. If you accidentally sync
  a group to multiple Include modules, whichever HQ wins the initialization
  race gets it. Double-check your sync graph.

## Next steps

- [`player-commander.md`](player-commander.md) — you become the commander,
  HAL runs your subordinates
- [`../modules/squad.md`](../modules/squad.md) — browse all 23 squad
  modifier modules
- [`../personality-guide.md`](../personality-guide.md) — fine-tune the 6
  personality traits
