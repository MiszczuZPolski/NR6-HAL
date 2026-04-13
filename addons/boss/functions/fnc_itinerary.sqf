#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:629 (RYD_Itinerary)
/**
 * @description Determines sectors and target objectives along an advance route between two positions
 * @param {Array} _sectors Array of sector location objects
 * @param {Array} _targets Array of strategic target areas
 * @param {Array} _pos1 Start position (HQ position)
 * @param {Array} _pos2 Target position
 * @param {String} _side Side identifier ("A" or "B")
 * @return {Array} [sectorsInBound, targetsInBound, infFactor, vehFactor]
 */
params ["_sectors","_targets","_pos1","_pos2","_side"];

private _bound = createLocation ["Name", _pos1, 1, 1];
_bound setRectangular true;

[_bound,_pos1,_pos2,120000] call FUNC(locLineTransform);

private _secIn = [];
private _tgtIn = [];

{
    if ((position _x) in _bound) then {_secIn pushBack _x}
} forEach _sectors;

{
    if ((_x select 0) in _bound) then
        {
        private _cSum = 0;

        {
            _cSum = _cSum + _x
        } forEach (_x select 0);

        private _varName = "HandledAreas" + _side;

        private _HandledArray = missionNamespace getVariable _varName;

        if (isNil "_HandledArray") then
            {
            missionNamespace setVariable [_varName,[]];
            _HandledArray = missionNamespace getVariable _varName
            };

        if !(_cSum in _HandledArray) then
            {
            _tgtIn pushBack _x;
            _HandledArray pushBack _cSum;
            missionNamespace setVariable [_varName,_HandledArray];
            }
        }
} forEach _targets;

deleteLocation _bound;

private _topoAn = [_secIn] call FUNC(topoAnalize);

_secIn = _topoAn select 0;

_topoAn = [_secIn] call FUNC(topoAnalize);

private _infF = _topoAn select 1;
private _vehF = _topoAn select 2;

[_secIn,_tgtIn,_infF,_vehF]
