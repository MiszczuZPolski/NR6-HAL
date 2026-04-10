#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:40 (RYD_DistOrdB)
/**
 * @description Sorts an array of strategic areas by distance from a reference point, filtering by limit
 * @param {Array} _array Array of strategic area elements (each element has a position at index 0)
 * @param {Array} _point Reference point position
 * @param {Number} _limit Maximum distance limit
 * @return {Array} Filtered and distance-sorted array of areas within limit
 */
params ["_array","_point","_limit"];

private _first = [];
private _final = [];

{
    private _dst = round ((_x select 0) distance _point);
    if (_dst <= _limit) then {_first set [_dst,_x]}
} forEach _array;

{
    if !(isNil "_x") then {_final pushBack _x}
} forEach _first;

_first = nil;

_final
