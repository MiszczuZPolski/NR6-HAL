#include "..\script_component.hpp"

params ["_arty","_amount"];

_amount = ceil _amount;
//if (_amount < 2) exitWith {};

{
	{
		private _vehicle = vehicle _x;
		private _handled = _vehicle getVariable ["RydHQArtyAmmoHandled", false];

		if !(_handled) then {
			_vehicle setVariable ["RydHQArtyAmmoHandled", true];

			_vehicle addEventHandler ["Fired",{
				(_this select 0) setVariable [QGVAR(shotFired), true];
				(_this select 0) setVariable [QGVAR(shotFired2), ((_this select 0) getVariable [QGVAR(shotFired2), 0]) + 1];
			}];

			private _magTypes = getArtilleryAmmo [_vehicle];
			private _mags = magazines _vehicle;

			{
				private _type = _x;
				private _count = {_x in [_type]} count _mags;
				_vehicle addMagazines [_type, _count * (_amount - 1)];
			} forEach _magTypes;
		};
	} forEach (units _x);
} forEach _arty;
