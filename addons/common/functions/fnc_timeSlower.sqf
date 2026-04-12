#include "..\script_component.hpp"
// Originally from nr6_hal/TimeM/TimeSlower.sqf

private _acc = accTime;

setAccTime (_acc * 0.5);

player globalChat format ["New time acceleration: %1", _acc * 0.5];
