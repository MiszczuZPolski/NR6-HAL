# Phase 2 PREP Ordering (Leaf-First)

Ordering respects Phase 1 D-03 DAG (hal_data → hal_hac → hal_boss → hal_tasking).
Within each target_addon group, functions are sorted leaf-first by call-graph topological order, tie-broken by file then line.

Only `active` and `dead?` symbols requiring Phase 3 decisions are included. `migrated` symbols already have addons/common equivalents and are excluded from PREP ordering (their legacy bodies are deleted, not re-extracted).

Sources: wave 2 map files (map-hac-fnc.md, map-hac-fnc2.md, map-rhq-library.md, map-boss-fnc.md, map-boss-sqf.md, map-taskinit.md, map-squadtasking.md).

---

## hal_data (33 active symbols)

All RHQLibrary.sqf data arrays are pure static declarations with no outbound in-scope calls — they are all leaves. The composite `RYD_WS_AllClasses` depends on the 11 sub-arrays it concatenates, so it comes last among the arrays. `RYD_PresentRHQ` reads the arrays at runtime, so it follows after all arrays. `RYD_PresentRHQLoop` wraps `RYD_PresentRHQ` — comes last.

### Data Arrays (RHQLibrary.sqf — all leaves, no outbound calls)

1.  RYD_WS_specFor_class (RHQLibrary.sqf:1)       — leaf (static data array)
2.  RYD_WS_recon_class (RHQLibrary.sqf:5)          — leaf (static data array)
3.  RYD_WS_FO_class (RHQLibrary.sqf:41)            — leaf (static data array)
4.  RYD_WS_snipers_class (RHQLibrary.sqf:50)       — leaf (static data array)
5.  RYD_WS_ATinf_class (RHQLibrary.sqf:64)         — leaf (static data array)
6.  RYD_WS_AAinf_class (RHQLibrary.sqf:80)         — leaf (static data array)
7.  RYD_WS_Inf_class (RHQLibrary.sqf:90)           — leaf (static data array)
8.  RYD_WS_Art_class (RHQLibrary.sqf:262)          — leaf (static data array)
9.  RYD_WS_HArmor_class (RHQLibrary.sqf:279)       — leaf (static data array)
10. RYD_WS_MArmor_class (RHQLibrary.sqf:287)       — leaf (static data array)
11. RYD_WS_LArmor_class (RHQLibrary.sqf:291)       — leaf (static data array)
12. RYD_WS_LArmorAT_class (RHQLibrary.sqf:303)     — leaf (static data array)
13. RYD_WS_Cars_class (RHQLibrary.sqf:311)         — leaf (static data array)
14. RYD_WS_Air_class (RHQLibrary.sqf:366)          — leaf (static data array)
15. RYD_WS_BAir_class (RHQLibrary.sqf:409)         — leaf (static data array, not in AllClasses)
16. RYD_WS_RAir_class (RHQLibrary.sqf:416)         — leaf (static data array, not in AllClasses)
17. RYD_WS_NCAir_class (RHQLibrary.sqf:429)        — leaf (static data array, not in AllClasses)
18. RYD_WS_Naval_class (RHQLibrary.sqf:446)        — leaf (static data array)
19. RYD_WS_Static_class (RHQLibrary.sqf:462)       — leaf (static data array)
20. RYD_WS_StaticAA_class (RHQLibrary.sqf:497)     — leaf (static data array)
21. RYD_WS_StaticAT_class (RHQLibrary.sqf:504)     — leaf (static data array)
22. RYD_WS_Support_class (RHQLibrary.sqf:511)      — leaf (static data array)
23. RYD_WS_Cargo_class (RHQLibrary.sqf:538)        — leaf (static data array)
24. RYD_WS_NCCargo_class (RHQLibrary.sqf:606)      — leaf (static data array)
25. RYD_WS_Crew_class (RHQLibrary.sqf:648)         — leaf (static data array)
26. RYD_WS_Other_class (RHQLibrary.sqf:665)        — leaf (static data array)
27. RYD_WS_rep (RHQLibrary.sqf:672)                — leaf (static data array)
28. RYD_WS_med (RHQLibrary.sqf:693)                — leaf (static data array)
29. RYD_WS_fuel (RHQLibrary.sqf:712)               — leaf (static data array)
30. RYD_WS_ammo (RHQLibrary.sqf:731)               — leaf (static data array)
31. RYD_WS_AllClasses (RHQLibrary.sqf:752)         — depends on 11 RYD_WS_*_class arrays above

