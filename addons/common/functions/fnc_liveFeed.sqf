#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_LiveFeed)

params ["_unit","_HQ"];

_unit addAction ["Enable cam view", (RYD_Path + "LF\LF.sqf"),[_HQ], -71, false, true, "", "(!RydxHQ_LFActive) and (_this == _target)"];
_unit addAction ["Disable cam view", (RYD_Path + "LF\LF.sqf"),[_HQ], -81, false, true, "", "(RydxHQ_LFActive) and (_this == _target)"];
