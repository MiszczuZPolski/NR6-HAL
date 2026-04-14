#include "..\script_component.hpp"

params ["_units"];

{
    _x addAction ["Time: x2", (EGVAR(core,path) + "TimeM\TimeFaster.sqf"), "", -50, false, true, "", "(_this == _target)"];
    _x addAction ["Time: x0.5", (EGVAR(core,path) + "TimeM\TimeSlower.sqf"), "", -60, false, true, "", "(_this == _target)"];
    _x addAction ["Order pause enabled", (EGVAR(core,path) + "TimeM\EnOP.sqf"), "", -70, false, true, "", "(not RydHQ_GPauseActive) and (_this == _target)"];
    _x addAction ["Order pause disabled", (EGVAR(core,path) + "TimeM\DisOP.sqf"), "", -80, false, true, "", "RydHQ_GPauseActive and (_this == _target)"];
} forEach _units;
