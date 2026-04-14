#include "..\script_component.hpp"
// Originally from nr6_hal/TimeM/TimeFaster.sqf

private _acc = accTime;

setAccTime (_acc * 2);

player globalChat format ["New time acceleration: %1", _acc * 2];
