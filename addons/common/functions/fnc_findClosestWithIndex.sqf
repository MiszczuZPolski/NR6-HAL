#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_FindClosestWithIndex) — extracted during Phase 3 gap closure for fnc_distOrd dependency

/**
 * @description Returns [closestObject, index] from an array of objects/groups relative to a point. Handles groups by substituting vehicle of leader for the distance check.
 * @param {Array} _point World position [x,y,z] or object
 * @param {Array} _array Array of objects/groups to search
 * @return {Array} [closestObject, index] — or [objNull, 0] if array is empty
 */
params ["_point", "_array"];

private _filtered = _array - [0];

private _closest = objNull;
private _clIndex = 0;

if ((count _filtered) > 0) then {
    _closest = _filtered select 0;
    private _clst = _closest;
    if ((typeName _clst) == (typeName grpNull)) then {_clst = vehicle (leader _clst)};
    private _index = 0;
    _clIndex = 0;
    private _dstMin = _point distance _clst;

    {
        private _act = _x;
        if ((typeName _act) == (typeName grpNull)) then {_act = vehicle (leader _act)};
        private _dstAct = _point distance _act;

        if (_dstAct < _dstMin) then {
            _closest = _x;
            _dstMin = _dstAct;
            _clIndex = _index;
        };

        _index = _index + 1;
    } forEach _filtered;
};

[_closest, _clIndex]
