#include "..\script_component.hpp"
// RYD_CFF_FIRE

params ["_battery","_pos","_ammo","_amount"];

private ["_mags","_amount0","_alive","_available","_perGun1","_ammoC","_ws"];

private _eta = -1;

private _guns = [];

{
	if !(isNull _x) then {
		{
			private _vehicle = vehicle _x;
			if !(_vehicle in _guns) then {
				private _shots = 0;

				{
					if ((_x select 0) in _ammo) then {
						_shots = _shots + (_x select 1)
					};
				} forEach (magazinesAmmo _vehicle);

				_vehicle setVariable [QGVAR(shotsToFire), 0];
				_vehicle setVariable [QGVAR(myShots), _shots];

				if (_shots > 0) then {
					_guns pushBack _vehicle;
				};
			};
		} forEach (units _x)
	};
} forEach _battery;

private _aGuns = count _guns;

if (_aGuns < 1) exitWith {-1};
if (_amount < 1) exitWith {-1};

private _perGun = floor (_amount/_aGuns);
private _rest = _amount - (_perGun * _aGuns);

{
	_shots = _x getVariable [QGVAR(myShots), 0];
	if (_shots <= _perGun) then {
		_x setVariable [QGVAR(shotsToFire), _shots];
		_amount = _amount - _shots;
		_rest = _rest + (_perGun - _shots);
		_x setVariable [QGVAR(myShots), 0];
	} else {
		_x setVariable [QGVAR(shotsToFire), _perGun];
		_x setVariable [QGVAR(myShots), _shots - _perGun];
	};
} forEach _guns;

private _bad = false;
private _rest0 = 0;

while {(_rest > 0)} do {
	_rest0 = _rest;

	{
		if (_rest < 1) exitWith {};
		_shots = _x getVariable [QGVAR(myShots), 0];

		if (_shots > 0) then {
			private _toFire = _x getVariable [QGVAR(shotsToFire), 0];

			_rest = _rest - 1;

			_x setVariable [QGVAR(shotsToFire), _toFire + 1];
			_x setVariable [QGVAR(myShots), _shots - 1];
		};
	} forEach _guns;

	if ((_rest < _rest0) && (_rest > 0)) exitWith {_bad = true}
};

if (_bad) exitWith {-1};

private _fnc_code = {
	params ["_vehicle","_pos","_ammo"];

	if (_pos inRangeOfArtillery [[_vehicle],_ammo]) then {
		if (_ammo in (getArtilleryAmmo [_vehicle])) then {
			_vehicle setVariable [QGVAR(gunFree), false];

			if !((currentMagazine _vehicle) in [_ammo]) then {
				_vehicle loadMagazine [[0],currentWeapon _vehicle,_ammo];

				_ct = time;

				waitUntil {
					sleep 0.1;
					_ws = weaponState [_vehicle,[0]];
					_ws = _ws select 3;
					((_ws in [_ammo]) or ((time - _ct) > 30))
				};

				sleep ((getNumber (configFile >> "cfgWeapons" >> (currentWeapon _vehicle) >> "magazineReloadTime")) + 0.1)
			};

			if (_pos inRangeOfArtillery [[_vehicle],_ammo]) then {
				if (_ammo in (getArtilleryAmmo [_vehicle])) then {
					[_vehicle, [_pos, _ammo, (_vehicle getVariable [QGVAR(shotsToFire), 1])]] remoteExecCall ["doArtilleryFire", _vehicle];

					_ct = time;

					waitUntil {
						sleep 0.1;
						((_vehicle getVariable [QGVAR(shotFired2),0]) >= (_vehicle getVariable [QGVAR(shotsToFire),1]) || ((time - _ct) > 15))
					};

					_vehicle setVariable [QGVAR(shotFired), true];
					_vehicle setVariable [QGVAR(shotFired2), 0];
				};
			};

			sleep ((getNumber (configFile >> "cfgWeapons" >> (currentWeapon _vehicle) >> "reloadTime")) + 0.5);

			_vehicle setVariable [QGVAR(gunFree),true]
		};
	};
};

{
	switch (true) do {
		case (isNil {_x}) : {_guns set [_foreachIndex, objNull]};
		case (isNull _x) : {_guns set [_foreachIndex, objNull]};
		case !(alive _x) : {_guns set [_foreachIndex, objNull]};
	};
} forEach _guns;

_guns = _guns - [objNull];

if ((count _guns) < 1) exitWith {-1};

{
	if !(isNull _x) then {
		_vehicle = vehicle _x;

		if ((_vehicle getVariable [QGVAR(shotsToFire), 0]) > 0) then {
			_mags = getArtilleryAmmo [_vehicle];

			_ammoC = (magazines _vehicle) select 0;

			{
				if (_x in _ammo) exitWith {
					_ammoC = _x
				};
			} forEach (magazines _vehicle);

			if (_ammoC in _mags) then {
				_amount = _amount - 1;

				_newEta = _vehicle getArtilleryETA [_pos, _ammoC];

				if (isNil "_newEta") then {_newEta = -1};

				if ((_newEta < _eta) or (_eta < 0)) then {
					_eta = _newEta;
				};

				[[_vehicle,_pos,_ammoC],_fnc_code] call FUNC(spawn);
			};
		};
	};
} forEach _guns;

/*{
	if !(isNull _x) then
		{
			{
			(vehicle _x) setVariable ["RydHQ_GunFree",true]
			}
		foreach (units _x)
		}
	}
foreach _battery;*/

_eta
