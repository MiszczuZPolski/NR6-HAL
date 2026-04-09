#include "..\script_component.hpp"

params ["_group"];


private _allUnits = units _group;

{
    private _unit = _x;
    private _pos = getPosATL _unit;

    _pos params ["_posX","_posY"];

    _posX = _posX + (random 0.25) - 0.125;
    _posY = _posY + (random 0.25) - 0.125;

    _unit setPos [_posX, _posY, 1];

    sleep 0.05;

    _unit doMove [_posX, _posY, 0];

    sleep 0.05;

    _unit setDir (getDir player);

    sleep 0.05;

    _unit forceSpeed -1;

    sleep 0.05;

    if (weapons _unit isNotEqualTo []) then {

        private _type = (weapons _unit) select 0;
        private _muzzles = getArray (configFile >> "cfgWeapons" >> _type >> "muzzles");

        if (count _muzzles > 1) then {
            _unit selectWeapon (_muzzles select 0);
        } else {
            _unit selectWeapon _type
        };
    };
} forEach _allUnits;

sleep 0.5;

{
    _x doWatch objNull;
    sleep 0.05;
    _x doTarget objNull;
    sleep 0.05;
    _x enableReload false;
    sleep 0.05;
    _x stop true;
    sleep 0.05;
    _x setUnitPos "UP";
    sleep 0.05
} forEach _allUnits;

sleep 0.5;

{
    _x switchMove "";
    sleep 0.05;
    _x disableAI "TARGET";
    sleep 0.05;
    _x disableAI "AUTOTARGET";
    sleep 0.05;
    _x disableAI "MOVE";
    sleep 0.05;
    _x disableAI "FSM";
    sleep 0.05;
    _x disableAI "ANIM";
    sleep 0.05
} forEach _allUnits;

sleep 5;

{
    _x setUnitPos "AUTO";
    sleep 0.05;
    _x enableAI "TARGET";
    sleep 0.05;
    _x enableAI "AUTOTARGET";
    sleep 0.05;
    _x enableAI "MOVE";
    sleep 0.05;
    _x enableAI "FSM";
    sleep 0.05;
    _x enableAI "ANIM";
    sleep 0.05;
    _x stop false;
    sleep 0.05;
    _x enableReload true;
    sleep 0.05
} forEach _allUnits;
