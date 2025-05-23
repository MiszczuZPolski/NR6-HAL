#include "..\script_component.hpp"

private ["_battery","_pos","_ammo","_amount","_guns","_vh","_mags","_amount0","_eta","_alive","_available","_perGun","_rest","_aGuns","_perGun1","_shots","_toFire","_rest0","_bad","_ammoC","_ws","_code"];

	_battery = _this select 0;
	_pos = _this select 1;
	_ammo = _this select 2;
	_amount = _this select 3;

	_eta = -1;

	_guns = [];

		{
		if not (isNull _x) then
			{
				{
				_vh = vehicle _x;
				if not (_vh in _guns) then
					{
					_shots = 0;

						{
						if ((_x select 0) in _ammo) then
							{
							_shots = _shots + (_x select 1)
							}
						}
					forEach (magazinesAmmo _vh);

					_vh setVariable ["RydHQ_ShotsToFire",0];
					_vh setVariable ["RydHQ_MyShots",_shots];

					if (_shots > 0) then
						{
						_guns pushBack _vh
						}
					}
				}
			forEach (units _x)
			}
		}
	forEach _battery;

	_aGuns = count _guns;

	if (_aGuns < 1) exitWith {-1};
	if (_amount < 1) exitWith {-1};

	_perGun = floor (_amount/_aGuns);
	_rest = _amount - (_perGun * _aGuns);

		{
		_shots = _x getVariable ["RydHQ_MyShots",0];
		if not (_shots > _perGun) then
			{
			_x setVariable ["RydHQ_ShotsToFire",_shots];
			_amount = _amount - _shots;
			_rest = _rest + (_perGun - _shots);
			_x setVariable ["RydHQ_MyShots",0]
			}
		else
			{
			_x setVariable ["RydHQ_ShotsToFire",_perGun];
			_x setVariable ["RydHQ_MyShots",_shots - _perGun]
			};
		}
	forEach _guns;

	_bad = false;

	while {(_rest > 0)} do
		{
		_rest0 = _rest;

			{
			if (_rest < 1) exitWith {};
			_shots = _x getVariable ["RydHQ_MyShots",0];

			if (_shots > 0) then
				{
				_toFire = _x getVariable ["RydHQ_ShotsToFire",0];

				_rest = _rest - 1;

				_x setVariable ["RydHQ_ShotsToFire",_toFire + 1];
				_x setVariable ["RydHQ_MyShots",_shots - 1]
				}
			}
		forEach _guns;

		if (not (_rest0 > _rest) and (_rest > 0)) exitWith {_bad = true}
		};

	if (_bad) exitWith {-1};

	_code =
		{
		_SCRname = "ArtyFiring";

		_vh = _this select 0;
		_pos = _this select 1;
		_ammo = _this select 2;

		if (_pos inRangeOfArtillery [[_vh],_ammo]) then
			{
			if (_ammo in (getArtilleryAmmo [_vh])) then
				{
				_vh setVariable ["RydHQ_GunFree",false];

				if not ((currentMagazine _vh) in [_ammo]) then
					{
					_vh loadMagazine [[0],currentWeapon _vh,_ammo];

					_ct = time;

					waitUntil
						{
						sleep 0.1;
						_ws = weaponState [_vh,[0]];
						_ws = _ws select 3;
						((_ws in [_ammo]) or ((time - _ct) > 30))
						};

					sleep ((getNumber (configFile >> "cfgWeapons" >> (currentWeapon _vh) >> "magazineReloadTime")) + 0.1)
					};

				if (_pos inRangeOfArtillery [[_vh],_ammo]) then
					{
					if (_ammo in (getArtilleryAmmo [_vh])) then
						{
						[_vh,[_pos, _ammo,(_vh getVariable ["RydHQ_ShotsToFire",1])]] remoteExecCall ["doArtilleryFire",_vh];

						_ct = time;

						waitUntil
							{
							sleep 0.1;
							(not ((_vh getVariable ["RydHQ_ShotFired2",0]) < (_vh getVariable ["RydHQ_ShotsToFire",1])) or ((time - _ct) > 15))
							};

						_vh setVariable ["RydHQ_ShotFired",true];
						_vh setVariable ["RydHQ_ShotFired2",0];
						}
					};

				sleep ((getNumber (configFile >> "cfgWeapons" >> (currentWeapon _vh) >> "reloadTime")) + 0.5);

				_vh setVariable ["RydHQ_GunFree",true]
				}
			}
		};

		{
		switch (true) do
			{
			case (isNil {_x}) : {_guns set [_foreachIndex,objNull]};
			case (isNull _x) : {_guns set [_foreachIndex,objNull]};
			case not (alive _x) : {_guns set [_foreachIndex,objNull]};
			}
		}
	forEach _guns;

	_guns = _guns - [objNull];

	if ((count _guns) < 1) exitWith {-1};

		{
		if not (isNull _x) then
			{
			_vh = vehicle _x;

			if ((_vh getVariable ["RydHQ_ShotsToFire",0]) > 0) then
				{
				_mags = getArtilleryAmmo [_vh];

				_ammoC = (magazines _vh) select 0;

					{
					if (_x in _ammo) exitWith
						{
						_ammoC = _x
						}
					}
				forEach (magazines _vh);

				if (_ammoC in _mags) then
					{
					_amount = _amount - 1;

					_newEta = _vh getArtilleryETA [_pos,_ammoC];

					if (isNil "_newEta") then {_newEta = -1};

					if ((_newEta < _eta) or (_eta < 0)) then
						{
						_eta = _newEta
						};

					[[_vh,_pos,_ammoC],_code] call RYD_Spawn
					}
				}
			}
		}
	forEach _guns;

		/*{
		if not (isNull _x) then
			{
				{
				(vehicle _x) setVariable ["RydHQ_GunFree",true]
				}
			foreach (units _x)
			}
		}
	foreach _battery;*/

	_eta