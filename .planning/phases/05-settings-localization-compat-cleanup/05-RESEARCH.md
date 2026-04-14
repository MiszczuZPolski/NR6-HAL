# Phase 5: Settings, Localization, Compat & Cleanup - Research

**Researched:** 2026-04-11
**Domain:** Arma 3 addon migration (file extraction, CBA settings, stringtable, compat aliasing, behavior verification)
**Confidence:** HIGH

## Summary

Phase 5 is the final and largest phase. It has six sequential blocks: (1) extract ~60 remaining nr6_hal/ files into addons/, (2) dead-var audit + strip, (3) CBA settings integration, (4) stringtable creation, (5) full compatibility addon, (6) behavior verification tests. The critical path is Block 1: the extraction of 49 HAL/*.sqf behavior scripts + Boss.sqf + VarInit.sqf + Front.sqf + SquadTaskingNR6.sqf + supporting files. Everything else depends on all code living in addons/.

The key technical discovery is that VarInit.sqf (1211 lines) serves a dual role: (a) it initializes ~1000 runtime variables with default values, and (b) it compiles and assigns 41 HAL/*.sqf + Boss.sqf + Desperado function handles. These HAL_ function handles (e.g. `HAL_GoAttInf`, `HAL_EnemyScan`, `HAL_HQOrders`) are referenced as bare globals from already-migrated addons/ code. After Phase 3 removed the VarInit.sqf loader, these handles are currently undefined -- Phase 5 extraction will restore them via CBA PREP registration, then update all 40+ call sites to use EFUNC() macros.

**Primary recommendation:** Extract VarInit.sqf variable assignments first (they populate CBA settings defaults), then extract HAL/*.sqf as PREP'd functions, then update all call sites from bare `HAL_*` globals to `EFUNC()` macros, then handle Boss.sqf/Front.sqf/SquadTaskingNR6.sqf, then proceed to settings/compat/cleanup.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Extract ALL remaining nr6_hal/ files to addons/. Full COMPAT-04. Delete nr6_hal/ entirely.
- **D-02:** CBA settings as defaults, editor modules override at mission start.
- **D-03:** Full compat -- classnames + function vars + global aliases (all three layers).
- **D-04:** Scripted SQF smoke tests for behavior verification (run in Arma 3 debug console).
- **D-05:** Stringtable covers settings UI + module descriptions. English only.
- **D-06:** Dead-var strip after extraction, before compat aliasing.

### Deferred Ideas (OUT OF SCOPE)
- Radio chatter localization (v1.1)
- Multi-HQ SitRep deduplication / parameterization (v1.1)
- STD-01/STD-02 compliance on extracted HAL/*.sqf files (post-v1.0)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SET-01 | CBA settings framework via CBA_fnc_addSetting | Section: CBA Settings Candidates (Block 2) |
| SET-02 | All configurable options exposed as CBA settings | Section: CBA Settings Candidates -- 56 settings enumerated |
| SET-03 | stringtable.xml with English localization | Section: Stringtable (Block 3) -- ~130 string entries |
| SET-04 | Settings use LSTRING() macro | Section: LSTRING Macro Availability |
| COMPAT-01 | Old module classnames mapped via CfgVehicles | Section: Old Module Classnames (Block 4) -- 9 classnames mapped |
| COMPAT-02 | Legacy function variable aliases | Section: Function Variable Aliases -- 44 HAL_* handles + Boss + Desperado |
| COMPAT-03 | Existing missions load with compat addon | Section: Compat Integration |
| COMPAT-04 | nr6_hal/ directory removed | Section: File Inventory (Block 1) |
| BEHAV-01 | AI HQ commander initializes identically | Section: Observable States (Block 6) |
| BEHAV-02 | Group management produces identical behavior | Section: Observable States (Block 6) |
| BEHAV-03 | Enemy scanning functions identically | Section: Observable States (Block 6) |
| BEHAV-04 | Artillery/fire support identical | Section: Observable States (Block 6) |
| BEHAV-05 | AI chatter works identically | Section: Observable States (Block 6) |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

- No behavior changes -- AI logic must produce identical results
- HEMTT zero-warnings build gate (BBW1 accepted)
- `undefined = true` active -- any missed function reference = compile error
- Backward compatibility via compat addon
- ACE3 coding standard for file structure/naming/macros
- CBA 3.16.0+ dependency

---

## Block 1: nr6_hal/ File Extraction Inventory (D-01)

### Complete File Inventory

#### Top-level scripts (6 files, 3922 lines)

| File | Lines | Load mechanism | Loader location | Destination addon | Already migrated? |
|------|-------|---------------|-----------------|-------------------|-------------------|
| `Boss.sqf` | 2021 | `compile preprocessFile` via VarInit.sqf:1085, stored as `Boss` global | fnc_init.sqf:167 calls `Boss` | `hal_boss/functions/fnc_boss.sqf` | NO -- imperative main loop, not yet extracted |
| `VarInit.sqf` | 1211 | Was `preprocessFile` from fnc_init.sqf (removed Phase 3) | Nowhere currently (BROKEN) | Split: variable defaults to `core/functions/fnc_varInit.sqf`, function handle assignments DELETED (replaced by CBA PREP) | NO |
| `Front.sqf` | 97 | `call compile preprocessFile` | fnc_init.sqf:138 | `core/functions/fnc_front.sqf` | NO |
| `SquadTaskingNR6.sqf` | 508 | `execVM` | fnc_init.sqf:205 | `hal_tasking/functions/fnc_squadTasking.sqf` | NO |
| `Desperation.sqf` | 48 | `compile preprocessFile` via VarInit.sqf:1086, stored as `Desperado` global | Called from fnc_statusQuo.sqf:189 | `hal_hac/functions/fnc_desperation.sqf` | NO |
| `TaskMenu.sqf` | 37 | Was `preprocessFile` from fnc_init.sqf (removed Phase 3) | Nowhere currently | `hal_tasking/functions/fnc_taskMenu.sqf` | NO |

[VERIFIED: codebase grep of fnc_init.sqf, VarInit.sqf]

#### HAL/*.sqf behavior scripts (49 files, 20802 lines)

All loaded via `compile preprocessFile` in VarInit.sqf lines 1088-1128, stored as `HAL_*` global function handles. Called from addons/ code as `[args] call HAL_*` or `[args] spawn HAL_*`.

| File | Lines | Handle variable | Call sites in addons/ | Destination | Already in addons/? |
|------|-------|----------------|----------------------|-------------|---------------------|
| EnemyScan.sqf | 170 | `HAL_EnemyScan` | fnc_statusQuo.sqf:195 | hal_hac | YES -- `fnc_enemyScan.sqf` in core (198 lines) |
| Flanking.sqf | 183 | `HAL_Flanking` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| Garrison.sqf | 284 | `HAL_Garrison` | fnc_statusQuo.sqf:201 | hal_hac | NO |
| GoAmmoSupp.sqf | 604 | `HAL_GoAmmoSupp` | fnc_action8ct/9ct | hal_hac | NO |
| GoAttAir.sqf | 330 | `HAL_GoAttAir` | fnc_goLaunch.sqf | hal_hac | NO |
| GoAttAirCAP.sqf | 152 | `HAL_GoAttAirCAP` | fnc_goLaunch.sqf | hal_hac | NO |
| GoAttArmor.sqf | 235 | `HAL_GoAttArmor` | fnc_goLaunch.sqf | hal_hac | NO |
| GoAttInf.sqf | 791 | `HAL_GoAttInf` | fnc_goLaunch.sqf | hal_hac | NO |
| GoAttNaval.sqf | 190 | `HAL_GoAttNaval` | fnc_goLaunch.sqf | hal_hac | NO |
| GoAttSniper.sqf | 376 | `HAL_GoAttSniper` | fnc_goLaunch.sqf | hal_hac | NO |
| GoCapture.sqf | 1002 | `HAL_GoCapture` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| GoCaptureNaval.sqf | 304 | `HAL_GoCaptureNaval` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| GoDef.sqf | 262 | `HAL_GoDef` | (called from HQOrdersDef in nr6_hal/) | hal_hac | NO |
| GoDefAir.sqf | 198 | `HAL_GoDefAir` | (called from HQOrdersDef in nr6_hal/) | hal_hac | NO |
| GoDefNav.sqf | 160 | `HAL_GoDefNav` | (called from HQOrdersDef in nr6_hal/) | hal_hac | NO |
| GoDefRecon.sqf | 264 | `HAL_GoDefRecon` | (called from HQOrdersDef in nr6_hal/) | hal_hac | NO |
| GoDefRes.sqf | 271 | `HAL_GoDefRes` | (called from HQOrdersDef in nr6_hal/) | hal_hac | NO |
| GoFlank.sqf | 586 | `HAL_GoFlank` | (called from Flanking in nr6_hal/) | hal_hac | NO |
| GoFuelSupp.sqf | 234 | `HAL_GoFuelSupp` | fnc_action10ct | hal_hac | NO |
| GoIdle.sqf | 293 | `HAL_GoIdle` | (called from SFIdleOrd in nr6_hal/) | hal_hac | NO |
| GoMedSupp.sqf | 223 | `HAL_GoMedSupp` | fnc_action11ct/12ct | hal_hac | NO |
| GoRecon.sqf | 920 | `HAL_GoRecon` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| GoRepSupp.sqf | 225 | `HAL_GoRepSupp` | fnc_action13ct | hal_hac | NO |
| GoRest.sqf | 715 | `HAL_GoRest` | (called from GoAttAir/GoAttAirCAP in nr6_hal/) | hal_hac | NO |
| GoSFAttack.sqf | 842 | `HAL_GoSFAttack` | fnc_statusQuo_attackDispatch.sqf:140 | hal_hac | NO |
| HQOrders.sqf | 1187 | `HAL_HQOrders` | fnc_statusQuo_attackDispatch.sqf:44 | hal_hac | NO |
| HQOrdersDef.sqf | 1038 | `HAL_HQOrdersDef` | fnc_statusQuo_attackDispatch.sqf:56 | hal_hac | NO |
| HQOrdersEast.sqf | 144 | `HAL_HQOrdersEast` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| HQReset.sqf | 535 | `HAL_HQReset` | fnc_statusQuo_init.sqf:31,47 | hal_hac | NO |
| HQSitRep.sqf | 688 | `A_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | YES -- `fnc_HQSitRep.sqf` in core (687 lines) |
| HQSitRepB.sqf | 688 | `B_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepC.sqf | 687 | `C_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepD.sqf | 687 | `D_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepE.sqf | 688 | `E_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepF.sqf | 688 | `F_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepG.sqf | 688 | `G_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| HQSitRepH.sqf | 687 | `H_HQSitRep` | fnc_init.sqf:183 (dynamic dispatch) | core | NO (deferred dedup) |
| LHQ.sqf | 88 | `HAL_LHQ` | fnc_HQSitRep.sqf:36 | core | NO |
| LPos.sqf | 25 | `HAL_LPos` | fnc_statusQuo.sqf:183 | hal_hac | NO |
| Personality.sqf | 131 | `HAL_Personality` | (not directly -- core has its own fnc_personality.sqf) | core | YES -- `fnc_personality.sqf` in core (111 lines) |
| Reloc.sqf | 56 | `HAL_Reloc` | fnc_statusQuo.sqf:177 | hal_hac | NO |
| Rev.sqf | 56 | `HAL_Rev` | fnc_statusQuo.sqf:116 | hal_hac | NO |
| SCargo.sqf | 843 | `HAL_SCargo` | fnc_action7ct, fnc_actionGTct | hal_hac | NO |
| SFIdleOrd.sqf | 66 | `HAL_SFIdleOrd` | fnc_statusQuo.sqf:170 | hal_hac | NO |
| SpotScan.sqf | 168 | `HAL_Spotscan` | (called from HQOrders in nr6_hal/) | hal_hac | NO |
| SuppAmmo.sqf | 318 | `HAL_SuppAmmo` | fnc_statusQuo.sqf:156 | hal_hac | NO |
| SuppFuel.sqf | 271 | `HAL_SuppFuel` | fnc_statusQuo.sqf:135 | hal_hac | NO |
| SuppMed.sqf | 299 | `HAL_SuppMed` | fnc_statusQuo.sqf:126 | hal_hac | NO |
| SuppRep.sqf | 262 | `HAL_SuppRep` | fnc_statusQuo.sqf:144 | hal_hac | NO |

[VERIFIED: codebase grep + VarInit.sqf lines 1088-1128]

#### Already-migrated equivalents (3 files)

These HAL/*.sqf files have counterparts already in addons/ from Phase 3:
1. `EnemyScan.sqf` -> `addons/core/functions/fnc_enemyScan.sqf` (PREP'd as `hal_core_fnc_enemyScan`)
2. `HQSitRep.sqf` -> `addons/core/functions/fnc_HQSitRep.sqf` (PREP'd as `hal_core_fnc_HQSitRep`)
3. `Personality.sqf` -> `addons/core/functions/fnc_personality.sqf` (PREP'd as `hal_core_fnc_personality`)

For these, the nr6_hal/HAL/ copy can be DELETED (redundant). The bare `HAL_EnemyScan` / `HAL_Personality` globals in addons/ call sites must be rewritten to `EFUNC(core,enemyScan)` / `EFUNC(core,personality)`. [VERIFIED: XEH_PREP.hpp + file comparison]

#### Support files (LF, TimeM, Sound, config.cpp)

| Path | Type | Lines/Count | Destination |
|------|------|-------------|-------------|
| `LF/LF.sqf` | SQF | 10 | `common/functions/fnc_LF_toggle.sqf` or DELETE (already `PREP(LF)` in common) |
| `TimeM/DisOP.sqf` | SQF | 3 | `common/functions/fnc_timeDisOP.sqf` |
| `TimeM/EnOP.sqf` | SQF | 3 | `common/functions/fnc_timeEnOP.sqf` |
| `TimeM/TimeFaster.sqf` | SQF | 5 | `common/functions/fnc_timeFaster.sqf` |
| `TimeM/TimeSlower.sqf` | SQF | 5 | `common/functions/fnc_timeSlower.sqf` |
| `Sound/` | Audio assets | 4 .ogg files + 3 Voice dirs (~300 .ogg files) | `hal_data/Sound/` |
| `config.cpp` | Config | 4450 lines | CfgRadio section -> `hal_data/CfgRadio.hpp` |

[VERIFIED: directory listing + file inspection]

### VarInit.sqf Analysis

VarInit.sqf (1211 lines) has two distinct sections:

**Section A: Variable default assignments (lines 1-1084)**
- Lines 1-30: Artillery arrays (RydHQ_Howitzer, RydHQ_Mortar, RydHQ_Rocket, etc.)
- Lines 31-48: Smoke/flare muzzle arrays
- Lines 50-161: Misc defaults (RydART_Amount, etc.) + RHQLibrary.sqf loader
- Lines 162-1084: RHQ weapon class array definitions (already migrated to `fnc_initWeaponClasses.sqf` in hal_data during Phase 3)

Most of Section A is REDUNDANT with Phase 3/4 work. The weapon class arrays (lines 162-1084) are already in `fnc_initWeaponClasses.sqf`. The artillery/smoke/flare arrays (lines 1-48) need verification -- they may be the only remaining unique content.

**Section B: Function handle compilation (lines 1085-1128)**
- `Boss = compile preprocessFile (RYD_Path + "Boss.sqf")` (line 1085)
- `Desperado = compile preprocessFile (RYD_Path + "Desperation.sqf")` (line 1086)
- 41 `HAL_* = compile preprocessFile (RYD_Path + "HAL\*.sqf")` assignments (lines 1088-1128)

**Section C: HQSitRep conditional compilation (lines 1130-1201)**
- `A_HQSitRep = compile preprocessFile (RYD_Path + "HAL\HQSitRep.sqf")` (unconditional, line 1130)
- `B_HQSitRep` through `H_HQSitRep` each conditional on `isNil "leaderHQ*"` (lines 1140-1196)
- Also sets `RydHQ*_Obj1..4` defaults per HQ

**Section D: Leader null fallbacks (lines 1203-1211)**
- Sets `leaderHQ` through `leaderHQH` to `objNull` if nil

After extraction, Section A's unique content moves to a new init function, Section B is DELETED (CBA PREP replaces it), Section C's dynamic dispatch logic must be preserved in fnc_init.sqf, and Section D stays in fnc_init.sqf.

[VERIFIED: direct file read of VarInit.sqf lines 1080-1211]

### Boss.sqf Loading and the HAL_ Function Handle Dispatch

**Current state:**
1. VarInit.sqf was the master loader -- it compiled ALL HAL/*.sqf files into `HAL_*` global function handles
2. Phase 3 removed the VarInit.sqf loader from fnc_init.sqf (line 97 comment)
3. BUT addons/ code still calls `HAL_*` handles (40+ call sites across hal_hac, hal_tasking, common, core)
4. These handles are currently UNDEFINED -- the code is broken in this intermediate state
5. Boss.sqf is also stored as the `Boss` handle (VarInit.sqf:1085) and called from fnc_init.sqf:167

**Phase 5 resolution:**
- Extract each HAL/*.sqf as a PREP'd function in the appropriate addon (mostly hal_hac)
- Replace all `call HAL_*` / `spawn HAL_*` call sites with `call EFUNC(hal_hac,*)` / `spawn EFUNC(hal_hac,*)`
- For the 3 already-migrated files (EnemyScan, Personality, HQSitRep), update call sites to EFUNC(core,*)
- The `Boss` handle: extract Boss.sqf to `hal_boss/functions/fnc_boss.sqf`, PREP it, update fnc_init.sqf:167
- The `Desperado` handle: extract to `hal_hac/functions/fnc_desperation.sqf`, PREP it

**HQSitRep dynamic dispatch concern:**
fnc_init.sqf:183 does: `missionNamespace getVariable (_codeSign + "_HQSitRep")` to resolve A_HQSitRep through H_HQSitRep. After extraction:
- Option A (recommended): Keep the dynamic dispatch pattern but populate the variables in fnc_init.sqf with PREP'd function references:
  ```sqf
  A_HQSitRep = EFUNC(core,HQSitRep);
  B_HQSitRep = EFUNC(core,HQSitRepB);
  // etc.
  ```
- The 7 HQSitRep[B-H].sqf files are extracted as-is (dedup deferred to v1.1)

[VERIFIED: fnc_init.sqf lines 167, 183; VarInit.sqf lines 1085-1128]

### Sound Asset Migration

The `nr6_hal/Sound/` directory contains:
- 4 static .ogg files (Static1ss-4ss.ogg, empty01s.ogg)
- 3 voice subdirectories (Voice1/, Voice2/, Voice3/) with ~100 .ogg files each

The `nr6_hal/config.cpp` CfgRadio section (lines 268-4450) references them as `\NR6_HAL\Sound\Voice1\*.ogg` etc. There are 351 CfgRadio class entries.

**Migration plan:**
1. Move `Sound/` directory to `addons/hal_data/Sound/`
2. Move CfgRadio section to `addons/hal_data/CfgRadio.hpp` and include it from hal_data's config.cpp
3. Update all sound paths from `\NR6_HAL\Sound\` to `\z\hal\addons\hal_data\Sound\` (HEMTT PBO path)
4. The `\z\hal\addons\hal_data\` prefix matches the $PBOPREFIX$ for hal_data

[VERIFIED: nr6_hal/config.cpp CfgRadio inspection, Sound directory listing]

---

## Block 2: CBA Settings Candidates (D-02)

### Settings Enumeration from CfgVehicles.hpp

All module arguments currently defined in `addons/missionmodules/CfgVehicles.hpp` that should become CBA settings:

#### General Settings (GenSettings_Module) -- 24 settings

| # | Argument class | CBA Setting Name | Type | Default | Category |
|---|---------------|-----------------|------|---------|----------|
| 1 | `EGVAR(core,reconCargo)` | `hal_core_reconCargo` | CHECKBOX | true | HAL General |
| 2 | `EGVAR(core,synchroAttack)` | `hal_core_synchroAttack` | CHECKBOX | false | HAL General |
| 3 | `EGVAR(core,hQChat)` | `hal_core_hQChat` | CHECKBOX | true | HAL General |
| 4 | `EGVAR(core,aIChatDensity)` | `hal_core_aIChatDensity` | SLIDER (0-100) | 100 | HAL General |
| 5 | `EGVAR(core,aIChat_Type)` | `hal_core_aIChat_Type` | LIST | "NONE" | HAL General |
| 6 | `EGVAR(core,infoMarkersID)` | `hal_core_infoMarkersID` | CHECKBOX | true | HAL General |
| 7 | `EGVAR(core,actions)` | `hal_core_actions` | CHECKBOX | true | HAL General |
| 8 | `EGVAR(core,actionsMenu)` | `hal_core_actionsMenu` | CHECKBOX | true | HAL General |
| 9 | `EGVAR(core,taskActions)` | `hal_core_taskActions` | CHECKBOX | false | HAL General |
| 10 | `EGVAR(core,supportActions)` | `hal_core_supportActions` | CHECKBOX | false | HAL General |
| 11 | `EGVAR(core,actionsAceOnly)` | `hal_core_actionsAceOnly` | CHECKBOX | false | HAL General |
| 12 | `EGVAR(core,noRestPlayers)` | `hal_core_noRestPlayers` | CHECKBOX | true | HAL General |
| 13 | `EGVAR(core,noCargoPlayers)` | `hal_core_noCargoPlayers` | CHECKBOX | true | HAL General |
| 14 | `EGVAR(core,disembarkRange)` | `hal_core_disembarkRange` | SLIDER | 200 | HAL General |
| 15 | `EGVAR(core,cargoObjRange)` | `hal_core_cargoObjRange` | SLIDER | 1500 | HAL General |
| 16 | `EGVAR(core,lZ)` | `hal_core_lZ` | CHECKBOX | true | HAL General |
| 17 | `EGVAR(core,garrisonV2)` | `hal_core_garrisonV2` | CHECKBOX | true | HAL General |
| 18 | `EGVAR(core,nEAware)` | `hal_core_nEAware` | SLIDER | 500 | HAL General |
| 19 | `EGVAR(core,slingDrop)` | `hal_core_slingDrop` | CHECKBOX | false | HAL General |
| 20 | `EGVAR(core,rHQAutoFill)` | `hal_core_rHQAutoFill` | CHECKBOX | true | HAL General |
| 21 | `EGVAR(core,pathFinding)` | `hal_core_pathFinding` | SLIDER (0-10) | 0 | HAL General |
| 22 | `EGVAR(core,magicHeal)` | `hal_core_magicHeal` | CHECKBOX | false | HAL General |
| 23 | `EGVAR(core,magicRepair)` | `hal_core_magicRepair` | CHECKBOX | false | HAL General |
| 24 | `EGVAR(core,magicRearm)` | `hal_core_magicRearm` | CHECKBOX | false | HAL General |
| 25 | `EGVAR(core,magicRefuel)` | `hal_core_magicRefuel` | CHECKBOX | false | HAL General |
| 26 | `RydART_Safe` | `hal_core_artySafe` | SLIDER | 250 | HAL General |

Note: `RydHQx_PlayerCargoCheckLoopTime` and `EGVAR(core,wS_ArtyMarks)` also appear in fnc_init.sqf but are minor.

#### Commander Settings (Leader_Settings_Module) -- 14 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `EGVAR(core,fast)` | CHECKBOX | false | HAL Commander |
| 2 | `EGVAR(core,commDelay)` | SLIDER | 1 | HAL Commander |
| 3 | `EGVAR(common,chatDebug)` | CHECKBOX | false | HAL Commander |
| 4 | `EGVAR(core,exInfo)` | CHECKBOX | true | HAL Commander |
| 5 | `EGVAR(core,resetTime)` | SLIDER | 150 | HAL Commander |
| 6 | `EGVAR(core,resetOnDemand)` | CHECKBOX | false | HAL Commander |
| 7 | `EGVAR(core,subAll)` | CHECKBOX | false | HAL Commander |
| 8 | `EGVAR(core,subSynchro)` | CHECKBOX | false | HAL Commander |
| 9 | `EGVAR(core,knowTL)` | CHECKBOX | false | HAL Commander |
| 10 | `EGVAR(core,getHQInside)` | CHECKBOX | false | HAL Commander |
| 11 | `EGVAR(hal_hac,camV)` | CHECKBOX | false | HAL Commander |
| 12 | `EGVAR(core,infoMarkers)` | CHECKBOX | false | HAL Commander |
| 13 | `EGVAR(core,artyMarks)` | CHECKBOX | false | HAL Commander |
| 14 | `EGVAR(core,secTasks)` | CHECKBOX | false | HAL Commander |
| 15 | `EGVAR(common,debug)` | CHECKBOX | false | HAL Commander |

#### Behaviour Settings (Leader_BehSettings_Module) -- 22 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `EGVAR(core,smoke)` | CHECKBOX | true | HAL Behaviour |
| 2 | `EGVAR(core,flare)` | CHECKBOX | true | HAL Behaviour |
| 3 | `EGVAR(core,garrVehAb)` | CHECKBOX | true | HAL Behaviour |
| 4 | `EGVAR(core,idleOrd)` | CHECKBOX | true | HAL Behaviour |
| 5 | `EGVAR(core,idleDef)` | CHECKBOX | true | HAL Behaviour |
| 6 | `EGVAR(core,flee)` | CHECKBOX | true | HAL Behaviour |
| 7 | `EGVAR(core,surr)` | CHECKBOX | true | HAL Behaviour |
| 8 | `EGVAR(core,muu)` | SLIDER | 1 | HAL Behaviour |
| 9 | `EGVAR(core,rush)` | CHECKBOX | false | HAL Behaviour |
| 10 | `EGVAR(core,withdraw)` | SLIDER | 1 | HAL Behaviour |
| 11 | `EGVAR(core,airDist)` | SLIDER | 4000 | HAL Behaviour |
| 12 | `EGVAR(core,dynForm)` | CHECKBOX | true | HAL Behaviour |
| 13 | `EGVAR(core,defRange)` | SLIDER | 1 | HAL Behaviour |
| 14 | `EGVAR(core,garrRange)` | SLIDER | 1 | HAL Behaviour |
| 15 | `EGVAR(core,attInfDistance)` | SLIDER | 1 | HAL Behaviour |
| 16 | `EGVAR(core,attArmDistance)` | SLIDER | 1 | HAL Behaviour |
| 17 | `EGVAR(core,attSnpDistance)` | SLIDER | 1 | HAL Behaviour |
| 18 | `EGVAR(core,flankDistance)` | SLIDER | 1 | HAL Behaviour |
| 19 | `EGVAR(core,attSFDistance)` | SLIDER | 1 | HAL Behaviour |
| 20 | `EGVAR(core,reconDistance)` | SLIDER | 1 | HAL Behaviour |
| 21 | `EGVAR(core,captureDistance)` | SLIDER | 1 | HAL Behaviour |
| 22 | `EGVAR(common,uAVAlt)` | SLIDER | 150 | HAL Behaviour |
| 23 | `EGVAR(core,combining)` | CHECKBOX | false | HAL Behaviour |

#### Personality Settings (Leader_PersSettings_Module) -- 2 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `EGVAR(core,mAtt)` | CHECKBOX | true | HAL Personality |
| 2 | `EGVAR(core,personality)` | LIST | "COMPETENT" | HAL Personality |

#### Support Settings (Leader_SupSettings_Module) -- 10 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `EGVAR(core,cargoFind)` | SLIDER | 1 | HAL Support |
| 2 | `EGVAR(core,noAirCargo)` | CHECKBOX | false | HAL Support |
| 3 | `EGVAR(core,noLandCargo)` | CHECKBOX | false | HAL Support |
| 4 | `EGVAR(core,sMed)` | CHECKBOX | true | HAL Support |
| 5 | `EGVAR(core,sFuel)` | CHECKBOX | true | HAL Support |
| 6 | `EGVAR(core,sAmmo)` | CHECKBOX | true | HAL Support |
| 7 | `EGVAR(core,sRep)` | CHECKBOX | true | HAL Support |
| 8 | `EGVAR(core,supportWP)` | CHECKBOX | false | HAL Support |
| 9 | `EGVAR(core,artyShells)` | SLIDER | 1 | HAL Support |
| 10 | `EGVAR(core,airEvac)` | CHECKBOX | true | HAL Support |
| 11 | `EGVAR(core,supportRTB)` | CHECKBOX | true | HAL Support |

#### Objectives Settings (Leader_ObjSettings_Module) -- 16 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `EGVAR(core,order)` | CHECKBOX | false | HAL Objectives |
| 2 | `EGVAR(core,berserk)` | CHECKBOX | false | HAL Objectives |
| 3 | `EGVAR(core,simpleMode)` | CHECKBOX | true | HAL Objectives |
| 4 | `EGVAR(core,unlimitedCapt)` | CHECKBOX | false | HAL Objectives |
| 5 | `EGVAR(core,captLimit)` | SLIDER | 10 | HAL Objectives |
| 6 | `EGVAR(core,garrR)` | SLIDER | 500 | HAL Objectives |
| 7 | `EGVAR(core,objHoldTime)` | SLIDER | 60 | HAL Objectives |
| 8 | `EGVAR(core,objRadius1)` | SLIDER | 300 | HAL Objectives |
| 9 | `EGVAR(core,objRadius2)` | SLIDER | 500 | HAL Objectives |
| 10 | `EGVAR(core,lRelocating)` | CHECKBOX | false | HAL Objectives |
| 11 | `EGVAR(core,noRec)` | SLIDER | 10 | HAL Objectives |
| 12 | `EGVAR(core,rapidCapt)` | SLIDER | 10 | HAL Objectives |
| 13 | `EGVAR(core,defendObjectives)` | SLIDER | 4 | HAL Objectives |
| 14 | `EGVAR(core,reconReserve)` | SLIDER | (no default) | HAL Objectives |
| 15 | `EGVAR(core,attackReserve)` | SLIDER | (no default) | HAL Objectives |
| 16 | `EGVAR(core,cRDefRes)` | SLIDER | 0.4 | HAL Objectives |
| 17 | `EGVAR(core,aAO)` | CHECKBOX | false | HAL Objectives |
| 18 | `EGVAR(core,forceAAO)` | CHECKBOX | false | HAL Objectives |
| 19 | `EGVAR(core,bBAOObj)` | SLIDER | 4 | HAL Objectives |
| 20 | `EGVAR(core,maxSimpleObjs)` | SLIDER | 5 | HAL Objectives |
| 21 | `EGVAR(hal_hac,objectiveRespawn)` | CHECKBOX | false | HAL Objectives |

#### BB Settings (BBSettings_Module) -- 3 settings

| # | Argument class | Type | Default | Category |
|---|---------------|------|---------|----------|
| 1 | `GVAR(customObjOnly)` | CHECKBOX | true | HAL High Commander |
| 2 | `GVAR(lRelocating)` | CHECKBOX | false | HAL High Commander |
| 3 | `GVAR(mainInterval)` | SLIDER | 5 | HAL High Commander |

**Total CBA settings: ~92 (some are per-commander not global)**

[VERIFIED: CfgVehicles.hpp full read, all 2850 lines]

### Per-HQ Override Mechanics

CBA settings are singletons. The current `fnc_leader*Settings.sqf` functions (rewritten in Phase 4) read module arguments with a fallback default:
```sqf
missionNamespace setVariable [QGVAR(smoke) + _letter, _logic getVariable [QGVAR(smoke), true]];
```

Phase 5 changes the hardcoded `true` default to the CBA setting value:
```sqf
missionNamespace setVariable [QGVAR(smoke) + _letter, _logic getVariable [QGVAR(smoke), GVAR(smoke)]];
```

**Timing concern:** CBA settings are initialized during CBA's preInit via `CBA_fnc_addSetting`. The module functions run during module activation (usually postInit or trigger-activated). Since CBA settings are populated before modules fire, `GVAR(smoke)` will have its CBA value by the time `fnc_leaderBehaviourSettings.sqf` runs. No timing issue. [ASSUMED -- based on CBA standard behavior]

**General vs per-commander settings:** The GenSettings_Module settings (24 items) are truly global (one value for the whole mission). The Commander Settings / Behaviour / Personality / Support / Objectives settings are per-commander but CBA can only provide a single default. The CBA setting provides the default; module overrides specialize per HQ. This is the correct ACE3 pattern. [ASSUMED -- based on ACE3 convention]

---

## Block 3: Stringtable (D-05)

### LSTRING Macro Availability

`LSTRING()`, `LLSTRING()`, and `CSTRING()` are defined in CBA's `script_macros_common.hpp` (included via `addons/main/script_macros.hpp` line 1):
- `LSTRING(var1)` = `"STR_hal_<component>_var1"` -- for use in config.cpp/hpp `displayName`/`description` fields
- `LLSTRING(var1)` = `localize "STR_hal_<component>_var1"` -- for use in SQF runtime
- `CSTRING(var1)` = `"$STR_hal_<component>_var1"` -- config string form

These are standard CBA macros, no custom definition needed. [VERIFIED: include/x/cba/addons/main/script_macros_common.hpp lines 1274-1280]

### Stringtable Scope

Strings needed:

1. **CBA settings display names + tooltips:** ~92 settings x 2 = ~184 strings
2. **Module displayNames:** 9 editor modules (HAL Core, HAL General Settings, HAL Commander, Commander Settings, Commander Behaviour Settings, Commander Personality Settings, Commander Support Settings, Commander Objectives Settings, High Commander) = ~9 display names + ~9 descriptions = ~18 strings
3. **Module category labels:** core, leader, utilities, objectives, squad, attributes, BB = ~7 strings
4. **Squad property module displayNames:** 20 squad modules x (displayName + description) = ~40 strings

**Estimated total: ~250 string entries** (higher than CONTEXT.md's 50-80 estimate because every CBA setting needs both a name and tooltip string).

The stringtable format:
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project name="HAL">
  <Package name="core">
    <Key ID="STR_hal_core_smoke">
      <English>Smoke For Retreat</English>
    </Key>
    <Key ID="STR_hal_core_smoke_desc">
      <English>Squads will use smoke grenades to cover their retreat.</English>
    </Key>
  </Package>
</Project>
```

**Location:** `addons/main/stringtable.xml` (centralized, per ACE3 convention) [ASSUMED -- ACE3 typically puts stringtable in the main addon]

---

## Block 4: Compatibility Addon (D-03)

### Old Module Classnames (COMPAT-01)

From the compat_nr6hal skeleton (classname inventory comments):

| Old classname | New classname | Notes |
|--------------|---------------|-------|
| `NR6_HAL_Core_Module` | `hal_missionmodules_Core_Module` | |
| `NR6_HAL_Leader_Module` | `hal_missionmodules_Leader_Module` | |
| `NR6_HAL_Leader_Settings_Module` | `hal_missionmodules_Leader_Settings_Module` | |
| `NR6_HAL_GenSettings_Module` | `hal_missionmodules_GenSettings_Module` | |
| `NR6_HAL_Leader_BehSettings_Module` | `hal_missionmodules_Leader_BehSettings_Module` | |
| `NR6_HAL_Objective_Module` | `hal_missionmodules_Leader_Objective_Module` | Name changed |
| `NR6_HAL_BBObjective_Module` | `hal_missionmodules_BBLeader_Objective_Module` | Name changed |
| `NR6_HAL_BBLeader_Module` | `hal_missionmodules_BBLeader_Module` | |
| `NR6_HAL_Front_Module` | `hal_missionmodules_Leader_Front_Module` | Name changed |

Implementation: Each old classname becomes a CfgVehicles class inheriting from the new classname:
```cpp
class NR6_HAL_Core_Module: hal_missionmodules_Core_Module {};
```

[VERIFIED: compat_nr6hal/config.cpp classname inventory]

### Function Variable Aliases (COMPAT-02)

All bare global function handles that user scripts or missions might reference:

**41 HAL_* handles from VarInit.sqf (lines 1088-1128):**
```
HAL_EnemyScan, HAL_Flanking, HAL_Garrison, HAL_GoAmmoSupp, HAL_GoAttAir,
HAL_GoAttAirCAP, HAL_GoAttArmor, HAL_GoAttInf, HAL_GoAttSniper, HAL_GoAttNaval,
HAL_GoCapture, HAL_GoCaptureNaval, HAL_GoDef, HAL_GoDefAir, HAL_GoDefRecon,
HAL_GoDefRes, HAL_GoDefNav, HAL_GoFlank, HAL_GoFuelSupp, HAL_GoIdle,
HAL_GoMedSupp, HAL_GoRecon, HAL_GoRepSupp, HAL_GoRest, HAL_GoSFAttack,
HAL_HQOrders, HAL_HQOrdersEast, HAL_HQOrdersDef, HAL_HQReset, HAL_LHQ,
HAL_LPos, HAL_Personality, HAL_Reloc, HAL_Rev, HAL_SCargo, HAL_SFIdleOrd,
HAL_Spotscan, HAL_SuppAmmo, HAL_SuppFuel, HAL_SuppMed, HAL_SuppRep
```

**2 special handles:**
- `Boss` -> `EFUNC(hal_boss,boss)`
- `Desperado` -> `EFUNC(hal_hac,desperation)`

**8 HQSitRep handles:**
- `A_HQSitRep` through `H_HQSitRep` -> each maps to their respective PREP'd function

**2 engine function handles from fnc_init.sqf:**
- `HAL_fnc_getType` -- loads from A3 engine, NOT user-replaceable, keep as-is
- `HAL_fnc_getSize` -- loads from A3 engine, NOT user-replaceable, keep as-is

**CfgFunctions aliases (from nr6_hal/config.cpp):**
The old config.cpp defined ~45 CfgFunctions entries under `class NR6`. These map to function names like `NR6_fnc_HALcore`, `NR6_fnc_HALGenset`, etc. The compat addon may need CfgFunctions entries for these if any user scripts call them by name, though this is unlikely since they are module functions.

Implementation: In `addons/compat_nr6hal/XEH_postInit.sqf`:
```sqf
// Function handle aliases
HAL_EnemyScan = EFUNC(core,enemyScan);
HAL_GoAttInf = EFUNC(hal_hac,goAttInf);
// ... etc for all 41+2+8 handles
Boss = EFUNC(hal_boss,boss);
Desperado = EFUNC(hal_hac,desperation);
A_HQSitRep = EFUNC(core,HQSitRep);
B_HQSitRep = EFUNC(core,HQSitRepB);
// etc.
```

[VERIFIED: VarInit.sqf function handle assignments, addons/ call site grep]

### Global Variable Aliases from rename-map.json (D-03 + Phase 4 D-05)

The rename-map.json has 506 entries, 0 stripped. Each needs a compat alias:
```sqf
RydHQ_Activity = EGVAR(core,activity);
publicVariable "RydHQ_Activity";
```

Schema per entry:
```json
{
  "legacy_name": "RHQ_AAInf",
  "new_macro_owner_form": "GVAR(aAInf)",
  "new_macro_extern_form": "EGVAR(hal_data,aAInf)",
  "new_literal_expansion": "hal_hal_data_aAInf",
  "addon_owner": "hal_data",
  "stripped": false,
  ...
}
```

After the dead-var audit (D-06), stripped entries will be excluded from aliasing. The compat postInit will use the `new_literal_expansion` as the source and `legacy_name` as the target. [VERIFIED: rename-map.json schema inspection, 506 entries confirmed]

---

## Block 5: Dead-Var Audit (D-06)

### Audit Procedure

After extraction (all code in addons/), grep each of the 506 rename-map entries:

```bash
# For each entry in rename-map.json:
# Check if the variable has any READERS (getVariable, direct use, isNil check)
# An entry is DEAD if it only has WRITERS (setVariable) and no readers

# Step 1: Get all entries
python -c "
import json
data = json.load(open('.planning/phases/04-variable-namespacing/rename-map.json'))
for e in data['entries']:
    name = e['new_literal_expansion']
    # grep for readers: getVariable [...name...], isNil QGVAR form, or direct GVAR() use
    print(name)
"

# Step 2: For each literal expansion, grep addons/ for readers
# A variable is alive if it has at least one getVariable/isNil reader
# A variable is dead if it ONLY has setVariable writers

# Step 3: Mark dead entries as stripped:true in rename-map.json
```

The audit must run AFTER extraction because some readers may be in the newly-extracted HAL/*.sqf files. [ASSUMED -- standard grep-based audit pattern from Phase 4]

---

## Block 6: Behavior Verification Tests (D-04)

### Test Structure

Tests live in `addons/tests/` (or `tests/` at project root). Each test is a standalone SQF script runnable via `execVM "tests/test_BEHAV_01.sqf"` in the Arma 3 debug console.

### Observable States per BEHAV Requirement

#### BEHAV-01: HQ Initialization

After HQ init (wait ~20s after mission start):
- `group leaderHQ` is NOT null
- `(group leaderHQ) getVariable [QEGVAR(core,codeSign), ""]` equals `"A"`
- Personality traits set: `(group leaderHQ) getVariable [QEGVAR(core,recklessness), -1]` is in range [0,1]
- Same for: consistency, activity, reflex, circumspection, fineness
- `EGVAR(core,allHQ)` is an array with count > 0
- `EGVAR(core,allLeaders)` is an array with count > 0

#### BEHAV-02: Group Management

After adding a group via Include module (wait ~30s):
- `(group leaderHQ) getVariable [QEGVAR(core,friends), []]` contains at least 1 group
- At least one subordinate group has an active waypoint (`count (waypoints _grp) > 0`)

#### BEHAV-03: Enemy Scanning

After placing enemies within 1000m (wait ~60s for scan cycle):
- `(group leaderHQ) getVariable [QEGVAR(core,knownEnemy), []]` is NOT empty
- `(group leaderHQ) getVariable [QEGVAR(core,hostileGroups), []]` is NOT empty

#### BEHAV-04: Artillery/CFF

With artillery battery present and enemies in range:
- `(group leaderHQ) getVariable [QEGVAR(core,batteryBusy), false]` has been set (regardless of value)
- At least one arty fire mission variable has been touched

#### BEHAV-05: AI Chatter

With `hal_core_hQChat = true`:
- After ~30s, check that sideChat messages have fired (hardest to verify programmatically)
- Alternative: verify `EGVAR(core,aIChatDensity)` is read and `EFUNC(common,AIChatter)` has been called
- Pragmatic: set a debug flag in AIChatter and check it

[ASSUMED -- based on fnc_HQSitRep.sqf, fnc_statusQuo.sqf, fnc_personality.sqf variable analysis]

---

## Common Pitfalls

### Pitfall 1: HAL_ function handle call sites not updated

**What goes wrong:** After extracting HAL/*.sqf as PREP'd functions, forgetting to update a `call HAL_GoAttInf` to `call EFUNC(hal_hac,goAttInf)` causes nil function call -- AI silently stops issuing that order type.
**Why it happens:** 40+ call sites across addons/ and within the newly-extracted HAL/*.sqf files themselves (cross-references like `HAL_GoFlank` called from `Flanking.sqf`).
**How to avoid:** After extraction, grep for all remaining `HAL_` bare globals in addons/. Zero hits required (except in compat addon).
**Warning signs:** `undefined=true` HEMTT lint will catch some but NOT runtime-compiled scripts.

### Pitfall 2: HQSitRep dynamic dispatch broken

**What goes wrong:** fnc_init.sqf:183 uses `missionNamespace getVariable (_codeSign + "_HQSitRep")` to dispatch per-HQ SitRep functions. If `A_HQSitRep` through `H_HQSitRep` are not set after extraction, all HQ SitRep loops silently fail.
**Why it happens:** VarInit.sqf set these variables. After removing VarInit.sqf, they must be set elsewhere.
**How to avoid:** In fnc_init.sqf (or a new fnc_varInit.sqf), set `A_HQSitRep = EFUNC(core,HQSitRep)` etc. BEFORE the dispatch loop at line 183.
**Warning signs:** No SitRep markers appearing, no threat updates to HQ.

### Pitfall 3: Sound path references not updated

**What goes wrong:** CfgRadio entries reference `\NR6_HAL\Sound\...` but after moving Sound/ to `addons/hal_data/Sound/`, the PBO path changes to `\z\hal\addons\hal_data\Sound\...`. If paths are wrong, all radio chatter becomes silent.
**Why it happens:** 351 CfgRadio class entries each have a hardcoded path.
**How to avoid:** Batch find-replace all `\NR6_HAL\Sound\` to `\z\hal\addons\hal_data\Sound\` in the CfgRadio config.
**Warning signs:** Radio chatter icon appears but no sound plays.

### Pitfall 4: CBA settings registration timing

**What goes wrong:** If CBA settings are registered too late (postInit instead of preInit), module functions that read `GVAR(settingName)` as a default may get nil values.
**Why it happens:** CBA_fnc_addSetting must run during preInit or before module activation.
**How to avoid:** Use `initSettings.inc.sqf` included from `XEH_preInit.sqf` (standard ACE3 pattern).
**Warning signs:** All settings default to nil, modules override everything.

### Pitfall 5: Dead-var audit missing readers in newly-extracted files

**What goes wrong:** If the dead-var audit runs BEFORE extraction, it misses readers in the HAL/*.sqf files (which are about to become addons/ code). Variables are incorrectly stripped, causing runtime failures.
**Why it happens:** The audit only greps addons/ -- files still in nr6_hal/ are invisible.
**How to avoid:** D-06 specifies: audit AFTER extraction, BEFORE compat aliasing. Follow this order strictly.
**Warning signs:** Variables that AI behavior scripts read are marked dead and removed.

---

## Architecture Patterns

### Extraction Pattern for HAL/*.sqf Files

Each HAL/*.sqf file becomes a PREP'd function following this template:

```sqf
// addons/hal_hac/functions/fnc_goAttInf.sqf
#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/GoAttInf.sqf
// NOTE: No params/private conversion per D-05 (deferred to v1.1)

// ... original file content, with these changes:
// 1. Add #include header
// 2. Replace any RYD_Spawn calls with EFUNC(common,spawn)
// 3. Replace any HAL_* bare globals with EFUNC() macros
// 4. Replace any RYD_*/RydHQ_* bare globals with GVAR()/EGVAR() (should already be done in Phase 4 for addons/ code, but nr6_hal/ files were NOT Phase-4-renamed)
```

**CRITICAL:** The nr6_hal/HAL/*.sqf files were NOT processed by Phase 4 variable renaming (Phase 4 only touched addons/). They still contain raw `RydHQ_*`, `RydxHQ_*`, `RYD_*` variable names. During extraction, these MUST be converted to GVAR()/EGVAR() macros using the rename-map.json. This is a significant amount of work -- 20,802 lines of code with legacy variable names.

### CBA Settings Pattern (ACE3 standard)

```sqf
// addons/core/initSettings.inc.sqf
[
    QGVAR(smoke),           // setting name
    "CHECKBOX",             // setting type
    [LSTRING(smoke), LSTRING(smoke_desc)], // [displayName, tooltip]
    LSTRING(category_behaviour), // category
    true,                   // default value
    1                       // 1 = server only (publicVariable'd)
] call CBA_fnc_addSetting;
```

Include from XEH_preInit.sqf:
```sqf
#include "initSettings.inc.sqf"
```

### Compat Addon Pattern

```cpp
// addons/compat_nr6hal/config.cpp
class CfgVehicles {
    class hal_missionmodules_Core_Module;
    class NR6_HAL_Core_Module: hal_missionmodules_Core_Module {};
    // ... 8 more old->new mappings
};
```

```sqf
// addons/compat_nr6hal/XEH_postInit.sqf
// Function handle aliases
HAL_EnemyScan = EFUNC(core,enemyScan);
HAL_GoAttInf = EFUNC(hal_hac,goAttInf);
// ... all 41 + 2 + 8 handles

