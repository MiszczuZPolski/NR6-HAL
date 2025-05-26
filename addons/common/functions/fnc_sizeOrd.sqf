private ["_array","_final","_highest","_ix"];

	_array = +(_this select 0);

	_final = [];

	while {((count _array) > 0)} do
		{
		_highest = [_array] call RYD_FindBiggest;
		_ix = _highest select 1;
		_highest = _highest select 0;

		if not (isNil "_highest") then
			{
			if not (isNull _highest) then
				{
				_final pushBack _highest;
				}
			};

		_array deleteAt _ix;
		};

	_final
