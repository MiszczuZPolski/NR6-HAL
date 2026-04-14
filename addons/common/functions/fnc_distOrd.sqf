#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_DistOrd) — extracted during Phase 3 gap closure; distinct from distOrdB/distOrdD

/**
 * @description Greedy sort of an array of objects/groups by iterative closest-point extraction within a distance limit. Distinct from distOrdD (weighted-score sort) and distOrdB (strategic-area sort).
 * @param {Array} _array Array of objects/groups to sort — consumed (copied internally with +)
 * @param {Array} _point Reference world position
 * @param {Number} _limit Maximum distance from _point; entries beyond this are dropped
 * @return {Array} Sorted array of objects/groups, closest-first, filtered by _limit
 */
params ["_array", "_point", "_limit"];

private _arr = +_array;
private _final = [];

while {(({not ((typeName _x) in ["STRING"])} count _arr) > 0)} do {
    private _result = [_point, _arr] call FUNC(findClosestWithIndex);
    private _ix = _result select 1;
    private _closest = _result select 0;
    private _clst = _closest;
    if ((typeName _clst) == (typeName grpNull)) then {_clst = vehicle (leader _clst)};

    if ((_clst distance _point) < _limit) then {
        _final pushBack _closest;
    };

    _arr deleteAt _ix;
};

_final
