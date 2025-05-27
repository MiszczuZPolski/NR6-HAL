#include "..\script_component.hpp"

params ["_units"];

{
    _x addAction ["Time: x2", (RYD_Path + "TimeM\TimeFaster.sqf"), "", -50, false, true, "", "(_this == _target)"];
    _x addAction ["Time: x0.5", (RYD_Path + "TimeM\TimeSlower.sqf"), "", -60, false, true, "", "(_this == _target)"];
    _x addAction ["Order pause enabled", (RYD_Path + "TimeM\EnOP.sqf"), "", -70, false, true, "", "(not RydHQ_GPauseActive) and (_this == _target)"];
    _x addAction ["Order pause disabled", (RYD_Path + "TimeM\DisOP.sqf"), "", -80, false, true, "", "RydHQ_GPauseActive and (_this == _target)"];
} forEach _units;
