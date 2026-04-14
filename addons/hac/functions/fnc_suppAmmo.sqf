#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/SuppAmmo.sqf

_SCRname = "SuppAmmo";

private ["_HQ","_ammo","_noenemy","_ammoS","_ammoSG","_Hollow","_soldiers","_ZeroA","_ammoN","_av","_MTrucks","_mtr","_unitvar","_busy","_Unable","_MTrucks2","_MTrucks3","_MTrucks2a","_MTrucks3a","_Zunits","_a",
	"_Zunit","_halfway","_distT","_eClose1","_eClose2","_UL","_Hunits","_MTruck","_Hunit","_ammoBox","_supported"];

_HQ = _this select 0;

_ammo = EGVAR(data,ammo) + EGVAR(data,wS_ammo) - RHQs_Ammo;

_noenemy = true;
	
_ammoS = [];
_ammoSG = [];

	{
	if not (_x in _ammoS) then
		{
		if ((toLower (typeOf (assignedVehicle _x))) in _ammo) then 
			{
			_ammoS pushBack _x;

			if not ((group _x) in (_ammoSG + (_HQ getVariable [QEGVAR(hac,specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]))) then 
				{
				_ammoSG pushBack (group _x)
				}
			}
		}
	}
forEach (_HQ getVariable [QEGVAR(hac,support),[]]);

	{
	if not (_x in _ammoSG) then
		{
		_ammoSG pushBack _x
		}
	}
forEach (_HQ getVariable [QEGVAR(core,ammoDrop),[]]);

_HQ setVariable [QGVAR(ammoSupport),_ammoS];
_HQ setVariable [QGVAR(ammoSupportG),_ammoSG];

_Hollow = [];
_soldiers = [];
_ZeroA = [];

	{
	
	if not (isPlayer (leader _x)) then {

		_ammoN = 0;

			{
			_ammoN = _ammoN + (count (magazines _x))
			}
		forEach (units _x);

			{
			_av = assignedVehicle _x;

			if not (isNull _av) then
				{
				if not (someAmmo _av) then
					{
					if not (_av in _ZeroA) then
						{
						if not ((toLower (typeOf _av)) in ((_HQ getVariable [QEGVAR(core,nCVeh),[]]))) then
							{
							if (((getPosATL _x) select 2) < 5) then 
								{
								_ZeroA pushBack _av
								}
							}
						}
					}
				};

			if ((isNull objectParent _x)) then
				{
				if (((_x ammo ((weapons _x) select 0)) == 0) or ((count (magazines _x)) < 2) or ((_ammoN/(((count (units (group _x))) + 0.1)) < (6/(((_HQ getVariable [QEGVAR(core,recklessness),0.5])*2) + 1))))) then
					{
					if not (_x in _Hollow) then 
						{
						_Hollow pushBack _x; 
						if not (_x in _soldiers) then 
							{
							_soldiers pushBack _x
							}
						}
					}
				}
			}
		forEach (units _x)
		
	};
	}
forEach ((_HQ getVariable [QEGVAR(core,friends),[]]) - (_HQ getVariable [QGVAR(exReAmmo),[]]));

//_Hollow = _Hollow + _ZeroA;
_HQ setVariable [QGVAR(hollow),_Hollow + _ZeroA];
_MTrucks = [];

	{
	_mtr = assignedVehicle (leader _x);

	if not (isNull _mtr) then
		{
		if (canMove _mtr) then
			{
			if ((fuel _mtr) > 0.2) then
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
					if not (_x in _MTrucks) then 
						{
						_MTrucks pushBack _x
						}
					}
				}
			}
		}
	}
forEach _ammoSG;

_MTrucks2 = [];
_MTrucks3 = [];

	{
	if (_x in (_HQ getVariable [QEGVAR(core,ammoDrop),[]])) then
		{
		_MTrucks3 pushBack _x
		}
	else
		{
		_MTrucks2 pushBack _x
		}
	}
forEach _MTrucks;

_MTrucks2a = +_MTrucks2;
_MTrucks3a = +_MTrucks3;

