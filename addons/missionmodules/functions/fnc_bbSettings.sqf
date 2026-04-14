#include "..\script_component.hpp"
params ["_logic"];

// Editor module overrides CBA setting; CBA setting is the fallback default.
// HC settings are registered as missionmodules-local CBA settings in
// addons/core/initSettings.inc.sqf (QEGVAR(missionmodules,*)).

GVAR(customObjOnly) = _logic getVariable [QGVAR(customObjOnly), GVAR(customObjOnly)];
GVAR(lRelocating)   = _logic getVariable [QGVAR(lRelocating),   GVAR(lRelocating)];
GVAR(mainInterval)  = _logic getVariable [QGVAR(mainInterval),  GVAR(mainInterval)];
//RydBB_BBOnMap = (_logic getVariable "RydBB_BBOnMap");
