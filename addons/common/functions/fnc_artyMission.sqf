#include "..\script_component.hpp"
// RYD_ArtyMission

params ["_pos","_arty","_ammoG","_amount","_FO"];

private _ammo = "";
private _ammoArr = [];

private _hasAmmo = 0;
private _possible = false;
private _battery = [];
private _agp = [];

private _artyAv = [];
private _vehs = 0;
private _allAmmo = 0;

{
	private _group = _x;
	if !(isNull _group) then {
		if !(_group getVariable [QGVAR(batteryBusy), false]) then {
			_hasAmmo = 0;
			private _checked = [];

			{
				private _vehicle = vehicle _x;
				if !(_vehicle in _checked) then {
					_checked pushBack _vehicle;

					private _type = toLower (typeOf _vehicle);

					switch (true) do {
						case (_type in EGVAR(core,mortar_A3)) : {
							switch (_ammoG) do {
								case ("HE") : {_ammo = "8Rnd_82mm_Mo_shells"};
								case ("SPECIAL") : {_ammo = "8Rnd_82mm_Mo_shells"};
								case ("SECONDARY") : {_ammo = "8Rnd_82mm_Mo_shells"};
								case ("SMOKE") : {_ammo = "8Rnd_82mm_Mo_Smoke_white"};
								case ("ILLUM") : {_ammo = "8Rnd_82mm_Mo_Flare_white"};
							};
						};

						case (_type in EGVAR(core,sPMortar_A3)) : {
							switch (_ammoG) do {
								case ("HE") : {_ammo = "32Rnd_155mm_Mo_shells"};
								case ("SPECIAL") : {_ammo = "2Rnd_155mm_Mo_Cluster"};
								case ("SECONDARY") : {_ammo = "2Rnd_155mm_Mo_guided"};
								case ("SMOKE") : {_ammo = "6Rnd_155mm_Mo_smoke"};
								case ("ILLUM") : {_ammo = ""};
							};
						};

						case (_type in EGVAR(data,rocketArty)) : {
							switch (_ammoG) do {
								case ("HE") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
								case ("SPECIAL") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
								case ("SECONDARY") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
								case ("SMOKE") : {_ammo = ""};
								case ("ILLUM") : {_ammo = ""};
							};
						};

						case (_type in EGVAR(core,rocket_A3)) : {
							switch (_ammoG) do {
								case ("HE") : {_ammo = "12Rnd_230mm_rockets"};
								case ("SPECIAL") : {_ammo = "12Rnd_230mm_rockets"};
								case ("SECONDARY") : {_ammo = "12Rnd_230mm_rockets"};
								case ("SMOKE") : {_ammo = ""};
								case ("ILLUM") : {_ammo = ""};
							};
						};

						default {
							if ((count EGVAR(data,art)) > 0) then {
								_arr = [];

								{
									if (_type in (_x select 0)) exitWith {_arr = _x select 1}
								} forEach EGVAR(data,otherArty);

								if ((count _arr) > 0) then {

									switch (_ammoG) do {
										case ("HE") : {_ammo = _arr select 0};
										case ("SPECIAL") : {_ammo = _arr select 1};
										case ("SECONDARY") : {_ammo = _arr select 2};
										case ("SMOKE") : {_ammo = _arr select 3};
										case ("ILLUM") : {_ammo = _arr select 4};
									};

								} else {

									switch (_ammoG) do {
										case ("HE") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
										case ("SPECIAL") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
										case ("SECONDARY") : {_ammo = (((magazinesAllTurrets _vehicle) select 0) select 0)};
										case ("SMOKE") : {_ammo = ""};
										case ("ILLUM") : {_ammo = ""};
									};

								};
							};
						};
					};

					private _inRange = _pos inRangeOfArtillery [[_vehicle],_ammo];

					if (_inRange) then {
						{
							if ((_x select 0) in [_ammo]) then {
								_hasAmmo = _hasAmmo + (_x select 1);
								_allAmmo = _allAmmo + (_x select 1);
								_ammoArr pushBack _ammo;
								_vehs = _vehs + 1
							};

							if (_hasAmmo >= _amount) exitWith {};
							if (_allAmmo >= _amount) exitWith {}
						} forEach (magazinesAmmo _vehicle);
					};
				};

				if (_amount >_vehs) exitWith {}
			} forEach (units _group);

			if (_hasAmmo > 0) then {
				_artyAv pushBack _group;
				_agp pushBack leader _group
			};
		};
	};

	if (_amount > _hasAmmo ) exitWith {};
	if (_amount > _allAmmo) exitWith {}
} forEach _arty;