_Zunits = +_ZeroA;
_a = 0;
for [{_a = 500},{_a <= 44000},{_a = _a + 500}] do
	{
		{
		_MTruck = assignedVehicle (leader _x);

		for [{_b = 0},{_b < (count _ZeroA)},{_b = _b + 1}] do 
			{
			_Zunit = _ZeroA select _b;		

				{
				if ((_Zunit distance (assignedVehicle (leader _x))) < 400) exitWith 
					{
					if not ((group _Zunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
						_supported pushBack (group _Zunit);
						_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
						//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Zunit)]]
						}
					};
				}
			forEach _ammoSG;
			
				{
				if ((_Zunit distance _x) < 400) exitWith 
					{
					if not ((group _Zunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
						_supported pushBack (group _Zunit);
						_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
						//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Zunit)]]
						}
					};
				}
			forEach (_HQ getVariable [QEGVAR(core,ammoPoints),[]]);
			
			_noenemy = true;

			_halfway = [(((position _MTruck) select 0) + ((position _Zunit) select 0))/2,(((position _MTruck) select 1) + ((position _Zunit) select 1))/2];
			_distT = 500/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
			_eClose1 = [_Zunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
			_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
			if ((_eClose1) or (_eClose2)) then {_noenemy = false};
			if not ((group _Zunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then
				{
				_UL = leader (group (assignedDriver _Zunit));
				if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_SuppReq),"SuppReq"] call EFUNC(common,AIChatter)}};
				};
			
			if (not ((group _Zunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) and ((_Zunit distance _MTruck) <= _a) and (_noenemy) and (_x in _MTrucks)) then 
				{
				if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
				_MTrucks2 = _MTrucks2 - [_x];
				_Zunits = _Zunits - [_Zunit];
				_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
				_supported pushBack (group _Zunit);
				_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
				//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Zunit)]];
				//[_MTruck,_Zunit,_Hollow,_soldiers,false,objNull,_HQ] spawn FUNC(goAmmoSupp)
				
				[[_MTruck,_Zunit,_Hollow,_soldiers,false,objNull,_HQ],FUNC(goAmmoSupp)] call EFUNC(common,spawn);
				}
			else
				{
				if (_a >= 44000) then 
					{
					if not ((group _Zunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
					_Zunits = _Zunits - [_Zunit]
					};
				};
			
			if (((_MTrucks2 isEqualTo [])) or ((_Zunits isEqualTo []))) exitWith {};
			};
			
		if (((_MTrucks2 isEqualTo [])) or ((_Zunits isEqualTo []))) exitWith {};
		}
	forEach _MTrucks2a;
	};

if ((count (_HQ getVariable [QEGVAR(core,ammoBoxes),[]])) > 0) then
	{
	_Hunits = +_Hollow;

	for [{_a = 500},{_a < 44000},{_a = _a + 500}] do
		{
			{
			_MTruck = assignedVehicle (leader _x);
			
			for [{_b = 0},{_b < (count _Hollow)},{_b = _b + 1}] do 
				{
				_Hunit = _Hollow select _b;

					{
					if ((_Hunit distance (assignedVehicle (leader _x))) < 250) exitWith 
						{
						if not ((group _Hunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then 
							{
							_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
							_supported pushBack (group _Hunit);
							_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
							//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Hunit)]]
							}
						};
					}
				forEach _ammoSG;

					{
					if ((_Hunit distance _x) < 250) exitWith 
						{
						if not ((group _Hunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then 
							{
							_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
							_supported pushBack (group _Hunit);
							_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
							//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Hunit)]]
							}
						};
					}
				forEach (_HQ getVariable [QEGVAR(core,ammoPoints),[]]);

				_noenemy = true;
				_halfway = [(((position _MTruck) select 0) + ((position _Hunit) select 0))/2,(((position _MTruck) select 1) + ((position _Hunit) select 1))/2];
				_distT = 300/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
				_eClose1 = [_Hunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
				_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
				if ((_eClose1) or (_eClose2)) then {_noenemy = false};

				if not ((group _Hunit) in ((_HQ getVariable [QEGVAR(core,aSupportedG),[]]) + (_HQ getVariable [QEGVAR(core,boxed),[]]))) then
					{
					_UL = leader (group _Hunit);
					if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_SuppReq),"SuppReq"] call EFUNC(common,AIChatter)}};
					};
			
				if (not ((group _Hunit) in ((_HQ getVariable [QEGVAR(core,aSupportedG),[]]) + (_HQ getVariable [QEGVAR(core,boxed),[]]))) and ((_Hunit distance _MTruck) <= _a) and (_noenemy) and (_x in _MTrucks) and ((count (_HQ getVariable [QEGVAR(core,ammoBoxes),[]])) > 0)) then 
					{
					if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
					_MTrucks3 = _MTrucks3 - [_x];
					_Hunits = _Hunits - [_Hunit];
					
					_supported = _HQ getVariable [QEGVAR(core,aSupportedG),[]];
					_supported pushBack (group _Hunit);
					_HQ setVariable [QEGVAR(core,aSupportedG),_supported];
					
					//_HQ setVariable ["RydHQ_ASupportedG",(_HQ getVariable ["RydHQ_ASupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_ASupportedG",[]])),(group _Hunit)]];
					_ammoBox = (_HQ getVariable [QEGVAR(core,ammoBoxes),[]]) select 0;
					_HQ setVariable [QEGVAR(core,ammoBoxes),(_HQ getVariable [QEGVAR(core,ammoBoxes),[]]) - [_ammoBox]];
					//[_MTruck,_Hunit,_Hollow,_soldiers,true,_ammoBox,_HQ] spawn FUNC(goAmmoSupp); 
					[[_MTruck,_Hunit,_Hollow,_soldiers,true,_ammoBox,_HQ],FUNC(goAmmoSupp)] call EFUNC(common,spawn);
					}
				else
					{
					if (_a >= 44000) then 
						{
						if not ((group _Hunit) in (_HQ getVariable [QEGVAR(core,aSupportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
						_Hunits = _Hunits - [_Hunit]
						};
					};				
				if (((_MTrucks3 isEqualTo [])) or ((_Hunits isEqualTo []))) exitWith {};
				};
				
			if (((_MTrucks3 isEqualTo [])) or ((_Hunits isEqualTo []))) exitWith {};
			}
		forEach _MTrucks3a
		}
	};