### Code Functions (HAC_fnc2.sqf)

32. RYD_PresentRHQ (HAC_fnc2.sqf:2207)             — reads all RYD_WS_* arrays; must follow array declarations
33. RYD_PresentRHQLoop (HAC_fnc2.sqf:3233)         — wraps RYD_PresentRHQ (spawn); must follow PresentRHQ

---

## hal_hac (3 active/dead? symbols)

Active: RYD_Dispatcher. Dead?: RYD_FindClosestWithIndex, RYD_DistOrd, RYD_DistOrdC.

Dependency analysis (active only):
- RYD_Dispatcher calls RYD_VarReductor (migrated — not in active scope) and external HAL_* functions. No in-scope active outbound calls. → leaf.

Dead? functions (no active callers in 7-file scope — included for Phase 3 confirmation):
- RYD_FindClosestWithIndex: no in-scope active callers → leaf (dead, confirm before delete)
- RYD_DistOrd: callers are in commented blocks → leaf (dead, HAL/ scope check needed)
- RYD_DistOrdC: no callers in 7-file scope → leaf (dead, HAL/ scope check needed)

Also dead?: RYD_LF_Loop (HAC_fnc2.sqf:1780) — no callers in 7-file scope. Target_addon: hal_hac. Confirm before delete.

1. RYD_FindClosestWithIndex (HAC_fnc.sqf:1000)  — dead? leaf (no active in-scope callers; AMBIGUOUS)
2. RYD_DistOrd (HAC_fnc.sqf:1077)              — dead? leaf (callers in commented blocks; HAL/ check needed)
3. RYD_DistOrdC (HAC_fnc.sqf:1108)             — dead? leaf (no callers; AMBIGUOUS)
4. RYD_LF_Loop (HAC_fnc2.sqf:1780)             — dead? leaf (no active callers; AMBIGUOUS)
5. RYD_Dispatcher (HAC_fnc.sqf:1276)           — active leaf (in-scope calls are all to migrated/external symbols)

---

## hal_boss (26 active symbols)

Active functions from Boss_fnc.sqf (21) + HAC_fnc2.sqf HAL_* functions (3) + RYD_StatusQuo (1) + Boss.sqf main loop (1 structural section treated as a single entry point).

### Internal dependency edges (in-scope active → in-scope active):

