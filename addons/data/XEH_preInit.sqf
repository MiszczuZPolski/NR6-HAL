#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Seed static weapon-class lookup arrays (RHQLibrary equivalent).
// fnc_presentRHQ reads GVAR(wS_Inf_class) etc. on every HQSitRep tick — they must exist
// before the first tick fires. Originally these were loaded via VarInit.sqf line 161:
//   call compile preprocessFile (RYD_Path + "RHQLibrary.sqf");
// That call was migrated to fnc_initWeaponClasses but the call site was never added here.
[] call FUNC(initWeaponClasses);

// Seed dynamic per-mission classification arrays that fnc_presentRHQ populates via
// pushBackUnique. pushBackUnique on nil is a hard error — arrays must exist as [] first.
// Mission-designer overrides are respected via the isNil guard.
if (isNil QGVAR(specFor))   then { GVAR(specFor)   = [] };
if (isNil QGVAR(recon))     then { GVAR(recon)     = [] };
if (isNil QGVAR(fO))        then { GVAR(fO)        = [] };
if (isNil QGVAR(snipers))   then { GVAR(snipers)   = [] };
if (isNil QGVAR(aTInf))     then { GVAR(aTInf)     = [] };
if (isNil QGVAR(aAInf))     then { GVAR(aAInf)     = [] };
if (isNil QGVAR(inf))       then { GVAR(inf)       = [] };
if (isNil QGVAR(art))       then { GVAR(art)       = [] };
if (isNil QGVAR(hArmor))    then { GVAR(hArmor)    = [] };
if (isNil QGVAR(mArmor))    then { GVAR(mArmor)    = [] };
if (isNil QGVAR(lArmor))    then { GVAR(lArmor)    = [] };
if (isNil QGVAR(lArmorAT))  then { GVAR(lArmorAT)  = [] };
if (isNil QGVAR(cars))      then { GVAR(cars)      = [] };
if (isNil QGVAR(air))       then { GVAR(air)       = [] };
if (isNil QGVAR(bAir))      then { GVAR(bAir)      = [] };
if (isNil QGVAR(rAir))      then { GVAR(rAir)      = [] };
if (isNil QGVAR(nCAir))     then { GVAR(nCAir)     = [] };
if (isNil QGVAR(naval))     then { GVAR(naval)     = [] };
if (isNil QGVAR(static))    then { GVAR(static)    = [] };
if (isNil QGVAR(staticAA))  then { GVAR(staticAA)  = [] };
if (isNil QGVAR(staticAT))  then { GVAR(staticAT)  = [] };
if (isNil QGVAR(support))   then { GVAR(support)   = [] };
if (isNil QGVAR(cargo))     then { GVAR(cargo)     = [] };
if (isNil QGVAR(nCCargo))   then { GVAR(nCCargo)   = [] };
if (isNil QGVAR(crew))      then { GVAR(crew)      = [] };
if (isNil QGVAR(other))     then { GVAR(other)     = [] };
if (isNil QGVAR(ammo))      then { GVAR(ammo)      = [] };
if (isNil QGVAR(fuel))      then { GVAR(fuel)      = [] };
if (isNil QGVAR(med))       then { GVAR(med)       = [] };
if (isNil QGVAR(rep))       then { GVAR(rep)       = [] };
if (isNil QGVAR(add_OtherArty)) then { GVAR(add_OtherArty) = [] };
if (isNil QGVAR(otherArty))     then { GVAR(otherArty)     = [] };

ADDON = true;
