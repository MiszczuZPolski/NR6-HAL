#include "..\script_component.hpp"

private ["_enemies","_targets","_target","_nothing","_potential","_potL","_taken","_candidate","_CL","_vehFactor","_artFactor","_crowdFactor","_veh","_nearImp","_ValMax","_trgValS",
	"_temptation","_vh","_HQfactor","_nearCiv"];

	_enemies = _this select 0;

	_targets = [];
	_target = objNull;
	_temptation = 0;
	_nothing = 0;

		{
		_potential = vehicle _x;

		if not (isNil "_potential") then
			{
			if not (isNull _potential) then
				{
				if (alive _potential) then
					{
					_potL = vehicle (leader _potential);
					_taken = (group _potential) getVariable ["CFF_Taken",false];

					if not (isNil "_taken") then
						{
						if not (_taken) then
							{
							if (((getPosATL _potL) select 2) < 20) then
								{
								if ((abs(speed _potL)) < 50) then
									{
									if ((count (weapons (leader _potential))) > 0) then
										{
										if not ((leader _potential) isKindOf "civilian") then
											{
											if not (captive _potL) then
												{
												if not (_potential in _targets) then
													{
													if ((damage _potL) < 0.9) then
														{
														_targets pushBack _potential
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	forEach _enemies;

		{
		_candidate = _x;
		_CL = leader _candidate;

		_temptation = 0;
		_vehFactor = 0;
		_artFactor = 1;
		_crowdFactor = 1;
		_HQFactor = 1;
		_veh = objNull;

		if not (isNull (assignedVehicle _CL)) then {_veh = assignedVehicle _CL};
		if not ((vehicle _CL) == _CL) then
			{
			_veh = vehicle _CL;
			if ((toLower (typeOf _veh)) in RydHQ_AllArty) then {_artFactor = 10} else {_vehFactor = 500 + (rating _veh)};
			};

		_nearImp = (getPosATL _CL) nearEntities [["CAManBase","AllVehicles","Strategic","WarfareBBaseStructure","Fortress"],100];
		_nearCiv = false;

			{
			if (_x isKindOf "civilian") exitWith {_nearCiv = true};
			if (((side _x) getFriend (side _CL)) >= 0.6) then
				{
				_vh = vehicle _x;
				_crowdFactor = _crowdFactor + 0.2;
				if not (_x == _vh) then
					{
					_crowdFactor = _crowdFactor + 0.2;
					if ((toLower (typeOf _vh)) in RydHQ_AllArty) then
						{
						_crowdFactor = _crowdFactor + 0.2
						}
					}
				};
			}
		forEach _nearImp;

		if (_CL in RydxHQ_AllLeaders) then {_HQFactor = 20};

		if (_nearCiv) then
			{
			_targets deleteAt _foreachIndex
			}
		else
			{

				{
				_temptation = _temptation + (250 + (rating _x));
				}
			forEach (units _candidate);

			_temptation = (((_temptation + _vehFactor)*10)/(5 + (speed _CL))) * _artFactor * _crowdFactor * _HQFactor;
			_candidate setVariable ["CFF_Temptation",_temptation]
			}
		}
	forEach _targets;

	_ValMax = 0;

		{
		_trgValS = _x getVariable ["CFF_Temptation",0];
		if ((_ValMax < _trgValS) and (random 100 < 85)) then {_ValMax = _trgValS;_target = _x};
		}
	forEach _targets;

	if (isNull _target) then
		{
		if not ((count _targets) == 0) then
			{
			_target = _targets select (floor (random (count _targets)))
			}
		else
			{
			_nothing = 1
			}
		};

	_target