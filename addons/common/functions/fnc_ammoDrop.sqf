#include "..\script_component.hpp"

params ["_cargo","_ammoBox","_benef"];

private _type = typeOf _ammoBox;

private _dir = getDir _cargo;

private _backLimit = (((boundingBoxReal _cargo) select 0) select 1);

private _parachutePos = _cargo modelToWorld [0, (_backLimit - 2), -2];

private _parachute = createVehicle ["B_Parachute_02_F", [_parachutePos select 0, _parachutePos select 1, 2000], [], 0.5, "NONE"];
_parachute setPos _parachutePos;
_parachute setDir _dir;

private _vel = velocity _cargo;

_parachute setVelocity [(_vel select 0)/2,(_vel select 1)/2,(_vel select 2)/2];

_ammoBox setDir _dir;

_ammoBox attachTo [_parachute,[0,0,0]];

_ammoBox enableSimulationGlobal true;
_ammoBox hideObjectGlobal false;

sleep 2;

waitUntil {
    private _height1 = (getPosATL _ammoBox) select 2;
    sleep 0.005;
    private _height2 = (getPosATL _ammoBox) select 2;
    private _speed = abs ((velocity _ammoBox) select 2);
    if (_height2 > _height1) then {_parachute setVelocity [0, 0, -20]};
    sleep 0.005;
    private _height3 = (getPosATL _ammoBox) select 2;

    ((_height2 < 0.05) or {(_height2 < 2) and {(_height3 > _height2) or {(_speed < 0.001) or {(isNull _parachute)}}}})
};

detach _ammoBox;

private _pos = getPosATL _ammoBox;

//deleteVehicle _ammoBox;

//_ammoBox = createVehicle [_type, _pos, [], 0, "NONE"];

private _off = _ammoBox modelToWorld [0,0,0] select 2;
if (_off < 2) then {
    _ammoBox setPos [_pos select 0,_pos select 1,0];
} else {
    _off = getPos _ammoBox select 2;
    _ammoBox setPosATL [_pos select 0,_pos select 1,(_pos select 2)-_off];
};

_benef setVariable ["isBoxed", _ammoBox];

if !(isNull _parachute) then {
    _parachute setVelocity [0,0,0]
};

sleep 5;

if !(isNull _parachute) then {
    deleteVehicle _parachute
};
