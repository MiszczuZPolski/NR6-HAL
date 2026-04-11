#include "..\script_component.hpp"
private ["_logic"];

_logic = (_this select 0);

GVAR(customObjOnly) = (_logic getVariable QGVAR(customObjOnly));
GVAR(lRelocating) = (_logic getVariable QGVAR(lRelocating));

GVAR(mainInterval) = (_logic getVariable QGVAR(mainInterval));
//RydBB_BBOnMap = (_logic getVariable "RydBB_BBOnMap");
