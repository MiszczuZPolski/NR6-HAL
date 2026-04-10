#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:282 (RYD_LocMultiTransform)
/**
 * @description Transforms a location to cover a set of multiple points with padding, fitting all points inside
 * @param {Location} _loc The location object to transform
 * @param {Array} _ps Array of positions (ATL)
 * @param {Number} _space Padding around the points
 * @return {Boolean} Always true
 */
params ["_loc","_ps","_space"];

private _sx = 0;
private _sy = 0;

{
    _sx = _sx + (_x select 0);
    _sy = _sy + (_x select 1)
} forEach _ps;

private _cnt = count _ps;

if !(_cnt > 0) exitWith {};

private _center = [_sx/_cnt,_sy/_cnt,0];

private _pf = _ps select 0;

private _dmax = _center distance _pf;

private _indx = 0;

for "_i" from 0 to ((count _ps) - 1) do
    {
    private _check = _ps select _i;

    if (((typeName _check) == "ARRAY") and ((count _check) > 1)) then
        {
        private _cX = _check select 0;
        private _cY = _check select 1;

        _check = [_cX,_cY,0];

        private _dst = _center distance _check;
        if (_dst > _dmax) then
            {
            _pf = _check;
            _indx = _i;
            _dmax = _dst
            }
        }
    };

private _pfMain = _pf;

_ps set [_indx,"DeleteThis"];
_ps = _ps - ["DeleteThis"];

_pf = _ps select 0;

private _dmaxbis = _center distance _pf;

for "_i" from 0 to ((count _ps) - 1) do
    {
    private _check = _ps select _i;

    private _cX = _check select 0;
    private _cY = _check select 0;

    _check = [_cX,_cY,0];

    private _dst = _center distance _check;
    if (_dst > _dmaxbis) then
        {
        _dmaxbis = _dst
        }
    };

private _angle = [_center,_pfMain,0] call EFUNC(common,angleTowards);

private _r1 = _dmaxbis;
private _r2 = _dmax;

_loc setPosition _center;
_loc setDirection _angle;
_loc setSize [_r1,_r2];

private _allIn = false;

private _mpl = 10;

while {(!(_allIn) and (_mpl > 0))} do
    {
    _allIn = true;

    _r1 = _dmaxbis/_mpl;
    _loc setSize [_r1,_r2];

    {
        private _pX = _x select 0;
        private _pY = _x select 1;

        if !([_pX,_pY,0] in _loc) exitWith {_allIn = false};
    } forEach (_ps + [_pfMain]);

    _mpl = _mpl - 0.1;
    };

_allIn = false;

_mpl = 10;

while {(!(_allIn) and (_mpl > 0))} do
    {
    _allIn = true;

    _r2 = _dmax/_mpl;
    _loc setSize [_r1,_r2];

    {
        private _pX = _x select 0;
        private _pY = _x select 1;

        if !([_pX,_pY,0] in _loc) exitWith {_allIn = false};
    } forEach (_ps + [_pfMain]);

    _mpl = _mpl - 0.1;
    };

_r1 = _r1 + _space;
_r2 = _r2 + _space;

_loc setSize [_r1,_r2];

true