// Global variable aliases (from rename-map.json, non-stripped only)
RydHQ_Activity = EGVAR(core,activity);
// ... up to 506 entries
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Settings UI | Custom dialog | CBA_fnc_addSetting | Handles menu, persistence, MP sync, server/client scope |
| Localization | Hardcoded strings | stringtable.xml + LSTRING() | CBA macro chain handles compilation |
| Function compilation | `compile preprocessFile` | CBA PREP macro | Caching, error reporting, compile-order safety |
| Classname compat | Mission SQF patches | CfgVehicles inheritance | Engine-level, zero runtime cost |
| Variable aliasing | Complex proxy objects | Simple `oldName = newName` assignment | One-directional alias is sufficient per CONTEXT.md |

---

## Risks

### Risk 1: nr6_hal/ files contain un-renamed legacy variables

**Symptom:** After extraction, HEMTT lint reports hundreds of undefined variable warnings from the newly-extracted files.
**Detection:** First `hemtt build` after extraction batch.
**Mitigation:** Each extracted HAL/*.sqf file needs Phase 4-style variable renaming. Plan to use the Phase 4 rename tool (`scripts/phase4-rename.py`) on the newly-placed files, or do manual replacement using rename-map.json. Budget significant time for this.

### Risk 2: Circular dependencies between HAL/*.sqf files

**Symptom:** Function A calls function B which calls function A -- CBA PREP order cannot resolve.
**Detection:** Grep cross-references between HAL/*.sqf files before extraction.
**Mitigation:** All HAL/*.sqf are compiled at preInit via PREP. They only CALL each other at runtime (not at compile time). CBA PREP order doesn't matter for runtime calls -- only for compile-time dependencies. This risk is LOW. [ASSUMED]

### Risk 3: Boss.sqf is too large for a single function file

**Symptom:** `fnc_boss.sqf` at 2021 lines violates no explicit rule but is hard to maintain.
**Detection:** Visual inspection.
**Mitigation:** Per CONTEXT.md deferred ideas, no decomposition in Phase 5. Extract as-is. Decomposition is a v1.1 candidate.

### Risk 4: CfgRadio path references scattered through config

**Symptom:** 351 sound entries with wrong paths = complete radio silence.
**Detection:** In-game testing.
**Mitigation:** Automated find-replace of all 351 entries. Single pattern replacement: `\NR6_HAL\Sound\` -> `\z\hal\addons\hal_data\Sound\`. Verify count matches (351 entries).

### Risk 5: compat postInit too large (506 variable aliases + 51 function aliases)

**Symptom:** Noticeable mission start delay from 557 global variable assignments.
**Detection:** Profiling.
**Mitigation:** This is a one-time cost at mission start. 557 assignments take negligible time in SQF. Not a real performance risk. [ASSUMED]

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | CBA settings registered in preInit are available before module activation in postInit | CBA Settings / Per-HQ Override | Module defaults would be nil instead of CBA setting values |
| A2 | ACE3 convention places stringtable.xml in addons/main/ | Stringtable | Would need to be moved; no functional impact |
| A3 | CBA PREP order doesn't matter for runtime-only cross-calls between HAL functions | Risk 2 | Could cause nil function calls at runtime if PREP depends on order |
| A4 | 557 global assignments in compat postInit have negligible performance impact | Risk 5 | Mission start delay; could split into lazy-load if needed |
| A5 | nr6_hal/HAL/*.sqf files still contain raw RydHQ_*/RYD_* variable names (not Phase 4 renamed) | Block 1 Architecture | If already renamed, extraction is simpler; if not, need full rename pass |

