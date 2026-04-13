#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/SuppRep.sqf

_SCRname = "SuppRep";

private ["_HQ","_rep","_noenemy","_repS","_repSG","_damaged","_Sdamaged","_Ldamaged","_av","_rtrs","_rt","_unitvar","_busy","_unable","_rtrs2","_SDunits","_a","_rtr","_SDunit","_halfway","_distT","_eClose1",
	"_eClose2","_UL","_Dunits","_Dunit","_supported"];
	
_HQ = _this select 0;

_rep = EGVAR(data,rep) + EGVAR(data,wS_rep) - RHQs_Rep;
_noenemy = true;

_repS = [];
_repSG = [];

	{
	if not (_x in _repS) then
		{
		if ((toLower (typeOf (assignedVehicle _x))) in _rep) then 
			{
			_repS pushBack _x;
			if not ((group _x) in (_repSG + (_HQ getVariable [QEGVAR(hac,specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]))) then 
				{
				_repSG pushBack (group _x)
				}
			}
		}
	}
forEach (_HQ getVariable [QEGVAR(hac,support),[]]);

_HQ setVariable [QGVAR(repSupport),_repS];
_HQ setVariable [QGVAR(repSupportG),_repSG];

_damaged = [];
_Sdamaged = [];
_Ldamaged = [];

	{
	if not (isPlayer (leader _x)) then {
		{
		_av = assignedVehicle _x;
		if not (isNull _av) then
			{
			if ((damage _av) > 0.1) then
				{
				if ((damage _av) < 0.9) then
					{
					if (((getPosATL _x) select 2) < 5) then 
						{
						_damaged pushBack _av;
						if (((damage _av) > 0.5) or not (canMove _av)) then
							{
							_Sdamaged pushBack _av
							}
						}
					}
				}
			}
		}
	forEach (units _x)
	};
	}
forEach ((_HQ getVariable [QEGVAR(core,friends),[]]) - (_HQ getVariable [QEGVAR(core,exRepair),[]]));

_Ldamaged = _damaged - _Sdamaged;
_HQ setVariable [QGVAR(damaged),_damaged];
_rtrs = [];

	{
	_rt = assignedVehicle (leader _x);

	if not (isNull _rt) then
		{
		if (canMove _rt) then
			{
			if ((fuel _rt) > 0.2) then
				{
				_unitvar = str (_x);
				_busy = false;
				_busy = _x getVariable ("Busy" + _unitvar);
				if (isNil ("_busy")) then {_busy = false};

				_unable = false;
				_unable = _x getVariable "Unable";
				if (isNil ("_unable")) then {_unable = false};

				if (not (_busy) and not (_unable)) then
					{
					if not (_x in _rtrs) then 
						{
						_rtrs pushBack _x
						}
					}
				}
			}
		}
	}
forEach _repSG;

_rtrs2 = +_rtrs;
_SDunits = +_Sdamaged;
_a = 0;
for [{_a = 500},{_a <= 44000},{_a = _a + 500}] do
	{
		{
		_rtr = assignedVehicle (leader _x);

		for [{_b = 0},{_b < (count _Sdamaged)},{_b = _b + 1}] do 
			{
			_SDunit = _Sdamaged select _b;

				{
				if ((_SDunit distance (assignedVehicle (leader _x))) < 300) exitWith 
					{
					if not ((group _SDunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
						_supported pushBack (group _SDunit);
						_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
						//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _SDunit)]]
						}
					};
				}
			forEach _repSG;

				{
				if ((_SDunit distance _x) < 300) exitWith 
					{
					if not ((group _SDunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
						_supported pushBack (group _SDunit);
						_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
						//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _SDunit)]]
						}
					};
				}
			forEach (_HQ getVariable [QEGVAR(core,repPoints),[]]);

			_noenemy = true;
			_halfway = [(((position _rtr) select 0) + ((position _SDunit) select 0))/2,(((position _rtr) select 1) + ((position _SDunit) select 1))/2];
			_distT = 500/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
			_eClose1 = [_SDunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
			_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
			if ((_eClose1) or (_eClose2)) then {_noenemy = false};

			if not ((group _SDunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then
				{
				_UL = leader (group (assignedDriver _SDunit));
				if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_SuppReq),"SuppReq"] call EFUNC(common,AIChatter)}};
				};
			
			if (not ((group _SDunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) and ((_SDunit distance _rtr) <= _a) and (_noenemy) and (_x in _rtrs)) then 
				{
				if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
				_rtrs = _rtrs - [_x];
				_SDunits = _SDunits - [_SDunit];
				
				_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
				_supported pushBack (group _SDunit);
				_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
				
				//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _SDunit)]];
				//[_rtr,_SDunit,_damaged,_HQ] spawn FUNC(goRepSupp); 
				[[_rtr,_SDunit,_damaged,_HQ],FUNC(goRepSupp)] call EFUNC(common,spawn);
				}
			else
				{
				if (_a >= 44000) then 
					{
					if not ((group _SDunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
					_SDunits = _SDunits - [_SDunit]
					};
				};
			
			if (((count _rtrs) == 0) or ((count _SDunits) == 0)) exitWith {};
			};
			
		if (((count _rtrs) == 0) or ((count _SDunits) == 0)) exitWith {};
		}
	forEach _rtrs2;
	};

_Dunits = +_damaged;

for [{_a = 500},{_a < 10000},{_a = _a + 500}] do
	{
		{
		_rtr = assignedVehicle (leader _x);
		for [{_b = 0},{_b < (count _damaged)},{_b = _b + 1}] do 
			{
			_Dunit = _damaged select _b;

				{
				if ((_Dunit distance (assignedVehicle (leader _x))) < 400) exitWith 
					{
					if not ((group _Dunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
						_supported pushBack (group _Dunit);
						_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
						//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _Dunit)]]
						}
					};
				}
			forEach _repSG;

				{
				if ((_Dunit distance _x) < 400) exitWith 
					{
					if not ((group _Dunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
						_supported pushBack (group _Dunit);
						_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
						//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _Dunit)]]
						}
					};
				}
			forEach (_HQ getVariable [QEGVAR(core,repPoints),[]]);

			_noenemy = true;
			_halfway = [(((position _rtr) select 0) + ((position _Dunit) select 0))/2,(((position _rtr) select 1) + ((position _Dunit) select 1))/2];
			_distT = 600/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
			_eClose1 = [_Dunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
			_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
			if ((_eClose1) or (_eClose2)) then {_noenemy = false};

			if not ((group _Dunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then
				{
				_UL = leader (group (assignedDriver _Dunit));
				if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_SuppReq),"SuppReq"] call EFUNC(common,AIChatter)}};
				};
						
			if (not ((group _Dunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) and ((_Dunit distance _rtr) <= _a) and (_noenemy) and (_x in _rtrs)) then 
				{
				if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
				_rtrs = _rtrs - [_x];
				_Dunits = _Dunits - [_Dunit];
				
				_supported = _HQ getVariable [QEGVAR(core,rSupportedG),[]];
				_supported pushBack (group _Dunit);
				_HQ setVariable [QEGVAR(core,rSupportedG),_supported];
				
				//_HQ setVariable ["RydHQ_RSupportedG",(_HQ getVariable ["RydHQ_RSupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_RSupportedG",[]])),(group _Dunit)]];
				//[_rtr,_Dunit,_damaged,_HQ] spawn FUNC(goRepSupp); 
				[[_rtr,_Dunit,_damaged,_HQ],FUNC(goRepSupp)] call EFUNC(common,spawn);
				}
			else
				{
				if (_a >= 10000) then 
					{
					if not ((group _Dunit) in (_HQ getVariable [QEGVAR(core,rSupportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
					_Dunits = _Dunits - [_Dunit]
					};
				};
			
			if (((count _rtrs) == 0) or ((count _Dunits) == 0)) exitWith {};
			};
			
		if (((count _rtrs) == 0) or ((count _Dunits) == 0)) exitWith {};
		}
	forEach _rtrs2;
	};
