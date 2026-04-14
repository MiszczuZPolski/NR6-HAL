#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Seed AI radio chatter sentence arrays for the boss addon.
// GVAR(aIC_OrdConf) (= hal_boss_aIC_OrdConf) is the order-confirmation pool used by
// fnc_reserveExecuting (boss context). EGVAR(boss,aIC_OrdConf) is the same variable
// and is also read by hac fnc_garrison, fnc_goAtt*, fnc_goCapture*, fnc_goDef*,
// fnc_goRecon, fnc_sCargo — every time a non-player unit receives an order.
// Without this seed selectRandom nil crashes on the first AI chatter attempt.
// Values from legacy nr6_hal/VarInit.sqf (RydxHQ_AIC_OrdConf).
GVAR(aIC_OrdConf) = [
    "HAC_OrdConf1","HAC_OrdConf2","HAC_OrdConf3","HAC_OrdConf4","HAC_OrdConf5",
    "v2HAC_OrdConf1","v2HAC_OrdConf2","v2HAC_OrdConf3","v2HAC_OrdConf4","v2HAC_OrdConf5",
    "v3HAC_OrdConf1","v3HAC_OrdConf2","v3HAC_OrdConf3","v3HAC_OrdConf4","v3HAC_OrdConf5"
];

ADDON = true;
