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

if !(isNil "RydBB_MC") then
    {
    _mapMinX = RydBB_MapXMin;
    _mapMinY = RydBB_MapYMin
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
        if (_pX > RydBB_MapXMax) then
            {
            _onMap = false
            }
        else
            {
            if (_pY > RydBB_MapYMax) then
                {
                _onMap = false
                }
            }
        }
    };

_onMap
