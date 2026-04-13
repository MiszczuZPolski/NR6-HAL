# NR6-HAL Documentation

Documentation for **NR6-HAL v1.0** — an Arma 3 AI commander mod that runs
autonomous AI side commanders ("HQs") capable of coordinating infantry,
vehicles, artillery, recon, and support assets.

## Start here

- **[Quickstart](quickstart.md)** — minimum viable HAL mission in 5 minutes
- **[Personality Guide](personality-guide.md)** — what the 6 personality
  trait sliders actually do (derived from the tactical code)
- **[CBA Settings vs Editor Modules](cba-settings-vs-modules.md)** — how
  mission-design-time and runtime configuration interact

## Module reference

All 45 HAL editor modules, grouped by category:

- **[Core Modules](modules/core.md)** (2) — Core, General Settings
- **[Leader Modules](modules/leader.md)** (16) — Leader HQs, settings,
  personality, support, objectives, decoys
- **[Squad Modifiers](modules/squad.md)** (23) — per-group restrictions
  and role modifiers
- **[Big Boss (High Command)](modules/bigboss.md)** (4) — experimental
  high-command layer above individual HQs

Module metadata is auto-generated from `addons/missionmodules/CfgVehicles.hpp`
and the English stringtable. See `.tmp/gen_module_docs.py` if you need to
regenerate after CfgVehicles changes.

## Example missions

Hand-written, concrete walkthroughs:

- **[Basic 2-Side Battle](examples/basic-battle.md)** — one BLUFOR HQ vs
  one CSAT HQ, 5-minute setup, beginner
- **[Three-HQ Combined Arms](examples/three-hq-with-arty.md)** —
  coordinated assault/recon/fire-support HQs, intermediate
- **[Player as HAL Commander](examples/player-commander.md)** — you play
  the commander role, HAL dispatches support on request, intermediate

## In-game configuration

HAL supports three configuration surfaces:

1. **Eden editor modules** (mission-design time) — place modules with
   attributes, sync to HQs or groups. Most fine-grained control.
2. **CBA Settings menu** (runtime) — `Esc → Options → Addon Options → HAL`.
   Server-wide defaults; overridden by editor modules when present.
3. **Debug console** (runtime debugging) — set GVARs directly:
   ```sqf
   private _hq = hal_core_allHQ select 0;
   _hq setVariable [QEGVAR(core,recklessness), 0.9];
   ```

## Architecture overview

HAL is composed of 7 addon PBOs:

| Addon | Purpose |
|---|---|
| `hal_main` | Shared macros, version info, script includes |
| `hal_core` | HQ initialization, personality, threat scanning, SitRep |
| `hal_common` | ~70 utility functions (pathfinding, wait loops, artillery math) |
| `hal_hac` | Tactical behavior scripts (GoAttInf, GoCapture, HQOrders, etc.) |
| `hal_boss` | Big Boss high-command logic + force analysis |
| `hal_data` | Weapon/vehicle classification tables + radio chatter assets |
| `hal_tasking` | 72 player action callbacks (request CAS, transport, etc.) |
| `hal_missionmodules` | 45 editor modules with CfgVehicles definitions |
| `hal_compat_nr6hal` | Backward compat: old classnames, function aliases, global vars |

Plus `hal_sites`, `hal_sitemarkers`, `hal_alice2`, `hal_airreinforcements`,
`hal_reinforcements`, `hal_tools` which are independent sub-systems not
refactored in v1.0.

## Testing

Smoke test harness lives in `tests/`:

- `tests/test_BEHAV_*.sqf` — 5 in-game smoke tests (run via debug console)
- `tests/harness/` — automated setup + run-all harness
- `tests/harness/mission.VR/` — minimal VR map test mission that auto-runs
  the harness 30 seconds after spawn

See `tests/harness/HARNESS.md` for setup and usage.

## Project history

v1.0 is the result of a 5-phase refactor:

1. **Phase 1** — Addon skeleton + HEMTT build foundation
2. **Phase 2** — Dependency mapping of legacy `nr6_hal/` files
3. **Phase 3** — Function extraction (111+ functions from legacy files)
4. **Phase 4** — Variable namespacing (517 variables renamed to CBA macros)
5. **Phase 5** — Settings, localization, compat addon, full legacy removal

Full planning archive lives in `.planning/phases/`.

## Credits

- **Rydygier** — original Hetman's Artificial Leader
- **NinjaRider6000** — NR6-HAL maintenance and continued development
- **Rockdood** — original documentation
- **Radek5311 / Radekj1** — sqfc binarization work
- **v1.0 refactor** — ACE3-standard restructure, full CBA integration, lint
  cleanup, documentation

## License and source

See the repository root `README.md` for license and contribution info.
Source code lives in `addons/` (structured per ACE3 convention). Build with
HEMTT via `hemtt build`.
