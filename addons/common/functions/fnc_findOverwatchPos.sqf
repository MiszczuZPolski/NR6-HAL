#include "..\script_component.hpp"

private ["_pos","_tgtPos","_radius","_dir","_posASL","_tgtPosASL","_pool","_posX","_posY","_posX2","_posY2","_pool2","_isBlock","_pool3","_elevImp","_terrImp","_terr","_elev","_final","_value",
	"_urban","_forest","_group","_dst","_vehicle"];


params ["_pos", "_tgtPos", "_radius", "_elevImp", "_terrImp", "_group"];

_tgtPos = [_tgtPos select 0,_tgtPos select 1, 1.5];

private _vehicle = vehicle (leader _group);

private _tgtPosASL = [_tgtPos select 0, _tgtPos select 1, getTerrainHeightASL [_tgtPos select 0, _tgtPos select 1] + 1.5];

private _pool = [];

private _randomizedPosition = [_pos, _radius] call CBA_fnc_randPos;
_randomizedPosition params ["_posX", "_posY"];

if !(surfaceIsWater [_posX, _posY]) then {_pool pushBack [_posX, _posY, 1]};

private _pool2 = [];
private _isBlock = false;

{
	_isBlock = terrainIntersect [_x, _tgtPos];
	if !(_isBlock) then {
		_pool2 pushBack _x;
	};
} forEach _pool;

if (_pool2 isEqualTo []) then {_pool2 = _pool};

private _pool3 = [];

{
	_isBlock = lineIntersects [[_x select 0, _x select 1, getTerrainHeightASL [_x select 0, _x select 1] + 1], _tgtPosASL];
	if !(_isBlock) then {
		_pool3 pushBack _x;
	};
} forEach _pool2;

if (_pool3 isEqualTo []) then {_pool3 = _pool2};

{
	_value = [_x, 1, 1] call FUNC(terraCognita);
	_urban = _value select 0;
	_forest = _value select 1;

	_terr = (_urban + _forest) * 100;

	_posX = _x select 0;
	_posY = _x select 1;
	_elev = getTerrainHeightASL [_posX,_posY];
	_dst = 0;
	if !(isNull _group) then {
		_dst = ([_posX,_posY] distance _vehicle)/1000;
	};

	_x pushBack ((_terr * _terrImp) + (_elev * _elevImp))/(1 + _dst);
} forEach _pool3;

_pool3 = [_pool3] call FUNC(valueOrd);

_final = [];

{
	_final pushBack [_x select 0, _x select 1];
} forEach _pool3;

_final