---

## Open Questions

1. **Boss_fnc.sqf residual loading**
   - What we know: fnc_init.sqf:147 still does `call compile preprocessFile (GVAR(path) + "Boss_fnc.sqf")`. Phase 3 already extracted all 20 Boss_fnc.sqf functions to hal_boss.
   - What's unclear: Does Boss_fnc.sqf still contain any non-extracted content, or is it now empty/redundant?
   - Recommendation: Read Boss_fnc.sqf during plan execution. If empty, delete loader from fnc_init.sqf. If not, extract remaining content.

2. **VarInit.sqf unique content (lines 1-161)**
   - What we know: Lines 162-1084 are weapon class arrays (already in fnc_initWeaponClasses.sqf). Lines 1085-1211 are function handles + HQ setup.
   - What's unclear: Lines 1-161 contain artillery/smoke/flare arrays and defaults. Are these already covered by Phase 4 renames in addons/, or are they the authoritative source?
   - Recommendation: Read VarInit.sqf lines 1-161 during extraction. Compare with existing addons/ code to identify unique content that must be preserved.

3. **LF/LF.sqf relationship to common/fnc_LF.sqf**
   - What we know: `PREP(LF)` exists in common. `nr6_hal/LF/LF.sqf` is 10 lines.
   - What's unclear: Is LF.sqf the caller or a duplicate of fnc_LF.sqf?
   - Recommendation: Compare files during execution.

