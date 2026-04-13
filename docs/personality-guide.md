# HAL Personality Guide

HAL models its AI commander using **6 personality traits**, each a number
from `0.0` to `1.0`. These traits feed directly into HAL's decision formulas
in `addons/hal_hac/functions/*.sqf` — they're not cosmetic.

This guide explains **what each trait actually does to runtime behavior**,
derived by reading the tactical code. No gameplay-feel opinions — just the
mechanical effects.

## Where to set personality

**Option 1 — Editor module (recommended for per-mission):**
Place a **HAL Leader Personality Settings** module, sync it to the HAL Core
module. Double-click to configure.

You can pick a **preset** via the *Select Personality* dropdown (9 presets,
default is `COMPETENT`), or set **Manual Personality = True** to override
each trait individually with sliders.

**Option 2 — CBA Settings menu (server-wide defaults):**
`Esc → Options → Addon Options → HAL` → personality sliders. These apply to
any HQ that doesn't have a Leader Personality Settings module placed.

**Option 3 — Runtime debug console:**
```sqf
private _hq = hal_core_allHQ select 0;
_hq setVariable [QEGVAR(core,recklessness), 0.9];
```

## The 6 traits

### Recklessness (`hal_core_recklessness`, default `0.5`)

**"How much damage will HAL accept before pulling back, and how greedily does
it push into enemy-held territory?"**

Used in 10+ decision sites. Key formulas:

- **Withdraw threshold** (`fnc_hqOrders.sqf:110`):
  ```
  withdraw if  (group_damage / (current_strength + 0.1)) > 0.4 * ((recklessness / 1.2) + 1)
  ```
  - `0.0`: withdraws at ~33% effective damage
  - `0.5`: withdraws at ~56% (default)
  - `1.0`: withdraws at ~73%

- **Safe distance for idle** (`fnc_goIdle.sqf:67`):
  ```
  safedist = 100 / (0.75 + recklessness / 2)
  ```
  - `0.0`: 133 m buffer from enemies when idle
  - `0.5`: 100 m (default)
  - `1.0`: 80 m

- **Recon skip chance** (`fnc_hqOrders.sqf:357`): higher recklessness = more
  likely to skip recon and attack directly.

- **Objective capture limit** (`fnc_hqOrders.sqf:767`): paired with
  `circumspection`. Higher recklessness + low circumspection = accepts more
  enemies near an objective while still pushing for capture.

**In practice:**
- `0.0–0.3` — conservative, retreats quickly, recons everything
- `0.4–0.6` — default balanced play
- `0.7–1.0` — aggressive, stays in fights past reasonable damage thresholds

### Consistency (`hal_core_consistency`, default `0.5`)

**"How much does HAL stick to a plan once committed?"**

Used with `recklessness` to calculate enemy tolerance near a capture
objective (`fnc_goCapture.sqf:940`):
```
enemies_tolerated = (recklessness / (0.5 + consistency)) * 10
```

Higher consistency **lowers** the enemies-tolerated threshold, meaning the
capture is aborted sooner when enemies show up. So `consistency` acts like a
"caution amplifier" in capture scenarios.

Also affects the **personality drift loop** in `fnc_lhq.sqf`: every decision
cycle, `consistency` drifts down by `random 0.2`, which means a high starting
consistency gradually decays as HQ leadership changes hands. A HIGH starting
consistency means HAL will stay more committed to early plans; a LOW starting
consistency means HAL re-evaluates aggressively.

**In practice:**
- `0.0` — HAL constantly changes its mind, responds hard to tactical shifts
- `0.5` — default, mixed commitment
- `1.0` — sticks to the first plan even when the situation has changed

### Activity (`hal_core_activity`, default `0.5`)

**"How often does HAL initiate proactive patrols and movements?"**

Used in idle-group decisions (`fnc_goIdle.sqf:148`):
```
patrol = true if random(100) > (20/0.5 + activity)
       OR random(100) > (80/0.5 + activity)
```

The inverse relationship means **higher activity increases patrol frequency
exponentially**. At `activity = 0.0`, groups rarely patrol while idle. At
`activity = 1.0`, idle groups are almost always patrolling.

**In practice:**
- `0.0–0.3` — groups hold positions when nothing is happening
- `0.5` — default, occasional patrols
- `0.7–1.0` — constant movement, hard to ambush but wears out faster

### Reflex (`hal_core_reflex`, default `0.5`)

**"How fast does HAL tick? How quickly does it react to new information?"**

Used in the main HQ cycle delay (`fnc_statusQuo.sqf:68`):
```
tick_delay = (friend_count * 5) + round((10 + friend_count) / (0.5 + reflex)) * commDelay
```

This is HAL's **decision loop period**. Lower reflex = longer delay between
decision cycles. Higher reflex = shorter delay. At `reflex = 0.0`, HAL
effectively "thinks" at half speed; at `reflex = 1.0`, it thinks at ~1.5×
base speed.

Crucially, this affects **how quickly HAL notices new enemy contacts and
reassigns groups**. A low-reflex HAL will still be holding old plans when the
tactical situation has already changed.