- RYD_WhereIs → RYD_AngTowards (migrated — external; leaf in scope)
- RYD_LocLineTransform → RYD_AngTowards (migrated; leaf in scope)
- RYD_LocMultiTransform → RYD_AngTowards (migrated; leaf in scope)
- RYD_TopoAnalize → RYD_Sectorize [reads sector variables, no direct call to Sectorize — leaf]
- RYD_Itinerary → RYD_LocLineTransform
- RYD_ClusterA → (none — pure math; leaf)
- RYD_ClusterB → (none — pure math; leaf)
- RYD_Cluster → RYD_ClusterB, RYD_ClusterA
- RYD_BBSimpleD → RYD_Cluster, RYD_isOnMap, RYD_Marker (+ migrated RYD_AngTowards, RYD_Mark)
- RYD_ObjMark → RYD_Marker
- RYD_ExecuteObj → RYD_LocLineTransform, RYD_Marker (+ migrated: RYD_AIChatter, RYD_WPadd, RYD_Wait, RYD_Spawn, RYD_AddTask, RYD_Mark)
- RYD_ExecutePath → RYD_DistOrdB, RYD_Marker, RYD_ExecuteObj (value-pass via RYD_Spawn)
- RYD_ReserveExecuting → RYD_Marker, RYD_LocLineTransform (+ migrated)
- RYD_ObjectivesMon → (Arma 3 API only; leaf)
- RYD_Sectorize → (Arma 3 API only; leaf)
- RYD_Marker → (Arma 3 marker API only; leaf)
- RYD_DistOrdB → (pure math; leaf)
- RYD_ForceCount → (pure math; leaf)
- RYD_ForceAnalyze → (Arma 3 API; leaf)
- RYD_isOnMap → (reads namespace variable; leaf)
- RYD_TerraCognita → (Arma 3 selectBestPlaces; leaf — DUAL PRESENCE, use migrated version)
- HAL_EBFT → (Arma 3 engine fns; leaf — spawned by RYD_StatusQuo)
- HAL_SecTasks → (reads namespace; leaf)
- HAL_FBFTLOOP → (Arma 3 engine fns; leaf)
- RYD_StatusQuo → HAL_EBFT (spawn, in-scope), + many external HAL_* calls; spawned from fnc_init.sqf
- Boss.sqf main loop → calls RYD_Sectorize, RYD_TerraCognita, RYD_ForceAnalyze, RYD_ForceCount, RYD_WhereIs, RYD_TopoAnalize, RYD_Marker, RYD_ObjMark, RYD_BBSimpleD, RYD_Itinerary, RYD_LocMultiTransform, RYD_ExecutePath, RYD_ReserveExecuting, RYD_ObjectivesMon

Topological order (leaves first, then callers):

**Tier 1 — leaves (no outbound in-scope active calls):**
1.  RYD_Marker (Boss_fnc.sqf:1)          — leaf (Arma 3 marker API only)
2.  RYD_DistOrdB (Boss_fnc.sqf:40)       — leaf (pure math)
3.  RYD_Sectorize (Boss_fnc.sqf:175)     — leaf (Arma 3 location API)
4.  RYD_ForceCount (Boss_fnc.sqf:418)    — leaf (pure math, no in-scope calls)
5.  RYD_ForceAnalyze (Boss_fnc.sqf:513)  — leaf (Arma 3 unit API)
6.  RYD_TopoAnalize (Boss_fnc.sqf:576)   — leaf (reads sector getVariable set by Sectorize, no direct call)
7.  RYD_TerraCognita (Boss_fnc.sqf:106)  — leaf (Arma 3 selectBestPlaces; DUAL PRESENCE — use migrated version)
8.  RYD_isOnMap (Boss_fnc.sqf:1952)      — leaf (namespace read only)
9.  RYD_ObjectivesMon (Boss_fnc.sqf:1578) — leaf (Arma 3 unit API; spawned via value-pass)
10. RYD_ClusterA (Boss_fnc.sqf:1769)     — leaf (pure math)
11. RYD_ClusterB (Boss_fnc.sqf:1811)     — leaf (pure math)
12. HAL_FBFTLOOP (HAC_fnc2.sqf:2871)     — leaf (Arma 3 engine fns; spawned from fnc_init.sqf)
13. HAL_EBFT (HAC_fnc2.sqf:3029)         — leaf (Arma 3 engine fns; spawned from StatusQuo)
14. HAL_SecTasks (HAC_fnc2.sqf:3121)     — leaf (reads namespace; spawned from fnc_init.sqf)

**Tier 2 — depends on Tier 1:**
15. RYD_WhereIs (Boss_fnc.sqf:67)        — calls RYD_AngTowards (migrated); in-scope leaf from active perspective
16. RYD_LocLineTransform (Boss_fnc.sqf:259) — calls RYD_AngTowards (migrated); in-scope leaf
17. RYD_LocMultiTransform (Boss_fnc.sqf:282) — calls RYD_AngTowards (migrated); in-scope leaf
18. RYD_Cluster (Boss_fnc.sqf:1887)      — calls RYD_ClusterB (15), RYD_ClusterA (16)
19. RYD_ObjMark (Boss_fnc.sqf:1723)      — calls RYD_Marker (1)

