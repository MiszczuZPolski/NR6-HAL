---
phase: 05-settings-localization-compat-cleanup
plan: 02
subsystem: extraction
tags: [extraction, compat-04, behav-01, behav-02, boss, hq-command, hqsitrep]
wave: 2
requires:
  - 05-01 (VarInit defaults + TimeM + TaskMenu + Sound/CfgRadio)
  - rename-map.json from Phase 4 (consumed via phase4-rename.py --owner-override)
provides:
  - fnc_boss as the canonical replacement for nr6_hal/Boss.sqf (main AI commander loop, 2021 lines)
  - fnc_front as hal_core function
  - fnc_desperation as hal_hac function
  - 7 HQSitRep[B-H] variants as hal_core functions
  - 11 HQ-level command scripts (flanking, hqOrders, hqOrdersDef, hqOrdersEast, hqReset, lhq, lPos, reloc, rev, sfIdleOrd, spotScan) as hal_hac functions
affects:
  - addons/core/functions/fnc_init.sqf (Boss/Front/HQSitRep dispatch rewired to EFUNC references)
  - addons/hal_hac/functions/fnc_statusQuo.sqf (HAL_* call sites for this plan's targets rewritten to EFUNC)
  - addons/hal_hac/functions/fnc_statusQuo_attackDispatch.sqf (partial)
  - addons/hal_hac/functions/fnc_statusQuo_init.sqf (partial)
  - addons/core/functions/fnc_HQSitRep.sqf (call-through rewrite)
tech-stack:
  added: []
  patterns:
    - "phase4-rename --owner-override pinning (prevents tool from re-inferring owners on freshly extracted files)"
    - "Boss_fnc.sqf dead-loader removal from fnc_init.sqf (file was already deleted in Phase 3)"
key-files:
  created:
    - addons/hal_boss/functions/fnc_boss.sqf
    - addons/core/functions/fnc_front.sqf
    - addons/hal_hac/functions/fnc_desperation.sqf
    - addons/core/functions/fnc_HQSitRepB.sqf
    - addons/core/functions/fnc_HQSitRepC.sqf
    - addons/core/functions/fnc_HQSitRepD.sqf
    - addons/core/functions/fnc_HQSitRepE.sqf
    - addons/core/functions/fnc_HQSitRepF.sqf
    - addons/core/functions/fnc_HQSitRepG.sqf
    - addons/core/functions/fnc_HQSitRepH.sqf
    - addons/hal_hac/functions/fnc_flanking.sqf
    - addons/hal_hac/functions/fnc_hqOrders.sqf
    - addons/hal_hac/functions/fnc_hqOrdersDef.sqf
    - addons/hal_hac/functions/fnc_hqOrdersEast.sqf
    - addons/hal_hac/functions/fnc_hqReset.sqf
    - addons/hal_hac/functions/fnc_lhq.sqf
    - addons/hal_hac/functions/fnc_lPos.sqf
    - addons/hal_hac/functions/fnc_reloc.sqf
    - addons/hal_hac/functions/fnc_rev.sqf
    - addons/hal_hac/functions/fnc_sfIdleOrd.sqf
    - addons/hal_hac/functions/fnc_spotScan.sqf
  modified:
    - addons/core/XEH_PREP.hpp
    - addons/hal_boss/XEH_PREP.hpp
    - addons/hal_hac/XEH_PREP.hpp
    - addons/core/functions/fnc_init.sqf
    - addons/core/functions/fnc_HQSitRep.sqf
    - addons/hal_hac/functions/fnc_statusQuo.sqf
    - addons/hal_hac/functions/fnc_statusQuo_attackDispatch.sqf
    - addons/hal_hac/functions/fnc_statusQuo_init.sqf
decisions:
  - "phase4-rename.py required explicit --owner-override pins to rename-map.json canonical owners; default tool inference flipped owners for freshly-extracted files (first-touch rule biases toward addon containing the new file instead of canonical owner). Discovered on Task 1, carried through Tasks 2 and 3."
  - "RydHQ_Recklessness_Init preserved as bare legacy literal in fnc_desperation.sqf — it has no assignment site (write-never, read-once fallback via getVariable default)."
  - "Boss_fnc.sqf preprocessFile line removed from fnc_init.sqf — file was deleted in Phase 3 (dead loader)."
  - "HQSitRep dispatch (A_HQSitRep..H_HQSitRep) moved from nr6_hal/VarInit.sqf Section C into fnc_init.sqf as EFUNC(core,HQSitRep*) assignments — runtime resolution preserved (getVariable continues to read X_HQSitRep by letter key)."
  - "HAL_GoCapture/GoDef/GoAttInf/etc. bare-global call sites in fnc_statusQuo_* left as-is — they resolve in Plan 05-03."
  - "RydBB_* references in fnc_boss.sqf and fnc_hqReset.sqf NOT rewritten — RydBB_ is absent from rename-map.json (intentionally, it's the BattleZone subsystem's own namespace handled elsewhere). phase4-rename.py correctly skipped the prefix."
metrics:
  duration_minutes: 12
  tasks_completed: 3
  files_created: 21
  files_modified: 8
  completed: 2026-04-12
---

# Phase 5 Plan 02: Extraction Wave 2 (Boss + HQ command) Summary

Extracted the AI commander core — Boss.sqf (2021 lines), Front.sqf, Desperation.sqf, 7 HQSitRep[B-H] dispatch variants, and the 11 HQ-level command scripts (HQOrders/Def/East, HQReset, Flanking, LHQ, LPos, Reloc, Rev, SFIdleOrd, SpotScan) — from nr6_hal/ into addons/hal_boss, addons/core, and addons/hal_hac; fnc_init.sqf now dispatches Boss, Front, and all 8 HQSitRep variants via EFUNC macros, and statusQuo call sites for these targets are rewired.

## Objective Achieved

- Boss.sqf main AI commander loop is a PREP'd function at `EFUNC(hal_boss,boss)` with all rename-map-tracked legacy variables converted.
- Front.sqf front-line detection lives at `EFUNC(core,front)` and is called from fnc_init.sqf instead of `compile preprocessFile`.
- Desperation.sqf lives at `EFUNC(hal_hac,desperation)` with the `RydHQ_Recklessness_Init` write-never literal preserved.
- HQSitRepB..H (7 near-identical variants) are PREP'd in hal_core; dedup deferred to v1.1 per 05-CONTEXT.md.
- 11 HQ command scripts (Flanking, HQOrders, HQOrdersDef, HQOrdersEast, HQReset, LHQ, LPos, Reloc, Rev, SFIdleOrd, SpotScan) are PREP'd in hal_hac.
- fnc_init.sqf Boss/Front/HQSitRep dispatch is fully wired to EFUNC references; the dead `preprocessFile Boss_fnc.sqf` line is gone.
- Existing statusQuo call sites that target this plan's extractions are rewritten to EFUNC (the 05-03 targets HAL_Garrison/HAL_GoSFAttack/HAL_SuppMed/etc. are deliberately left bare for Plans 05-03 and 05-04).

## Commits

| # | Hash      | Subject |
|---|-----------|---------|
| 1 | d8b0322   | feat(05-02): extract Boss.sqf, Front.sqf, Desperation.sqf to addons |
| 2 | d167c13   | feat(05-02): extract 7 HQSitRep[B-H] variants to addons/core |
| 3 | 86b8e25   | feat(05-02): extract 11 HQ command scripts and wire dispatch |

## Verification Results

Independent verifier agent: **APPROVED** at Task 4 checkpoint.

Gates confirmed:
- `hemtt build` exits 0, 9 PBOs built.
- 7 remaining L-S warnings are behavior-preserving patterns inherited verbatim from nr6_hal/ source (L-S24/L-S12/L-S27) — not regressions.
- BBW1 accepted per CLAUDE.md environment notice.
- `grep -c "PREP(boss)" addons/hal_boss/XEH_PREP.hpp` → 1.
- `grep -c "PREP(HQSitRep" addons/core/XEH_PREP.hpp` → 7.
- `grep -c "PREP(hqOrders)" addons/hal_hac/XEH_PREP.hpp` → 1 (+ 10 sibling PREP entries for the other 10 HQ command scripts).
- `grep -n "EFUNC(hal_boss,boss)" addons/core/functions/fnc_init.sqf` → matches (Boss handle wired).
- `grep -n "EFUNC(core,HQSitRepB)" addons/core/functions/fnc_init.sqf` → matches (dispatch populated).
- `grep -n "nr6_hal" addons/core/functions/fnc_init.sqf` → 0 (all legacy loaders removed).
- `test -f addons/hal_boss/functions/fnc_boss.sqf` → PASS (2024 lines).

## Extraction Details

### Task 1 — Boss.sqf + Front.sqf + Desperation.sqf (commit d8b0322)

| Source | Destination | Lines | Owner rename prefix-by-prefix |
|---|---|---|---|
| nr6_hal/Boss.sqf | addons/hal_boss/functions/fnc_boss.sqf | 2021 | RydHQ_, RydxHQ_, RYD_ (pinned to core/hal_boss/hal_hac per canonical map) |
| nr6_hal/Front.sqf | addons/core/functions/fnc_front.sqf | 97 | RydHQ_, RydxHQ_ (pinned core) |
| nr6_hal/Desperation.sqf | addons/hal_hac/functions/fnc_desperation.sqf | 48 | RydHQ_, RydxHQ_ (pinned hal_hac for self-variables, core for non-self) |

- `call RYD_Spawn` occurrences in Front.sqf rewritten to `call EFUNC(common,spawn)`.
- `call Desperado` at fnc_statusQuo.sqf rewritten to `call FUNC(desperation)` (same addon).

### Task 2 — HQSitRep[B-H] (commit d167c13)

7 near-identical ~690-line dispatch variants extracted, one per HQ slot letter. phase4-rename run per-prefix with owner-override pins. Each file got its `#include "..\script_component.hpp"` header and `// Originally from nr6_hal/HAL/HQSitRep{X}.sqf` origin comment. All 7 registered in addons/core/XEH_PREP.hpp.

Dedup is deferred to v1.1 per 05-CONTEXT.md — these scripts will be consolidated into a parameterized function after behavior parity is verified in 05-08.

### Task 3 — HQ command scripts + fnc_init.sqf dispatch wiring (commit 86b8e25)

| Source | Destination | Lines |
|---|---|---|
| nr6_hal/HAL/Flanking.sqf | fnc_flanking.sqf | 183 |
| nr6_hal/HAL/HQOrders.sqf | fnc_hqOrders.sqf | 1187 |
| nr6_hal/HAL/HQOrdersDef.sqf | fnc_hqOrdersDef.sqf | 1038 |
| nr6_hal/HAL/HQOrdersEast.sqf | fnc_hqOrdersEast.sqf | 144 |
| nr6_hal/HAL/HQReset.sqf | fnc_hqReset.sqf | 535 |
| nr6_hal/HAL/LHQ.sqf | fnc_lhq.sqf | 88 |
| nr6_hal/HAL/LPos.sqf | fnc_lPos.sqf | 25 |
| nr6_hal/HAL/Reloc.sqf | fnc_reloc.sqf | 56 |
| nr6_hal/HAL/Rev.sqf | fnc_rev.sqf | 56 |
| nr6_hal/HAL/SFIdleOrd.sqf | fnc_sfIdleOrd.sqf | 66 |
| nr6_hal/HAL/SpotScan.sqf | fnc_spotScan.sqf | 168 |

fnc_init.sqf updates:
- `call Boss` -> `call EFUNC(hal_boss,boss)`.
- `call compile preprocessFile (GVAR(path) + "Front.sqf")` -> `call EFUNC(core,front)`.
- `preprocessFile ... Boss_fnc.sqf` line removed (file deleted in Phase 3).
- HQSitRep dispatch block added before the main loop, populating `A_HQSitRep..H_HQSitRep` with EFUNC references instead of reading them from the now-gone VarInit Section C.

Bare HAL_* call sites rewritten in fnc_statusQuo*.sqf and fnc_HQSitRep.sqf for this plan's targets:
- `HAL_LHQ` -> `EFUNC(hal_hac,lhq)`
- `HAL_Reloc`, `HAL_LPos`, `HAL_Rev`, `HAL_SFIdleOrd` -> `EFUNC(hal_hac,...)`
- `HAL_HQOrders`, `HAL_HQOrdersDef`, `HAL_HQReset` -> `EFUNC(hal_hac,...)`
- `Desperado` -> `EFUNC(hal_hac,desperation)`

05-03 targets (`HAL_GoCapture`, `HAL_GoDef*`, `HAL_GoAttInf`, `HAL_Garrison`, `HAL_GoSFAttack`) left as bare globals per existing statusQuo pattern — they will be rewritten in 05-03.
05-04 targets (`HAL_SuppMed`, `HAL_SuppFuel`, `HAL_SuppRep`, `HAL_SuppAmmo`) left as bare globals.
`HAL_EnemyScan` left as bare global — callee is already PREP'd as `EFUNC(core,enemyScan)` but call site rewrite deferred to 05-03 alongside the other statusQuo cleanup.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] phase4-rename default owner inference wrong for fresh files**
- **Found during:** Task 1 (first post-rename inspection of fnc_boss.sqf)
- **Issue:** phase4-rename.py's default owner inference walks the addons tree and picks "first addon containing this legacy name" — but a freshly copied file with no namespacing yet will be the FIRST (and only) addon file containing many variables. This caused the tool to assign `hal_boss` ownership to variables canonically owned by `core` or `hal_hac`.
- **Fix:** Switched to `--owner-override` pinning the tool against the rename-map.json canonical owner for every rename pass. Re-ran the tool on all three prefixes with pinned owners. This became the standard invocation pattern for Tasks 2 and 3.
- **Files modified:** addons/hal_boss/functions/fnc_boss.sqf, addons/core/functions/fnc_front.sqf, addons/hal_hac/functions/fnc_desperation.sqf
- **Commit:** d8b0322

**2. [Rule 1 - Bug] RydHQ_Recklessness_Init rewritten by tool, had to be restored**
- **Found during:** Task 2 (post Task 2's second-pass rename over already-extracted desperation.sqf)
- **Issue:** Phase4-rename's second pass on Task 2 converted `getVariable ["RydHQ_Recklessness_Init", _default]` in fnc_desperation.sqf to its GVAR form. The variable has NO assignment site anywhere in the codebase — it is a write-never literal that only exists as a getVariable default fallback. Converting it would break the fallback mechanism because the GVAR form would silently become a missing key lookup.
- **Fix:** Restored the bare `"RydHQ_Recklessness_Init"` literal in fnc_desperation.sqf getVariable call.
- **Files modified:** addons/hal_hac/functions/fnc_desperation.sqf
- **Commit:** d167c13

**3. [Rule 3 - Blocking] Boss_fnc.sqf dead preprocessFile loader in fnc_init.sqf**
- **Found during:** Task 3 (inspecting fnc_init.sqf for Boss call-site replacement)
- **Issue:** fnc_init.sqf still had `call compile preprocessFile (GVAR(path) + "Boss_fnc.sqf")` at ~line 147 — but Boss_fnc.sqf was deleted in Phase 3 after its 20 functions were extracted into addons/hal_boss. The loader would have runtime-errored if hit.
- **Fix:** Removed the line. No replacement needed (the 20 functions are already PREP'd).
- **Files modified:** addons/core/functions/fnc_init.sqf
- **Commit:** 86b8e25

**4. [Rule 1 - Bug] phase4-rename converted legacy function handles to GVAR()**
- **Found during:** Task 3 (initial hemtt build failure after running phase4-rename on HQ command scripts)
- **Issue:** HQ command scripts contain references like `call RYD_RandomOrd`, `call RYD_RandomOrdB`, `call RYD_PresentRHQ`, `call HAL_Flanking`, `call HAL_HQOrdersEast`, `call HAL_Spotscan`. These are COMPILED FUNCTION HANDLES, not data variables. phase4-rename has no way to tell the difference and rewrote them to `GVAR(randomOrd)` / `GVAR(presentRHQ)` / `GVAR(flanking)` — which are data-variable references that don't exist.
- **Fix:** Post-pass rewrites:
  - `GVAR(randomOrd)` / `GVAR(randomOrdB)` -> `EFUNC(common,randomOrd)` / `EFUNC(common,randomOrdB)`
  - `GVAR(presentRHQ)` -> `EFUNC(hal_data,presentRHQ)`
  - `GVAR(flanking)` / `GVAR(hqOrdersEast)` / `GVAR(spotScan)` -> `FUNC(flanking)` / `FUNC(hqOrdersEast)` / `FUNC(spotScan)` (same addon)
- **Files modified:** All 11 HQ command script files in addons/hal_hac/functions/
- **Commit:** 86b8e25

**5. [Rule 2 - Missing critical functionality] HAL_* call sites in statusQuo_*.sqf**
- **Found during:** Task 3 (post-rename sweep)
- **Issue:** Several bare HAL_* function handles in fnc_statusQuo.sqf, fnc_statusQuo_attackDispatch.sqf, fnc_statusQuo_init.sqf, and fnc_HQSitRep.sqf reference functions newly extracted in this plan. If left bare, they would be undefined at runtime because only the PREP'd macro names resolve.
- **Fix:** Rewrote HAL_LHQ/HAL_Reloc/HAL_LPos/HAL_Rev/HAL_SFIdleOrd/HAL_HQOrders/HAL_HQOrdersDef/HAL_HQReset/Desperado -> EFUNC(hal_hac, ...). Call sites referencing Plan 05-03 targets (HAL_GoCapture, HAL_Garrison, HAL_GoSFAttack, etc.) and Plan 05-04 targets (HAL_Supp*) deliberately left bare per intermediate-state pattern.
- **Files modified:** addons/hal_hac/functions/fnc_statusQuo.sqf, fnc_statusQuo_attackDispatch.sqf, fnc_statusQuo_init.sqf, addons/core/functions/fnc_HQSitRep.sqf
- **Commit:** 86b8e25

**6. [Rule 2 - Missing critical functionality] RHQ_*/RYD_WS_* refs in HQSitRep files**
- **Found during:** Task 3 (running phase4-rename over hal_hac added RHQ_/RYD_ prefix passes that also re-touched already-committed HQSitRep files)
- **Issue:** The HQSitRep[B-H] files committed in Task 2 had residual RHQ_* and RYD_WS_* references that Task 3's RHQ_/RYD_ pass caught. These needed rewriting to EGVAR(hal_data,...) per the canonical owner map.
- **Fix:** Accepted the Task 3 pass's updates to HQSitRep[B-H] files — they correctly rewrote the residuals to EGVAR(hal_data,...). Net rename is consistent with rename-map.json.
- **Files modified:** addons/core/functions/fnc_HQSitRep[B-H].sqf (8 files updated at ~58 lines diff each)
- **Commit:** 86b8e25

**7. [Rule 3 - Blocking] fnc_HQSitRep.sqf call-through rewrite**
- **Found during:** Task 3 (grep for bare HAL_LHQ outside the 11 new files)
- **Issue:** addons/core/functions/fnc_HQSitRep.sqf (extracted in an earlier phase) still called HAL_LHQ as a bare global. With LHQ now PREP'd, this call site needed upgrading.
- **Fix:** Rewrote to `call EFUNC(hal_hac,lhq)`.
- **Files modified:** addons/core/functions/fnc_HQSitRep.sqf
- **Commit:** 86b8e25

**8. [Rule 3 - Blocking] fnc_init.sqf HQSitRep dispatch reconstruction**
- **Found during:** Task 3 (fnc_init.sqf read during Boss call-site replacement)
- **Issue:** nr6_hal/VarInit.sqf Section C (lines 1130-1196) contained per-HQ conditional `isNil "leaderHQ*"` blocks that populated `A_HQSitRep..H_HQSitRep` with compiled function handles. This block was dropped when VarInit was extracted in 05-01. Without it, the main Boss loop's runtime dispatch via `_HQ getVariable "HQSitRep"` would read nil.
- **Fix:** Added the dispatch population block to fnc_init.sqf before the main server loop, using EFUNC references instead of compile preprocessFile. A_HQSitRep through H_HQSitRep are now set via `if !(isNil "leaderHQX") then { X_HQSitRep = EFUNC(core,HQSitRepX); };` pattern.
- **Files modified:** addons/core/functions/fnc_init.sqf
- **Commit:** 86b8e25

## Auth Gates

None.

## Known Stubs

None introduced by this plan.

## Deferred Issues

- **HAL_EnemyScan call site in fnc_statusQuo.sqf** — bare global. Callee is already PREP'd as `EFUNC(core,enemyScan)`. Rewrite deferred to 05-03 alongside statusQuo HAL_Garrison/HAL_GoSFAttack cleanup (same file sweep).
- **HAL_SuppMed/Fuel/Rep/Ammo in fnc_statusQuo.sqf** — bare globals. Callees extract in Plan 05-04.
- **HAL_Garrison, HAL_GoSFAttack in fnc_statusQuo.sqf/fnc_statusQuo_attackDispatch.sqf** — bare globals. Callees extract in Plan 05-03.
- **HAL_GoCapture, HAL_GoDef*, HAL_GoAttInf, HAL_GoRest, HAL_GoIdle, HAL_GoRecon, HAL_GoFlank, HAL_SCargo** in HQOrders/HQOrdersDef/HQOrdersEast — bare globals. Callees extract in Plan 05-03.
- **RydBB_* references** in fnc_boss.sqf (49 sites) and fnc_hqReset.sqf (4 sites) — NOT rewritten. RydBB_ is absent from rename-map.json — it's the BattleZone subsystem's own namespace, handled by addons/missionmodules via its own bbSettings.sqf path. Pre-existing state, not a regression.

## Threat Register Mitigations Applied

- **T-05-03 (Tampering — Boss.sqf variable rename):** Mitigated. All rename-map-tracked legacy names in fnc_boss.sqf are now GVAR/EGVAR macros. Remaining `RydBB_*`, `RydHQ_Recklessness_Init`, and a single documented comment reference are intentional preserves (see decisions + deviations above).
- **T-05-04 (Denial — HQSitRep dispatch):** Mitigated. A_HQSitRep..H_HQSitRep variables are populated in fnc_init.sqf before the main Boss loop via EFUNC(core,HQSitRep*) references. Verified present via `grep "EFUNC(core,HQSitRepB)" addons/core/functions/fnc_init.sqf`.
- **T-05-05 (Denial — HAL_* undefined calls):** Mitigated for this plan's targets. Every bare HAL_* call site for a Plan 05-02 target has been rewritten. Plan 03/04 targets remain bare (documented in Deferred Issues).

## Verifier Outcome

Independent verifier agent reviewed the checkpoint report after Tasks 1-3 and returned **APPROVED**. Key confirmations:
- owner-override pins matched rename-map.json canonical owners for every prefix pass.
- QEGVAR(core,...) bindings used correctly from hal_hac -> core references (e.g., fnc_hqReset.sqf simpleMode access).
- RydHQ_Recklessness_Init literal correctly preserved in fnc_desperation.sqf.
- Boss_fnc.sqf dead loader removal confirmed as correct (file removed in Phase 3).
- PREP registrations present for all 20 new functions across the 3 addons.
- 7 remaining L-S warnings verified as inherited from nr6_hal/ source patterns, not new regressions.
- hemtt build clean (9 PBOs, BBW1 accepted).

## Self-Check

- addons/hal_boss/functions/fnc_boss.sqf -> FOUND (2024 lines)
- addons/core/functions/fnc_front.sqf -> FOUND
- addons/hal_hac/functions/fnc_desperation.sqf -> FOUND
- addons/core/functions/fnc_HQSitRepB.sqf..fnc_HQSitRepH.sqf -> FOUND (7 files)
- addons/hal_hac/functions/fnc_flanking.sqf -> FOUND
- addons/hal_hac/functions/fnc_hqOrders.sqf -> FOUND
- addons/hal_hac/functions/fnc_hqOrdersDef.sqf -> FOUND
- addons/hal_hac/functions/fnc_hqOrdersEast.sqf -> FOUND
- addons/hal_hac/functions/fnc_hqReset.sqf -> FOUND
- addons/hal_hac/functions/fnc_lhq.sqf -> FOUND
- addons/hal_hac/functions/fnc_lPos.sqf -> FOUND
- addons/hal_hac/functions/fnc_reloc.sqf -> FOUND
- addons/hal_hac/functions/fnc_rev.sqf -> FOUND
- addons/hal_hac/functions/fnc_sfIdleOrd.sqf -> FOUND
- addons/hal_hac/functions/fnc_spotScan.sqf -> FOUND
- commit d8b0322 -> FOUND in git log
- commit d167c13 -> FOUND in git log
- commit 86b8e25 -> FOUND in git log

## Self-Check: PASSED