if (_artyAv isNotEqualTo []) then {
	_battery = _artyAv;

	_possible = true;

	if (_ammoG in ["ILLUM","SMOKE"]) then {
		{
			if !(isNull _x) then {
				_x setVariable [QGVAR(batteryBusy), true]
			};
		} forEach _battery;

		_pos params ["_pX","_pY","_pZ"];

		_pX = _pX + (random 100) - 50;
		_pY = _pY + (random 100) - 50;
		_pZ = _pZ + (random 20) - 10;

		_pos = [_pX,_pY,_pZ];
		//_i = [_pos,(random 1000),"markArty","ColorRed","ICON","mil_dot",_ammoG,"",[0.75,0.75]] call RYD_Mark;

		private _fnc_code = {
			params ["_battery", "_pos", "_ammo", "_FO", "_amount", "_ammoG"];

			private _positionFO = getPosASL _FO;

			if (_ammoG == "ILLUM") then {
					[_battery,_pos,_ammo,_amount] call FUNC(cff_fire);
			} else {
				private _angle = [_positionFO, _pos, 10] call FUNC(angleTowards);
				private _pos2 = [_pos, _angle + 110,200 + (random 100) - 50] call FUNC(positionTowards2D);
				private _pos3 = [_pos, _angle - 110,200 + (random 100) - 50] call FUNC(positionTowards2D);
				//_i2 = [_pos2,(random 1000),"markArty","ColorRed","ICON","mil_dot",_ammoG,"",[0.75,0.75]] call RYD_Mark;
				//_i3 = [_pos3,(random 1000),"markArty","ColorRed","ICON","mil_dot",_ammoG,"",[0.75,0.75]] call RYD_Mark;

				{
					[_battery, _x, _ammo,ceil (_amount/3)] call FUNC(cff_fire);

					_ct = 0;
					waitUntil {
						sleep 0.1;
						_ct = _ct + 0.1;
						_busy = 0;

						{
							if !(isNull _x) then {
								_busy = _busy + ({!((vehicle _x) getVariable [QGVAR(gunFree), true])} count (units _x))
							};
						} forEach _battery;

						((_busy == 0) || (_ct > 12))
					};
				} forEach [_pos,_pos2,_pos3];
			};

			_ct = 0;
			waitUntil {
				sleep 0.1;
				_ct = _ct + 0.1;
				_busy = 0;

				{
					if !(isNull _x) then {
						private _add = { !((vehicle _x) getVariable [QGVAR(gunFree), true])} count (units _x);
						_busy = _busy + _add;
						if (_add == 0) then {_x setVariable [QGVAR(batteryBusy), false];};
					};
				} forEach _battery;

				((_busy == 0) or (_ct > 12))
			};

			{
				if !(isNull _x) then {
				_x setVariable [QGVAR(batteryBusy), false];
				};
			} forEach _battery;
		};

		[[_battery,_pos,_ammoArr,_FO,_amount,_ammoG], _fnc_code] call FUNC(spawn)
	};
};

//diag_log format ["AM: %1",[_possible,_battery,_agp,_ammoArr]];

[_possible, _battery, _agp, _ammoArr, _allAmmo]
