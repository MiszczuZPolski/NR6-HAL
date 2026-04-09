#include "..\script_component.hpp"

params ["_pos", "_level", ["_cam", objNull], ["_target", objNull]];

_pos params ["_pX", "_pY"];

private _pZ = (_pos select 2) + 1;

private _pos1 = [_pX, _pY, _pZ];
private _pos2 = [_pX, _pY, _pZ + _level];

private _roofed = lineIntersects [_pos1, _pos2, _cam, _target];

_roofed
