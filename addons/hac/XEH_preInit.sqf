#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Seed AI radio chatter sentence arrays for the hac addon.
// All GVAR(aIC_*) references in the 40+ hac go*/supp*/statusQuo* functions expand to
// hal_hac_aIC_* in the hac component context. These are read (and passed to
// fnc_AIChatter) whenever a non-player unit receives or completes an order — which is
// the golden path for every HAL mission. Without seeds, selectRandom nil crashes.
// Values from legacy nr6_hal/VarInit.sqf (RydxHQ_AIC_* arrays).
GVAR(aIC_OrdConf) = [
    "HAC_OrdConf1","HAC_OrdConf2","HAC_OrdConf3","HAC_OrdConf4","HAC_OrdConf5",
    "v2HAC_OrdConf1","v2HAC_OrdConf2","v2HAC_OrdConf3","v2HAC_OrdConf4","v2HAC_OrdConf5",
    "v3HAC_OrdConf1","v3HAC_OrdConf2","v3HAC_OrdConf3","v3HAC_OrdConf4","v3HAC_OrdConf5"
];
GVAR(aIC_OrdDen) = [
    "HAC_OrdDen1","HAC_OrdDen2","HAC_OrdDen3","HAC_OrdDen4","HAC_OrdDen5",
    "v2HAC_OrdDen1","v2HAC_OrdDen2","v2HAC_OrdDen3","v2HAC_OrdDen4","v2HAC_OrdDen5",
    "v3HAC_OrdDen1","v3HAC_OrdDen2","v3HAC_OrdDen3","v3HAC_OrdDen4","v3HAC_OrdDen5"
];
GVAR(aIC_OrdFinal) = [
    "HAC_OrdFinal1","HAC_OrdFinal2","HAC_OrdFinal3","HAC_OrdFinal4",
    "v2HAC_OrdFinal1","v2HAC_OrdFinal2","v2HAC_OrdFinal3","v2HAC_OrdFinal4",
    "v3HAC_OrdFinal1","v3HAC_OrdFinal2","v3HAC_OrdFinal3","v3HAC_OrdFinal4"
];
GVAR(aIC_OrdEnd) = [
    "HAC_OrdEnd1","HAC_OrdEnd2","HAC_OrdEnd3","HAC_OrdEnd4",
    "v2HAC_OrdEnd1","v2HAC_OrdEnd2","v2HAC_OrdEnd3","v2HAC_OrdEnd4",
    "v3HAC_OrdEnd1","v3HAC_OrdEnd2","v3HAC_OrdEnd3","v3HAC_OrdEnd4"
];
GVAR(aIC_SuppReq) = [
    "HAC_SuppReq1","HAC_SuppReq2","HAC_SuppReq3","HAC_SuppReq4","HAC_SuppReq5",
    "v2HAC_SuppReq1","v2HAC_SuppReq2","v2HAC_SuppReq3","v2HAC_SuppReq4","v2HAC_SuppReq5",
    "v3HAC_SuppReq1","v3HAC_SuppReq2","v3HAC_SuppReq3","v3HAC_SuppReq4","v3HAC_SuppReq5"
];
GVAR(aIC_SuppAss) = [
    "v2HAC_SuppAss1","v2HAC_SuppAss2","v2HAC_SuppAss3","v2HAC_SuppAss4","v2HAC_SuppAss5"
];
GVAR(aIC_SuppDen) = [
    "v2HAC_SuppDen1","v2HAC_SuppDen2","v2HAC_SuppDen3","v2HAC_SuppDen4","v2HAC_SuppDen5"
];
GVAR(aIC_MedReq) = [
    "HAC_MedReq1","HAC_MedReq2","HAC_MedReq3","HAC_MedReq4","HAC_MedReq5",
    "v2HAC_MedReq1","v2HAC_MedReq2","v2HAC_MedReq3","v2HAC_MedReq4","v2HAC_MedReq5",
    "v3HAC_MedReq1","v3HAC_MedReq2","v3HAC_MedReq3","v3HAC_MedReq4","v3HAC_MedReq5"
];
GVAR(aIC_SmokeReq) = [
    "HAC_SmokeReq1","HAC_SmokeReq2","HAC_SmokeReq3","HAC_SmokeReq4",
    "v2HAC_SmokeReq1","v2HAC_SmokeReq2","v2HAC_SmokeReq3","v2HAC_SmokeReq4",
    "v3HAC_SmokeReq1","v3HAC_SmokeReq2","v3HAC_SmokeReq3","v3HAC_SmokeReq4"
];
GVAR(aIC_InDanger) = [
    "HAC_InDanger1","HAC_InDanger2","HAC_InDanger3","HAC_InDanger4","HAC_InDanger5",
    "HAC_InDanger6","HAC_InDanger7","HAC_InDanger8","HAC_InDanger9","HAC_InDanger10",
    "HAC_InDanger11","HAC_InDanger12","HAC_InDanger13",
    "v2HAC_InDanger1","v2HAC_InDanger2","v2HAC_InDanger3","v2HAC_InDanger4","v2HAC_InDanger5",
    "v2HAC_InDanger6","v2HAC_InDanger7","v2HAC_InDanger8","v2HAC_InDanger9","v2HAC_InDanger10",
    "v2HAC_InDanger11","v2HAC_InDanger12","v2HAC_InDanger13",
    "v3HAC_InDanger1","v3HAC_InDanger2","v3HAC_InDanger3","v3HAC_InDanger4","v3HAC_InDanger5",
    "v3HAC_InDanger6","v3HAC_InDanger7","v3HAC_InDanger8","v3HAC_InDanger9","v3HAC_InDanger10",
    "v3HAC_InDanger11","v3HAC_InDanger12","v3HAC_InDanger13"
];
GVAR(aIC_EnemySpot) = [
    "HAC_EnemySpot1","HAC_EnemySpot2","HAC_EnemySpot3","HAC_EnemySpot4","HAC_EnemySpot5",
    "v2HAC_EnemySpot1","v2HAC_EnemySpot2","v2HAC_EnemySpot3","v2HAC_EnemySpot4","v2HAC_EnemySpot5",
    "v3HAC_EnemySpot1","v3HAC_EnemySpot2","v3HAC_EnemySpot3","v3HAC_EnemySpot4","v3HAC_EnemySpot5"
];
GVAR(aIC_InFear) = [
    "HAC_InFear1","HAC_InFear2","HAC_InFear3","HAC_InFear4",
    "HAC_InFear5","HAC_InFear6","HAC_InFear7","HAC_InFear8",
    "v2HAC_InFear1","v2HAC_InFear2","v2HAC_InFear3","v2HAC_InFear4",
    "v2HAC_InFear5","v2HAC_InFear6","v2HAC_InFear7","v2HAC_InFear8",
    "v3HAC_InFear1","v3HAC_InFear2","v3HAC_InFear3","v3HAC_InFear4",
    "v3HAC_InFear5","v3HAC_InFear6","v3HAC_InFear7","v3HAC_InFear8"
];
GVAR(aIC_InPanic) = [
    "HAC_InPanic1","HAC_InPanic2","HAC_InPanic3","HAC_InPanic4",
    "HAC_InPanic5","HAC_InPanic6","HAC_InPanic7","HAC_InPanic8",
    "v2HAC_InPanic1","v2HAC_InPanic2","v2HAC_InPanic3","v2HAC_InPanic4",
    "v2HAC_InPanic5","v2HAC_InPanic6","v2HAC_InPanic7","v2HAC_InPanic8",
    "v3HAC_InPanic1","v3HAC_InPanic2","v3HAC_InPanic3","v3HAC_InPanic4",
    "v3HAC_InPanic5","v3HAC_InPanic6","v3HAC_InPanic7","v3HAC_InPanic8"
];
GVAR(aIC_DefStance) = ["v2HAC_DefStance1"];
GVAR(aIC_OffStance) = ["v2HAC_OffStance1"];

// Seed mARatio — minimum attacker ratio thresholds for the dispatcher.
// Five elements: [inf, armor, air, sniper, naval]. Value -1 means "skip ratio
// check" (the dispatcher code does `if (_x >= 0) then {...}`).
// Legacy source: nr6_hal/VarInit.sqf line 163 — RydxHQ_MARatio = [-1,-1,-1,-1,-1]
if (isNil QGVAR(mARatio)) then { GVAR(mARatio) = [-1,-1,-1,-1,-1] };

ADDON = true;
