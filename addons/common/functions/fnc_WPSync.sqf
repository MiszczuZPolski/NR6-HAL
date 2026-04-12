#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_WPSync)

params ["_waypoint", "_unit", "_group"];

// NOTE: Phase 3-06 — these variables (_i, _unitG, _HQ) were already undeclared in the
// legacy RYD_WPSync body and this function has no active callers in addons/. Declared
// here as private to silence L-S13 without altering the (dormant) code path. Full rewrite
// deferred to a future phase when an actual caller is wired up.
private _i = "";
private _unitG = grpNull;
private _HQ = grpNull;

private _trg = group _unit;

if (isNull _trg) exitWith {};

private _otherWP = _trg getVariable [QGVAR(attacks), []];

private _gps = [];
private _positions = [];

{
    _gps pushBack (_x select 0);
    _positions pushBack (_x select 1);
} forEach _otherWP;

private _markT = markerText _i;

private _timer = CBA_missionTime;
private _endThis = false;

waitUntil {
    sleep 5;

    switch (true) do {
        case (isNull _group): {_endThis = true};
        case ((({alive _x} count (units _group)) < 1)): {_endThis = true};
        case (_unitG getVariable ["Break",false]) : {_endThis = true; _unitG setVariable ["Break",false];};
        case ((_group getVariable [("Resting" + (str _group)),false]) or {(_group getVariable [QGVAR(mIA),false])}): {_endThis = true};
        case ((fleeing (leader _group)) or {(captive (leader _group))}): {_endThis = true};
    };

    if !(_endThis) then {
        _endThis = true;
        private _pos = [0,0,0];
        private _uPos = [0,0,0];


        {
            _pos = _positions select _foreachIndex;
            _uPos = position (vehicle (leader _x));

            if (((_pos distance2D _uPos) > 40) and {(_pos isNotEqualTo [0,0,0])}) exitWith {_endThis = false};
        } forEach _gps;
    };

    if (_HQ getVariable [QGVAR(debug),false]) then {
        _i setMarkerText (_markT + "sync: " + (str (round (time - _timer))))
    };

    ((_endThis) || {(time - _timer) > 1800})
};

if (_HQ getVariable [QGVAR(debug),false]) then {
    _i setMarkerText _markT;
};

_trg setVariable [QGVAR(attacks),[]];
