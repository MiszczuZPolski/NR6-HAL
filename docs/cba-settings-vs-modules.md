# CBA Settings vs Editor Modules

HAL exposes the same configuration surface **twice**: through ~45 editor
modules placed in Eden, and through ~101 CBA settings exposed in the runtime
addon options menu. This page explains how they interact and when to use
which.

## TL;DR

**Editor modules win.** CBA settings are **fallback defaults** that HAL reads
when no editor module has set the corresponding value. If you place a
`HAL Leader Personality Settings` module in Eden, its values override the
CBA setting for that HQ at mission start.

## The precedence rule

For any given setting (say, *Recklessness*):

```
1. Is there a HAL Leader Personality Settings module placed and synced
   to this HQ?
       YES → use the module's value
       NO  → fall through to step 2

2. Is there a CBA setting value configured?
       YES → use the CBA setting
       NO  → fall through to step 3

3. Use the hard-coded default (usually 0.5 for trait sliders).
```

This is implemented in `addons/missionmodules/functions/fnc_leader*Settings.sqf`
via the pattern:

```sqf
missionNamespace setVariable [
    QGVAR(recklessness) + _letter,
    _logic getVariable [QGVAR(recklessness), GVAR(recklessness)]
];
```

Breakdown:
- `_logic getVariable [QGVAR(recklessness), ...]` — read the module's attribute
- If the attribute is unset (editor didn't supply a value), fall back to
  `GVAR(recklessness)` which is the current CBA setting value

## When to use which

### Use **editor modules** when:
- You're building a **specific mission** with deliberate HAL tuning
- You want different HQs to have **different personalities** (module per HQ)
- You want to **restrict a specific group** (place a Squad_NoAttack etc.
  synced to just that group)
- You want to **place map-specific objectives** (Leader Objective modules)
- You want the mission to be **self-contained** and reproducible across
  different people's CBA configs

### Use **CBA settings** when:
- You're configuring a **server-wide policy** for HAL across all missions
- You want to override a mission designer's choices at runtime
- You're **testing different personality values** mid-session without
  re-editing the mission
- You run a community server and want consistent HAL behavior regardless
  of which mission is loaded

## How to open the CBA settings menu

1. Start or join a mission with NR6-HAL + CBA_A3 loaded
2. Press **Escape** to pause
3. Click **Options**
4. Click **Addon Options** (added by CBA_A3)
5. Top dropdown → select **HAL** (or a HAL sub-category)
6. Scroll the list, adjust sliders and checkboxes
7. Changes persist to your user profile

## Setting scopes

CBA settings have three possible scopes, which affect how they sync in
multiplayer:

| Scope | Meaning | Used in HAL for |
|---|---|---|
| **Client** | Per-player, no sync | None (HAL is server-side) |
| **Server** | Server decides, clients read | Most HAL settings |
| **Mission** | Server default, overridable per-mission by server admin | Some tuning knobs |

Check the **lock icon** next to each setting in the CBA menu to see whether
it's server-controlled or client-local.

## Gotcha: per-HQ overrides

CBA settings are **singletons** — one value per setting, globally. HAL
supports up to **8 independent HQs** (letters A–H), each with its own
personality.

If you want HQ A to be aggressive and HQ B to be defensive, **you cannot do
this via CBA settings alone**. You must:

1. Place a `HAL Leader Personality Settings` module for HQ A with
   aggressive values
2. Place a second `HAL Leader Personality Settings` module for HQ B with
   defensive values
3. Sync each module to its respective HAL Core

The CBA settings would still apply as defaults for any trait not explicitly
set in the module attributes.

## Gotcha: boolean-ness of module attributes

Some module attributes are `BOOL` with a default of `"True"` or `"False"`.
If the editor serializes these as strings, the fallback read

```sqf
_logic getVariable [QGVAR(smoke), GVAR(smoke)]
```

may return `"True"` (the string) instead of `true` (the boolean). HAL's
comparison code uses `== true` which coerces strings correctly in SQF, so
this is usually safe — but if you're writing custom HAL extensions, always
compare with `isEqualTo true` or cast explicitly.

## Migration note for old missions

Missions built against the **pre-refactor NR6-HAL** placed modules with
classnames like `NR6_HAL_Leader_Module`. The compat addon
(`addons/compat_nr6hal`) maps these old classnames to the new
`hal_missionmodules_Leader_Module` classes via CfgVehicles inheritance, so
old missions load.

**However**, the CBA settings are new in v1.0 — old missions have no CBA
settings to migrate. They simply use whatever CBA settings are configured on
the server, as defaults for any attributes the old modules don't specify.

## Which settings are exposed via CBA?

All ~101 of them. See `addons/core/initSettings.inc.sqf` for the complete
list of `CBA_fnc_addSetting` calls. Categories match the editor module
categories:

- **General** — cargo/recon options, chat density, action menus
- **Leader** — chat debug, info markers, artillery marks, subordinate modes
- **Behaviour** — smoke/flares/garrison/withdraw/flee thresholds, distance tuning
- **Personality** — the 6 trait sliders
- **Support** — cargo find range, support type allowances, artillery shell defaults
- **Objectives** — capture limits, defensive objectives, reserve sizing

## See also

- [`personality-guide.md`](personality-guide.md) — the 6 personality traits explained
- [`modules/README.md`](modules/README.md) — full editor module reference
- [`quickstart.md`](quickstart.md) — minimum viable HAL mission
- Source: `addons/core/initSettings.inc.sqf`,
  `addons/missionmodules/functions/fnc_leader*Settings.sqf`