**Tier 3 — depends on Tier 2:**
20. RYD_Itinerary (Boss_fnc.sqf:629)     — calls RYD_LocLineTransform (16)
21. RYD_BBSimpleD (Boss_fnc.sqf:2000)    — calls RYD_Cluster (18), RYD_isOnMap (8), RYD_Marker (1)
22. RYD_ExecuteObj (Boss_fnc.sqf:696)    — calls RYD_LocLineTransform (16), RYD_Marker (1)
23. RYD_ReserveExecuting (Boss_fnc.sqf:1320) — calls RYD_Marker (1), RYD_LocLineTransform (16)

**Tier 4 — depends on Tier 3:**
24. RYD_ExecutePath (Boss_fnc.sqf:1201)  — calls RYD_DistOrdB (2), RYD_Marker (1), RYD_ExecuteObj value-pass (22)

**Tier 5 — top-level callers:**
25. RYD_StatusQuo (HAC_fnc2.sqf:1)      — spawns HAL_EBFT (13); calls many external HAL_* fns
26. Boss.sqf (Boss.sqf:1)               — structural main loop; calls 14 Boss_fnc.sqf functions (entry point)

---

## hal_tasking (73 active symbols)

All 72 TaskInitNR6.sqf declarations have no mutual outbound calls to each other — each slot's functions are independent callbacks that call migrated/external functions only. They are all leaves with respect to each other. SquadTaskingNR6.sqf dispatches them via remoteExecCall (string dispatch) — it is the caller, so it comes last.

### Leaf tier (no outbound calls to other hal_tasking symbols):

All 72 TaskInitNR6 declarations (ordered by slot, then line within slot):

