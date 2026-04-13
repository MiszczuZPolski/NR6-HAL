#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:67 (RYD_WhereIs)
/**
 * @description Determines relative position (left/flanking/behind) of a point relative to a reference axis
 * @param {Array} _point The point to classify
 * @param {Array} _rPoint Reference point (observer position)
 * @param {Number} _axis Reference axis direction in degrees
 * @return {Array} [isLeft, isFlanking, isBehind]
 */
params ["_point","_rPoint","_axis"];

private _angle = [_rPoint,_point,0] call EFUNC(common,angleTowards);

private _isLeft = false;
private _isFlanking = false;
private _isBehind = false;

if (_angle < 0) then {_angle = _angle + 360};
if (_axis < 0) then {_axis = _axis + 360};

private _diffA = _angle - _axis;

if (_diffA < 0) then {_diffA = _diffA + 360};

if (_diffA > 180) then
    {
    _isLeft = true
    };

if ((_diffA > 60) and (_diffA < 300)) then
    {
    _isFlanking = true
    };

if ((_diffA > 120) and (_diffA < 240)) then
    {
    _isBehind = true
    };

[_isLeft,_isFlanking,_isBehind]