**In practice:**
- `0.0–0.3` — "old and slow general", moves reinforcements too late
- `0.5` — default
- `0.7–1.0` — reactive, snaps to new threats quickly. Expensive on large
  battles (`commDelay` multiplier can make this costly if you have many HQs)

### Circumspection (`hal_core_circumspection`, default `0.5`)

**"How carefully does HAL evaluate before committing to an objective?"**

Used in capture-limit calculations (`fnc_hqOrders.sqf:767`):
```
captLimit = captLimitBase * (1 + circumspection / (2 + recklessness))
```

Higher circumspection **raises the capture limit threshold** — meaning HAL
demands more friendly strength concentration before committing to a capture.
Paired inversely with recklessness.

Also used in the **goIdle road-finding check** (`fnc_goIdle.sqf:165`): higher
circumspection → more cautious road reconnaissance, less idle loitering near
roads.

**In practice:**
- `0.0–0.3` — reckless capture pushes with minimal force
- `0.5` — default
- `0.7–1.0` — careful concentration before each capture, slower pacing

### Fineness (`hal_core_fineness`, default `0.5`)

**"Flanking and tactical subtlety"**

Used in the **flanking-maneuver eligibility check**
(`fnc_hqOrders.sqf:256`):
```
flank_chance = random(100) > (30 / (0.5 + fineness))
```

Higher fineness **dramatically increases the chance** that a reserve group
gets tasked with a flanking maneuver instead of a straight assault. At
`fineness = 0.0`, flanking almost never triggers; at `fineness = 1.0`, it's
common.

Also used in goIdle idle-patrol decisions via a similar inverse formula
(`fnc_goIdle.sqf:165`).

**In practice:**
- `0.0–0.3` — frontal assaults only, predictable tactics
- `0.5` — default, occasional flanks
- `0.7–1.0` — flanking is common, HAL plays "smart" tactically

## Presets (the 9 dropdown choices)

Set via **Select Personality** when Manual = False. Exact values are defined
in the HAL personality code (`fnc_personality.sqf` in `addons/core/functions/`)
and applied to the 6 traits at mission start.

| Preset | Typical profile |
|---|---|
| **Ideal** | High fineness, high reflex, moderate recklessness — optimal decision-making |
| **Competent** *(default)* | All traits around 0.5 — balanced, sensible play |
| **Eager** | High recklessness + high activity — aggressive pushing |
| **Hesitant (Dilatory)** | Low recklessness + low reflex — slow, defensive, reactive |
| **Chaotic** | Randomized traits every decision cycle — unpredictable |
| **Worst (Idiot)** | Poor values on most traits — exists for comedy / difficulty tuning |
| **Schemer** | High fineness + high circumspection — methodical flanking |
| **Aggressive (Brute)** | High recklessness + low circumspection — reckless frontal assaults |
| **Randomized** | Random starting values (different each mission) |

For exact numeric profiles, read `addons/core/functions/fnc_personality.sqf`
(not documented here because they may change between versions).

## Personality drift

HAL simulates "leadership fatigue" via the `fnc_lhq.sqf` loop. Every time
the HQ leader changes (e.g. old leader KIA, new unit takes command), the 6
traits drift by `random 0.2` in varying directions, bounded to `[0.0, 1.0]`.

Also, 60–180 seconds after each drift event, morale is decremented by 10–20
points to simulate transition cost.

**Gotcha:** Prior to the v1.0 refactor cleanup, this loop had a pre-existing
scope bug — the trait reads were returning nil because the loop is invoked
via `spawn` (not `call`), so caller scope wasn't inherited. **This was fixed**
during the lint cleanup pass. If you notice behavior feels different from an
old install, this is why: trait drift now actually works.

## Recommended starting values by play style

| Goal | Recklessness | Consistency | Activity | Reflex | Circumspection | Fineness |
|---|---|---|---|---|---|---|
| **Hard mode (HAL aggressive)** | 0.8 | 0.7 | 0.7 | 0.7 | 0.3 | 0.8 |
| **Balanced** *(default)* | 0.5 | 0.5 | 0.5 | 0.5 | 0.5 | 0.5 |
| **Easy mode (HAL cautious)** | 0.3 | 0.4 | 0.3 | 0.4 | 0.7 | 0.4 |
| **Defensive specialist** | 0.3 | 0.6 | 0.4 | 0.6 | 0.8 | 0.6 |
| **Blitzkrieg** | 0.9 | 0.5 | 0.8 | 0.8 | 0.2 | 0.5 |
| **Tactical finesse** | 0.5 | 0.5 | 0.5 | 0.7 | 0.6 | 0.9 |

These are derived from the mechanical formulas above. They are not play-tested
recommendations — they're starting points that produce the *intended* behavior
pattern given how the formulas work.

## See also

- [`modules/leader.md`](modules/leader.md) — `HAL Leader Personality Settings` module reference
- [`cba-settings-vs-modules.md`](cba-settings-vs-modules.md) — precedence rules
- Source: `addons/hal_hac/functions/fnc_hqOrders.sqf`, `fnc_goIdle.sqf`,
  `fnc_goCapture.sqf`, `fnc_statusQuo.sqf`
