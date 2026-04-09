#include "..\script_component.hpp"

params ["_pos"];

private _posX = -1;
private _posY = -1;
private _radius = 50;

private _lz = objNull;

private _isFlat = [];

while {_radius <= 400} do {
    _isFlat = _pos isFlatEmpty [20, _radius, 1, 15, 0, false, objNull];

    if ((count _isFlat) > 1) exitWith {
        _posX = _isFlat select 0;
        _posY = _isFlat select 1;
    };

    _radius = _radius + 50;
};

if (_posX > 0) then {
    _lz = createVehicle ["Land_HelipadEmpty_F", [_posX, _posY, 0], [], 0, "NONE"];
    //_i01 = [[_posX,_posY],str (random 100),"markLZ","ColorRed","ICON","mil_dot","LZ",""] call RYD_Mark
};

_lz
