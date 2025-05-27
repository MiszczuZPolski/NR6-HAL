#include "..\script_component.hpp"

private ["_array","_final","_highest","_ix"];

_array = +(_this select 0);

_final = [];

while {((count _array) > 0)} do {
	private _result = [_array] call CBA_fnc_findMax;
	_ix = _result select 1;
	_highest = _result select 0;
	_final pushBack _highest;

	_array deleteAt _ix;
};

_final
