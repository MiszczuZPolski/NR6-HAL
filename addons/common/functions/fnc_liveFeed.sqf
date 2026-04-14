#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_LiveFeed)

params ["_unit","_HQ"];

_unit addAction ["Enable cam view", (EGVAR(core,path) + "LF\LF.sqf"),[_HQ], -71, false, true, "", "(!hal_common_lFActive) and (_this == _target)"];
_unit addAction ["Disable cam view", (EGVAR(core,path) + "LF\LF.sqf"),[_HQ], -81, false, true, "", "(hal_common_lFActive) and (_this == _target)"];
