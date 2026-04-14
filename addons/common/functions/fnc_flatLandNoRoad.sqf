#include "..\script_component.hpp"

private ["_pos","_radius","_final","_isGood","_isFlat","_noRoad","_nearestRoad","_ct"];

params ["_pos","_radius"];

private _final = +_pos;

private _isGood = true;

private _isFlat = _pos isFlatEmpty [5, _radius/2, 2, 5, 0, false, objNull];
if ((count _isFlat) <= 1) then {
    _isGood = false
} else {
    private _noRoad = true;
    private _nearestRoad = [_pos, 20] call FUNC(nearestRoad);
    if (!(isNull _nearestRoad) || (isOnRoad _pos)) then {
        _isGood = false;
    };
};

private _ct = 0;
while {!(_isGood)} do {
    _ct = _ct + 1;
    if (_ct > 30) exitWith {};
    _pos = [_pos, _radius] call FUNC(randomAround);

    _isGood = true;

    _isFlat = _pos isFlatEmpty [5, _radius/2, 2, 5, 0, false, objNull];
    if ((count _isFlat) <= 1) then {
        _isGood = false
    } else {
        _noRoad = true;
        _nearestRoad = [_pos,20] call FUNC(nearestRoad);
        if (!(isNull _nearestRoad) || (isOnRoad _pos)) then {
            _isGood = false;
        };
    };
};

if (_isGood) then {_final = _pos};

_final