1.  Action1ct (TaskInitNR6.sqf:3)
2.  Action1fnc (TaskInitNR6.sqf:23)
3.  ACEAction1fnc (TaskInitNR6.sqf:33)
4.  Action1fncR (TaskInitNR6.sqf:131)
5.  ACEAction1fncR (TaskInitNR6.sqf:142)
6.  Action2ct (TaskInitNR6.sqf:50)
7.  Action2fnc (TaskInitNR6.sqf:58)
8.  ACEAction2fnc (TaskInitNR6.sqf:75)
9.  Action2fncR (TaskInitNR6.sqf:152)
10. ACEAction2fncR (TaskInitNR6.sqf:163)
11. Action3ct (TaskInitNR6.sqf:90)
12. Action3fnc (TaskInitNR6.sqf:98)
13. ACEAction3fnc (TaskInitNR6.sqf:115)
14. Action3fncR (TaskInitNR6.sqf:173)
15. ACEAction3fncR (TaskInitNR6.sqf:184)
16. Action4ct (TaskInitNR6.sqf:197)
17. Action4fnc (TaskInitNR6.sqf:250)
18. ACEAction4fnc (TaskInitNR6.sqf:267)
19. Action4fncR (TaskInitNR6.sqf:288)
20. ACEAction4fncR (TaskInitNR6.sqf:299)
21. Action5ct (TaskInitNR6.sqf:309)
22. Action5fnc (TaskInitNR6.sqf:368)
23. ACEAction5fnc (TaskInitNR6.sqf:385)
24. Action5fncR (TaskInitNR6.sqf:402)
25. ACEAction5fncR (TaskInitNR6.sqf:413)
26. Action6ct (TaskInitNR6.sqf:423)
27. Action6fnc (TaskInitNR6.sqf:481)
28. ACEAction6fnc (TaskInitNR6.sqf:498)
29. Action6fncR (TaskInitNR6.sqf:515)
30. ACEAction6fncR (TaskInitNR6.sqf:526)
31. Action7ct (TaskInitNR6.sqf:537)
32. Action7fnc (TaskInitNR6.sqf:630)
33. ACEAction7fnc (TaskInitNR6.sqf:647)
34. Action7fncR (TaskInitNR6.sqf:664)
35. ACEAction7fncR (TaskInitNR6.sqf:675)
36. Action8ct (TaskInitNR6.sqf:688)
37. Action8fnc (TaskInitNR6.sqf:727)
38. ACEAction8fnc (TaskInitNR6.sqf:744)
39. Action8fncR (TaskInitNR6.sqf:765)
40. ACEAction8fncR (TaskInitNR6.sqf:776)
41. Action9ct (TaskInitNR6.sqf:786)
42. Action9fnc (TaskInitNR6.sqf:822)
43. ACEAction9fnc (TaskInitNR6.sqf:839)
44. Action9fncR (TaskInitNR6.sqf:856)
45. ACEAction9fncR (TaskInitNR6.sqf:867)
46. Action10ct (TaskInitNR6.sqf:877)
47. Action10fnc (TaskInitNR6.sqf:913)
48. ACEAction10fnc (TaskInitNR6.sqf:930)
49. Action10fncR (TaskInitNR6.sqf:947)
50. ACEAction10fncR (TaskInitNR6.sqf:958)
51. Action11ct (TaskInitNR6.sqf:968)
52. Action11fnc (TaskInitNR6.sqf:1004)
53. ACEAction11fnc (TaskInitNR6.sqf:1021)
54. Action11fncR (TaskInitNR6.sqf:1038)
55. ACEAction11fncR (TaskInitNR6.sqf:1049)
56. Action12ct (TaskInitNR6.sqf:1059)
57. Action12fnc (TaskInitNR6.sqf:1095)
58. ACEAction12fnc (TaskInitNR6.sqf:1112)
59. Action12fncR (TaskInitNR6.sqf:1129)
60. ACEAction12fncR (TaskInitNR6.sqf:1140)
61. Action13ct (TaskInitNR6.sqf:1151)
62. Action13fnc (TaskInitNR6.sqf:1187)
63. ACEAction13fnc (TaskInitNR6.sqf:1204)
64. Action13fncR (TaskInitNR6.sqf:1221)
65. ACEAction13fncR (TaskInitNR6.sqf:1232)
66. ActionMfnc (TaskInitNR6.sqf:1245)       — primary string-dispatch target from SquadTaskingNR6:33
67. ACEActionMfnc (TaskInitNR6.sqf:1262)    — primary string-dispatch target from SquadTaskingNR6:39
68. ActionMfncR (TaskInitNR6.sqf:1279)      — primary string-dispatch target from SquadTaskingNR6:50
69. ACEActionMfncR (TaskInitNR6.sqf:1290)   — primary string-dispatch target from SquadTaskingNR6:55
70. ActionGTct (TaskInitNR6.sqf:1300)
71. ActionArtct (TaskInitNR6.sqf:1393)
72. ActionArt2ct (TaskInitNR6.sqf:1583)

### Caller tier (depends on all 72 above being PREP'd first):

73. SquadTaskingNR6 loop (SquadTaskingNR6.sqf:1)  — imperative dispatch loop; remoteExecCall to all ActionX* symbols

---

## Cycles Detected

None. The dependency graph for active functions is a DAG. The closest thing to a cycle is the `RYD_ExecutePath → RYD_ExecuteObj` relationship (ExecutePath value-passes ExecuteObj to RYD_Spawn, while ExecuteObj's notes mention self-reference via Boss_fnc.sqf:1290–1293) — but this is an intra-Boss_fnc.sqf value-pass pattern where ExecutePath dispatches ExecuteObj as a spawned function, not a direct call cycle. The topological ordering `RYD_ExecuteObj` before `RYD_ExecutePath` is correct and cycle-free.
