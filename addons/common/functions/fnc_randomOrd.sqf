#include "..\script_component.hpp"

private ["_array","_final","_random","_select"];

	_array = _this select 0;

	_final = [];

	while {((count _array) > 0)} do
		{
		_select = floor (random (count _array));
		_random = _array select _select;

		if not (isNil "_random") then
			{
			if ((typeName _random) in [typeName grpNull]) then
				{
				if not (isNull _random) then
					{
					if (({alive _x} count (units _random)) > 0) then
						{
						_final pushBack _random;
						}
					}
				}
			};

		_array = _array - [_random]
		};

	_final