---

## Sources

### Primary (HIGH confidence)
- `addons/core/functions/fnc_init.sqf` -- verified all load mechanisms and call sites
- `nr6_hal/VarInit.sqf` -- verified HAL_ function handle assignments (lines 1085-1211)
- `addons/missionmodules/CfgVehicles.hpp` -- verified all 2850 lines for settings enumeration
- `addons/compat_nr6hal/config.cpp` -- verified classname inventory (9 module classes)
- `.planning/phases/04-variable-namespacing/rename-map.json` -- verified 506 entries, 0 stripped
- `include/x/cba/addons/main/script_macros_common.hpp` -- verified LSTRING/LLSTRING/CSTRING macros
- XEH_PREP.hpp files for all addons -- verified already-migrated functions

### Secondary (MEDIUM confidence)
- `nr6_hal/config.cpp` -- CfgRadio section (351 classes, 4450 total lines)
- All HAL/*.sqf files -- line counts verified via wc -l
- Sound directory listing -- verified 300+ audio files across 3 voice packs

---

## Metadata

**Confidence breakdown:**
- File inventory: HIGH -- all files counted and loading mechanisms traced
- CBA settings: HIGH -- all CfgVehicles.hpp arguments enumerated from source
- Compat classnames: HIGH -- inventory from Phase 1 compat skeleton verified
- Function handle dispatch: HIGH -- VarInit.sqf handle assignments fully mapped
- Stringtable scope: MEDIUM -- estimated count, actual may vary based on dedup
- Behavior verification states: MEDIUM -- based on code analysis, not runtime testing

**Research date:** 2026-04-11
**Valid until:** 2026-05-11 (stable -- Arma 3/CBA APIs rarely change)

---

## RESEARCH COMPLETE
