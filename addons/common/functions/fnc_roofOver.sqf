private ["_pos","_cam","_target","_pX","_pY","_pZ","_pos1","_pos2","_level","_roofed"];

	_pos = _this select 0;
	_level = _this select 1;

	_pX = _pos select 0;
	_pY = _pos select 1;
	_pZ = (_pos select 2) + 1;

	_pos1 = [_pX,_pY,_pZ];
	_pos2 = [_pX,_pY,_pZ + _level];

	_cam = objNull;

	if ((count _this) > 2) then {_cam = _this select 2};

	_target = objNull;

	if ((count _this) > 3) then {_target = _this select 3};

	_roofed = lineIntersects [_pos1, _pos2,_cam,_target];

	_roofed
