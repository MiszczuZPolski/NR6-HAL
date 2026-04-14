#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/Garrison.sqf
_SCRname = "Garrison";

_HQ = _this select 0;
_recArr = _this select 1;
_Garrison = _HQ getVariable [QEGVAR(core,garrison),[]];
_garrRange = _HQ getVariable [QEGVAR(core,garrRange),1];

{
	if (_x getVariable [("NOGarrisoned" + (str _x)),false]) then {_x setVariable [("Garrisoned" + (str _x)),false];_x setVariable [("NOGarrisoned" + (str _x)),false];_Garrison = _Garrison - [_x];};

} forEach _Garrison;

_HQ setVariable [QEGVAR(core,garrison),_Garrison];

if (isNil QEGVAR(core,garrisonV2)) then {EGVAR(core,garrisonV2) = false};

_posTaken = [];

for [{_a = 0},{_a < (count _Garrison)},{_a = _a + 1}] do
	{
	_unitG = _Garrison select _a;
	_garrisoned = _unitG getVariable ("Garrisoned" + (str _unitG));
	if (isNil "_garrisoned") then {_garrisoned = false};

	_NOgarrisoned = _unitG getVariable ("NOGarrisoned" + (str _unitG));
	if (isNil "_NOgarrisoned") then {_NOgarrisoned = false};

	_Unable = _unitG getVariable "Unable";
	if (isNil ("_Unable")) then {_Unable = false};

	_busy = _unitG getVariable ("Busy" + (str _unitG));
	if (isNil "_busy") then {_busy = false};

	if (not (_garrisoned) and not (_NOgarrisoned) and not (EGVAR(core,garrisonV2)) and not (_Unable) and not (_busy)) then
		{
		[_unitG] call CBA_fnc_clearWaypoints;

		_unitG setVariable ["Garrisoned" + (str _unitG),true];

		_pos = getPosATL (vehicle (leader _unitG));
		_units = [];

		_UL = leader _unitG;
		_AV = assignedVehicle _UL;

		if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,EGVAR(boss,aIC_OrdConf),"OrdConf"] call EFUNC(common,AIChatter)}};

		if ((_HQ getVariable [QEGVAR(common,debug),false]) or (isPlayer (leader _unitG))) then
			{
			_signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
			_i = [_pos,_unitG,"markGarrison","ColorBrown","ICON","mil_box","Garr " + _signum," - GARRISON",[0.5,0.5]] call EFUNC(common,mark);
			};

		if ((_HQ getVariable [QEGVAR(core,garrVehAb),false]) and not (isPlayer (leader _unitG))) then
			{
			//{unassignVehicle _x} foreach (units _unitG);
			(units _unitG) orderGetIn false;
			(units _unitG) allowGetIn false;//if (player in (units _unitG)) then {diag_log "NOT ALLOW garr"};
			sleep 5
			};

		if (not (isNull _AV) and not (_HQ getVariable [QEGVAR(core,garrVehAb),false])) exitWith
			{
			_formation = "DIAMOND";
			if (isPlayer (leader _unitG)) then {_formation = formation _unitG};
			_wp = [_unitG,position (leader _unitG),"SENTRY","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],false,0,[0,0,0],_formation] call EFUNC(common,WPadd)
			};

		_units = (units _unitG) - [leader _unitG];

		if not (isPlayer _UL) then
			{
			_list = _pos nearObjects ["StaticWeapon",300 * _garrRange];
			_staticWeapons = [];

				{
				if ((_x emptyPositions "gunner") > 0) then
					{
					_staticWeapons pushBack _x;
					};
				}
			forEach _list;

				{
				if ((_units isNotEqualTo [])) then
					{
					_unit = (_units select -1);

					if (((random 1) > 0.1) and not ((toLower (typeOf _unit)) in _recArr)) then
						{
						_unit assignAsGunner _x;
						[_unit] orderGetIn true;

						_units resize ((count _units) - 1)
						}
					}
				}
			forEach _staticWeapons;

			_Bldngs = _pos nearObjects ["House",300 * _garrRange];
			_posTaken = missionNamespace getVariable ["PosTaken",[]];
			_posAll = [];
			_posAll0 = [];

				{
				_Bldg = _x;
				if ((_Bldg distance _UL) > (300 * _garrRange)) then {_Bldg = objNull};

				if not (isNull _Bldg) then
					{
					_posAct = _Bldg buildingPos 0;
					_j = 0;
					while {((_posAct distance [0,0,0]) > 0)} do
						{
						_tkn = false;

							{
							if ((typeName _x) == ("ARRAY")) then
								{
								if (((_x select 0) + (_x select 1)) == ((_posAct select 0) + (_posAct select 1))) exitWith {_tkn = true}
								}
							}
						forEach _posTaken;

						if not (_tkn) then
							{
							_tkn = false;
							_sum = (_posAct select 0) + (_posAct select 1);

								{
								if ((typeName _x) == ("ARRAY")) then
									{
									if (((_x select 0) + (_x select 1)) == _sum) exitWith {_tkn = true}
									}
								}
							forEach _posTaken;

							if not (_tkn) then
								{
								_posAll pushBack [_posAct,_Bldg]
								}
							};

						_j = _j + 1;
						_posAct = _Bldg buildingPos _j;
						}
					}
				}
			forEach _Bldngs;

			_posAll0 = +_posAll;

				{
				_ix = 0;
				if not ((_posAll isEqualTo [])) then
					{
					_ix = floor (random (count _posAll));
					_posS = _posAll select _ix;
					_bld = _posS select 1;
					_posS = _posS select 0;
					_ct = 0;

					_posTaken = missionNamespace getVariable ["PosTaken",[]];

					while {((_posS in _posTaken) and (_ct < 20))} do
						{
						_ix = floor (random (count _posAll));
						_posS = _posAll select _ix;
						_ct = _ct + 1
						};

					if not ((_posS distance _pos) > (350 * _garrRange)) then
						{
						if ((random 100) > 20) then
							{
							_tkn = false;
							_sum = (_posS select 0) + (_posS select 1);

								{
								if ((typeName _x) == ("ARRAY")) then
									{
									if (((_x select 0) + (_x select 1)) == _sum) exitWith {_tkn = true}
									}
								}
							forEach _posTaken;

							if not (_tkn) then
								{
								_posAll set [_ix,0];
								_posAll = _posAll - [0];
								_ix  = count _posTaken;
								_posTaken pushBack _posS;
								_posTaken = _posTaken - [0];
								missionNamespace setVariable ["PosTaken",_posTaken];
								//[_x,_posS,_bld,[_posTaken,_ix],_HQ] spawn RYD_GarrS;
								[[_x,_posS,_bld,[_posTaken,_ix],_HQ],EFUNC(common,garrisonS)] call EFUNC(common,spawn);
								_units = _units - [_x]
								}
							}
						}
					}
				}
			forEach _units;

			_patrolPos = [];

				{
				_pA = _x select 0;
				if ((typeName _pA) == ("ARRAY")) then
					{
					_isGood = true;
					if ((_pA select 2) > 16) then
						{
						_isGood = false
						};

					if (_isGood) then
						{
						for "_i" from 0 to ((count _patrolPos) - 1) do
							{
							_pPos = _patrolPos select _i;
							_dst = _pPos distance _pA;
							if (_dst > 0.1) then
								{
								if (_dst < 16) then
									{
									_isGood = false
									}
								};
							}
						};

					if (_isGood) then
						{
						_patrolPos pushBack _pA;
						}
					}
				}
			forEach _posAll0;

			if ((count _patrolPos) > 1) then
				{
				//[_unitG,_patrolPos,_HQ] spawn RYD_GarrP
				[[_unitG,_patrolPos,_HQ],EFUNC(common,garrisonP)] call EFUNC(common,spawn);
				}
			else
				{
				_formation = "DIAMOND";
				if (isPlayer (leader _unitG)) then {_formation = formation _unitG};
				_wp = [_unitG,position (leader _unitG),"SENTRY","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],false,0,[0,0,0],_formation] call EFUNC(common,WPadd);
				}
			}
		};

	if (not (_garrisoned) and not (_NOgarrisoned) and (EGVAR(core,garrisonV2)) and not (_Unable) and not (_busy)) then
		{

		_unitG setVariable ["Garrisoned" + (str _unitG),true];

		_UL = leader _unitG;
		_AV = assignedVehicle _UL;
		_pos = getPosATL (vehicle (leader _unitG));

		if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,EGVAR(boss,aIC_OrdConf),"OrdConf"] call EFUNC(common,AIChatter)}};

		if (_unitG getVariable ["Busy" + (str _unitG),true]) then {
			_unitG setVariable ["Break",true];
			waitUntil {sleep 1; not (_unitG getVariable ["Break",false])};
		};

		[_unitG] call CBA_fnc_clearWaypoints;

		if (_HQ getVariable [QEGVAR(common,debug),false]) then
			{
			_signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
			_i = [_pos,_unitG,"markGarrison","ColorBlack","ICON","mil_box","GARR " + (groupId _unitG) + " " + _signum," - GARRISON",[0.5,0.5]] call EFUNC(common,mark);
			};

		_task = [(leader _unitG),["Setup Garrison", "Setup a garrison and defend the area.", ""],(getPosATL (leader _unitG)),"defend"] call EFUNC(common,addTask);

		[_unitG,_pos,150,1,0.5,0,false] remoteExecCall ["NR6_fnc_CBA_Defend",(leader _unitG)];

		}
	};
