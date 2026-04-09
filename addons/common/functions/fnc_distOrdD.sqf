#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_DistOrdD)

/**
 * @description Sorts an array of objects by a weighted score combining distance rank and
 *              object priority (objvalue variable). Lower score = higher priority.
 *              Score formula: (distanceRank / total * 1000) + (11 - objvalue) * 100
 * @param {Array} Array of objects/groups to sort
 * @param {Object|Array} Reference point or object
 * @param {Number} Maximum distance limit - objects beyond this are excluded
 * @return {Array} Filtered and sorted array
 */

params ["_array", "_point", "_limit"];

// Filter to objects within range
private _inRange = _array select {(_x distance _point) <= _limit};

if (_inRange isEqualTo []) exitWith { [] };

// Sort by raw distance first to get distance rank
private _byDist = [_inRange, [], { _x distance _point }, "ASCEND"] call BIS_fnc_sortBy;

// Build [score, obj] pairs — score combines distance rank and objvalue weighting
private _count = count _byDist;
private _scored = [];
{
    private _rank = _foreachIndex + 1;
    private _objVal = _x getVariable ["objvalue", 5];
    private _score = round ((_rank / _count * 1000) + ((11 - _objVal) * 100));
    _scored pushBack [_score, _x];
} forEach _byDist;

// Sort by score ascending, then extract objects
_scored sort true;
_scored apply { _x select 1 }
