#include "..\script_component.hpp"

private ["_array", "_final", "_highest", "_ix"];

_array = +(_this select 0);

_final = [];

while {((count _array) > 0)} do {
	_highest = [_array, 3] call FUNC(findHighestWithIndex);
	_ix = _highest select 1;
	_highest = _highest select 0;

	_final pushBack _highest;

	_array deleteAt _ix;
};

_final
