#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:259 (RYD_LocLineTransform)
/**
 * @description Transforms a location to cover a line segment between two points with padding
 * @param {Location} _loc The location object to transform
 * @param {Array} _p1 Start position (ATL)
 * @param {Array} _p2 End position (ATL)
 * @param {Number} _space Padding around the line
 * @return {Boolean} Always true
 */
params ["_loc","_p1","_p2","_space"];

private _center = [((_p1 select 0) + (_p2 select 0))/2,((_p1 select 1) + (_p2 select 1))/2,0];

private _angle = [_p1,_p2,0] call EFUNC(common,angleTowards);

private _r1 = _space;
private _r2 = (_center distance _p1) + _space;

_loc setPosition _center;
_loc setDirection _angle;
_loc setSize [_r1,_r2];

true
