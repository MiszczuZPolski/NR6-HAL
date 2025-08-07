#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_isInside)

params ["_vehicle", "_pos", "_level", "_axisArr"];

_axisArr params ["_axisArr", "_marks"];

private _cam = objNull;

if ((count _this) > 5) then {_cam = _this select 5};

_target = objNull;

if ((count _this) > 6) then {_target = _this select 6};

_pos params ["_posX", "_posY", "_posZ"];

_pos1 = [_posX,_posY,_posZ];

private _roofed = false;

{
    private _axis = _x;
    private _mark = _marks select _foreachIndex;

    _pos2 = +_pos1;
    _pos2 set [_axis, (_pos2 select _axis) + (_level * _mark)];

    _roofed = lineIntersects [ATLToASL (_vehicle modelToWorld _pos1), ATLToASL (_vehicle modelToWorld _pos2), _cam, _target];

    if (_roofed) exitWith {};
} forEach _axisArr;

_roofed
