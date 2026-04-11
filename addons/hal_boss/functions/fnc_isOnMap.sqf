#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1952 (RYD_isOnMap)
/**
 * @description Checks if a position is within the Big Boss battle map boundaries
 * @param {Array} _pos Position to check [x,y] or [x,y,z]
 * @return {Boolean} True if position is within map boundaries
 */
params ["_pos"];

private _onMap = true;

private _pX = _pos select 0;
private _pY = _pos select 1;

private _mapMinX = 0;
private _mapMinY = 0;

if !(isNil QEGVAR(missionmodules,mC)) then
    {
    _mapMinX = EGVAR(missionmodules,mapXMin);
    _mapMinY = EGVAR(missionmodules,mapYMin)
    };

if (_pX < _mapMinX) then
    {
    _onMap = false
    }
else
    {
    if (_pY < _mapMinY) then
        {
        _onMap = false
        }
    else
        {
        if (_pX > EGVAR(missionmodules,mapXMax)) then
            {
            _onMap = false
            }
        else
            {
            if (_pY > EGVAR(missionmodules,mapYMax)) then
                {
                _onMap = false
                }
            }
        }
    };

_onMap
