#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(handles) = [];

// Seed allArty as empty array so fnc_cff_tgt.sqf can read GVAR(allArty) safely.
// fnc_varInit.sqf (core) populates this with the full combined arty classname list
// at mission start. fnc_presentRHQ.sqf also pushBackUnique custom arty into it.
GVAR(allArty) = [];

// Seed per-HQ debug flags. EGVAR(common,debug) is registered as a CBA setting
// (default false) in core/initSettings.inc.sqf. debugB..H are not CBA settings —
// they are seeded here so fnc_init.sqf:183 can read them unconditionally before
// any HQSitRep function runs (which has its own lazy nil-guard but fires later).
GVAR(debugB) = false;
GVAR(debugC) = false;
GVAR(debugD) = false;
GVAR(debugE) = false;
GVAR(debugF) = false;
GVAR(debugG) = false;
GVAR(debugH) = false;

// Seed AI radio chatter sentence arrays for the common addon.
// GVAR(aIC_ArtyReq/ArtAss/ArtDen/ArtFire) are read by fnc_cff.sqf and fnc_cff_ffe.sqf
// whenever artillery is requested or fired. GVAR(aIC_OrdDen) is read by
// fnc_action1ct.sqf (tasking) when an order is denied. GVAR(aIC_IllumReq) has a
// safe getVariable fallback in fnc_flares.sqf so it is not seeded here.
// Values from legacy nr6_hal/VarInit.sqf.
GVAR(aIC_OrdDen) = [
    "HAC_OrdDen1","HAC_OrdDen2","HAC_OrdDen3","HAC_OrdDen4","HAC_OrdDen5",
    "v2HAC_OrdDen1","v2HAC_OrdDen2","v2HAC_OrdDen3","v2HAC_OrdDen4","v2HAC_OrdDen5",
    "v3HAC_OrdDen1","v3HAC_OrdDen2","v3HAC_OrdDen3","v3HAC_OrdDen4","v3HAC_OrdDen5"
];
GVAR(aIC_ArtyReq) = [
    "HAC_ArtyReq1","HAC_ArtyReq2","HAC_ArtyReq3","HAC_ArtyReq4","HAC_ArtyReq5",
    "v2HAC_ArtyReq1","v2HAC_ArtyReq2","v2HAC_ArtyReq3","v2HAC_ArtyReq4","v2HAC_ArtyReq5",
    "v3HAC_ArtyReq1","v3HAC_ArtyReq2","v3HAC_ArtyReq3","v3HAC_ArtyReq4","v3HAC_ArtyReq5"
];
GVAR(aIC_ArtAss) = [
    "v2HAC_ArtAss1","v2HAC_ArtAss2","v2HAC_ArtAss3","v2HAC_ArtAss4","v2HAC_ArtAss5"
];
GVAR(aIC_ArtDen) = [
    "v2HAC_ArtDen1","v2HAC_ArtDen2","v2HAC_ArtDen3","v2HAC_ArtDen4","v2HAC_ArtDen5"
];
GVAR(aIC_ArtFire) = [
    "HAC_ArtFire1","HAC_ArtFire2","HAC_ArtFire3","HAC_ArtFire4","HAC_ArtFire5"
];

// gPauseActive tracks whether the order-pause feature is active. fnc_TimeMachine.sqf
// registers it as an addAction condition string; fnc_timeEnOP/fnc_timeDisOP write it.
// The compat alias RydHQ_GPauseActive = EGVAR(common,gPauseActive) is copied at postInit,
// so the alias would capture nil unless we seed false here first.
GVAR(gPauseActive) = false;

ADDON = true;
