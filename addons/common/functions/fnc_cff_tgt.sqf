#include "..\script_component.hpp"
//RYD_CFF_TGT

params ["_enemies"];

private ["_targets","_target","_nothing","_potential","_potL","_taken","_candidate","_CL","_vehFactor","_artFactor","_crowdFactor","_veh","_nearImp","_ValMax","_trgValS","_temptation","_vh","_HQfactor","_nearCiv"];

_targets = [];
_target = objNull;
_temptation = 0;
_nothing = 0;

{
	_potential = vehicle _x;

	if !(isNil "_potential") then {
		if !(isNull _potential) then {
			if (alive _potential) then {
				_potL = vehicle (leader _potential);
				_taken = (group _potential) getVariable ["CFF_Taken",false];

				if !(isNil "_taken") then {
					if !(_taken) then {
						if (((getPosATL _potL) select 2) < 20) then {
							if ((abs(speed _potL)) < 50) then {
								if (weapons leader _potential isNotEqualTo []) then {
									if !((leader _potential) isKindOf "civilian") then {
										if !(captive _potL) then {
											if !(_potential in _targets) then {
												if ((damage _potL) < 0.9) then {
													_targets pushBack _potential;
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
} forEach _enemies;

{
	_candidate = _x;
	_CL = leader _candidate;

	_temptation = 0;
	_vehFactor = 0;
	_artFactor = 1;
	_crowdFactor = 1;
	_HQFactor = 1;
	_veh = objNull;

	if !(isNull (assignedVehicle _CL)) then {_veh = assignedVehicle _CL};
	if !(isNull objectParent _CL) then {
		_veh = vehicle _CL;
		if ((toLower (typeOf _veh)) in GVAR(allArty)) then {_artFactor = 10} else {_vehFactor = 500 + (rating _veh)};
	};

	_nearImp = (getPosATL _CL) nearEntities [["CAManBase","AllVehicles","Strategic","WarfareBBaseStructure","Fortress"], 100];
	_nearCiv = false;

	{
		if (_x isKindOf "civilian") exitWith {_nearCiv = true};
		if (((side _x) getFriend (side _CL)) >= 0.6) then {
			_vh = vehicle _x;
			_crowdFactor = _crowdFactor + 0.2;
			if (_x != _vh) then {
				_crowdFactor = _crowdFactor + 0.2;
				if ((toLower (typeOf _vh)) in GVAR(allArty)) then {
					_crowdFactor = _crowdFactor + 0.2
				};
			;}
		};
	} forEach _nearImp;

	if (_CL in EGVAR(core,allLeaders)) then {_HQFactor = 20};

	if (_nearCiv) then {
		_targets deleteAt _foreachIndex
	} else {

		{
			_temptation = _temptation + (250 + (rating _x));
		} forEach (units _candidate);

		_temptation = (((_temptation + _vehFactor)*10)/(5 + (speed _CL))) * _artFactor * _crowdFactor * _HQFactor;
		_candidate setVariable ["CFF_Temptation", _temptation]
	};
} forEach _targets;

_ValMax = 0;

{
	_trgValS = _x getVariable ["CFF_Temptation", 0];
	if ((_ValMax < _trgValS) and (random 100 < 85)) then {_ValMax = _trgValS;_target = _x};
} forEach _targets;

if (isNull _target) then {
	if (_targets isNotEqualTo []) then {
		_target = _targets select (floor (random (count _targets)))
	} else {
		_nothing = 1
	};
};

_target
