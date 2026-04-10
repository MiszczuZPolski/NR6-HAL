#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:175 (RYD_Sectorize)
/**
 * @description Divides a square area into a grid of rectangular sector locations
 * @param {Array} _ctr Center position of the area
 * @param {Number} _lng Length of the area (map edge)
 * @param {Number} _ang Rotation angle for the grid
 * @param {Number} _nbr Number of sectors per side
 * @return {Array} [sectors array, main location object]
 */
params ["_ctr","_lng","_ang","_nbr"];

private _EdgeL = _lng/_nbr;

private _rd = _lng/2;

private _main = createLocation ["Name", _ctr, _rd, _rd];
_main setRectangular true;

private _step = _EdgeL;

private _X1 = _ctr select 0;
private _Y1 = _ctr select 1;

private _posX = (_X1 - _rd) + _step/2;
private _posY = (_Y1 - _rd) + _step/2;

private _centers = [[_posX,_posY]];
private _first = false;

while {(true)} do
    {
    while {(true)} do
        {
        if !(_first) then {_first = true;_posX = _posX + _step};
        if !([_posX,_PosY] in _main) exitWith {_posX = ((_ctr select 0) - _rd) + _step/2;_first = true};
        _centers pushBack [_posX,_PosY];
        _first = false
        };
    _posY = _posY + _step;
    if !([_posX,_PosY] in _main) exitWith {}
    };

if !(_ang in [0,90,180,270]) then
    {
    _main setDirection _ang;
    private _centers2 = +_centers;
    _centers = [];

    {
        private _Xa = _x select 0;
        private _Ya = _x select 1;
        private _dXa = (_X1 - _Xa);
        private _dYa = (_Y1 - _Ya);
        private _dst = _ctr distance _x;

        private _ang2 = _ang + (_dXa atan2 _dYa);

        private _dXb = _dst * (sin _ang2);
        private _dYb = _dst * (cos _ang2);

        private _Xb = _X1 + _dXb;
        private _Yb = _Y1 + _dYb;
        private _center = [_Xb,_Yb];
        _centers pushBack _center
    } forEach _centers2
    };

private _sectors = [];

{
    private _crX = _x select 0;
    private _crY = _x select 1;
    private _crPoint = [_crX,_crY,0];
    private _sec = createLocation ["Name", _crPoint, _EdgeL/2, _EdgeL/2];
    _sec setDirection _ang;
    _sec setRectangular true;

    _sectors pushBack _sec;
} forEach _centers;

[_sectors,_main]
