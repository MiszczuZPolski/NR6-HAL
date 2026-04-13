#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/SuppMed.sqf

_SCRname = "SuppMed";

private ["_HQ","_med","_noenemy","_medS","_medSG","_medASG","_airMedAv","_landMedAv","_busy","_unable","_wounded","_Swounded","_Lwounded","_ambulances","_amb","_unitvar","_ambulances2","_SWunits","_a",
	"_SWunit","_halfway","_distT","_eClose1","_eClose2","_UL","_Wunits","_ambulance","_WUnit","_supported"];

_HQ = _this select 0;

_med = EGVAR(data,med) + EGVAR(data,wS_med) - RHQs_Med;
_noenemy = true;
	
_medS = [];
_medSG = [];
_medASG = [];

	{
	if not (_x in _medS) then
		{
		if ((toLower (typeOf (assignedVehicle _x))) in _med) then 
			{
			_medS pushBack _x;
			if not ((group _x) in _medSG) then 
				{
				_medSG pushBack _x
				};

			if not ((group _x) in (_medASG + (_HQ getVariable [QEGVAR(hac,specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]))) then
				{
				if (_x in (_HQ getVariable [QEGVAR(core,airG),[]])) then 
					{
					_medASG pushBack (group _x)
					}
				}
			}
		}
	}
forEach (_HQ getVariable [QEGVAR(hac,support),[]]);

_HQ setVariable [QGVAR(medSupport),_medS];
_HQ setVariable [QGVAR(medSupportG),_medSG];
_HQ setVariable [QGVAR(medSupportAirG),_medASG];

_airMedAv = [];
_landMedAv = [];

	{
	_busy = _x getVariable ("Busy" + (str _x));
	if (isNil "_busy") then {_busy = false};
	_unable = false;
	_unable = _x getVariable "Unable";
	if (isNil ("_unable")) then {_unable = false};

	if ((not _busy) and (not _unable)) then {_airMedAv pushBack _x}
	}
forEach _medASG;

	{
	_busy = _x getVariable ("Busy" + (str _x));
	if (isNil "_busy") then {_busy = false};
	_unable = false;
	_unable = _x getVariable "Unable";
	if (isNil ("_unable")) then {_unable = false};

	if (not (_busy) and not (_unable)) then {_landMedAv pushBack _x}
	}
forEach (_medSG - _medASG);

_wounded = [];
_Swounded = [];
_Lwounded = [];

	{
	if not (isPlayer (leader _x)) then {
		{
		if ((isNull objectParent _x)) then
			{
			if ((damage _x) > 0.5) then
				{
				if ((damage _x) < 0.9) then 
					{
					_wounded pushBack _x
					};

				if (alive _x) then
					{
					if (((damage _x) > 0.75) or not (canStand _x)) then
						{
						_Swounded pushBack _x
						}
					}
				}
			}
		}
	forEach (units _x)
	};
	}
forEach ((_HQ getVariable [QEGVAR(core,friends),[]]) - (_HQ getVariable [QEGVAR(core,exMedic),[]]));

_Lwounded = _wounded - _Swounded;
_HQ setVariable [QGVAR(wounded),_wounded];
_ambulances = [];

	{
	_amb = assignedVehicle (leader _x);

	if not (isNull _amb) then
		{
		if (canMove _amb) then
			{
			if ((fuel _amb) > 0.2) then
				{
				_unitvar = str (_x);
				_busy = false;
				_busy = _x getVariable ("Busy" + _unitvar);
				if (isNil ("_busy")) then {_busy = false};

				if not (_busy) then
					{
					if not (_x in _ambulances) then 
						{
						_ambulances pushBack _x
						}
					}
				}
			}
		}
	}
forEach _medSG;

_ambulances2 = +_ambulances;
_SWunits = +_Swounded;
_a = 0;
for [{_a = 500},{_a <= 44000},{_a = _a + 500}] do
	{
		{
		_ambulance = assignedVehicle (leader _x);

		for [{_b = 0},{_b < (count _Swounded)},{_b = _b + 1}] do 
			{
			_SWunit = _Swounded select _b;

				{
				if ((_SWunit distance (assignedVehicle (leader _x))) < 125) exitWith 
					{
					if not ((group _SWunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
						_supported pushBack (group _SWunit);
						_HQ setVariable [QEGVAR(core,supportedG),_supported];
						//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _SWunit)]]
						}
					};
				}
			forEach _medSG;

				{
				if ((_SWunit distance _x) < 125) exitWith 
					{
					if not ((group _SWunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
						_supported pushBack (group _SWunit);
						_HQ setVariable [QEGVAR(core,supportedG),_supported];
						//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _SWunit)]]
						}
					};
				}
			forEach (_HQ getVariable [QEGVAR(core,medPoints),[]]);

			_noenemy = true;
			_halfway = [(((position _ambulance) select 0) + ((position _SWunit) select 0))/2,(((position _ambulance) select 1) + ((position _SWunit) select 1))/2];
			_distT = 500/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
			_eClose1 = [_SWunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
			_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
			if ((_eClose1) or (_eClose2)) then {_noenemy = false};

			if not ((group _SWunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then
				{
				_UL = leader (group _SWunit);
				if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_MedReq),"MedReq"] call EFUNC(common,AIChatter)}};
				};				

			if (not ((group _SWunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) and ((_SWunit distance _ambulance) <= _a) and (_noenemy) and (_x in _ambulances)) then 
				{
				if ((_a > 1500) and ((_airMedAv isNotEqualTo [])) and not (_x in _airMedAv)) exitWith {};
				if ((_a <= 1500) and ((_landMedAv isNotEqualTo [])) and not (_x in _landMedAv)) exitWith {};
				if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
				if (_x in _airMedAv) then {_airMedAv = _airMedAv - [_x]} else {_landMedAv = _landMedAv - [_x]};
				_ambulances = _ambulances - [_x];
				_SWunits = _SWunits - [_SWunit];
				
				_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
				_supported pushBack (group _SWunit);
				_HQ setVariable [QEGVAR(core,supportedG),_supported];
				
				//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _SWunit)]];
				//[_ambulance,_SWunit,_wounded,_HQ] spawn FUNC(goMedSupp); 
				[[_ambulance,_SWunit,_wounded,_HQ],FUNC(goMedSupp)] call EFUNC(common,spawn);
				}
			else
				{
				if (_a >= 44000) then 
					{
					if not ((group _SWunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
					_SWunits = _SWunits - [_SWunit]
					};
				};
			
			if (((_ambulances isEqualTo [])) or ((_SWunits isEqualTo []))) exitWith {};
			};
			
		if (((_ambulances isEqualTo [])) or ((_SWunits isEqualTo []))) exitWith {};
		}
	forEach _ambulances2;
	};

_Wunits = +_wounded;

for [{_a = 500},{_a < 10000},{_a = _a + 500}] do
	{
		{
		_ambulance = assignedVehicle (leader _x);
		for [{_b = 0},{_b < (count _wounded)},{_b = _b + 1}] do 
			{
			_Wunit = _wounded select _b;

				{
				if ((_Wunit distance (assignedVehicle (leader _x))) < 250) exitWith 
					{
					if not ((group _Wunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
						_supported pushBack (group _Wunit);
						_HQ setVariable [QEGVAR(core,supportedG),_supported];
						//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _Wunit)]]
						}
					};
				}
			forEach _medSG;

				{
				if ((_Wunit distance _x) < 250) exitWith 
					{
					if not ((group _Wunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then 
						{
						_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
						_supported pushBack (group _Wunit);
						_HQ setVariable [QEGVAR(core,supportedG),_supported];
						//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _Wunit)]]
						}
					};
				}
			forEach (_HQ getVariable [QEGVAR(core,medPoints),[]]);

			_noenemy = true;
			_halfway = [(((position _ambulance) select 0) + ((position _Wunit) select 0))/2,(((position _ambulance) select 1) + ((position _Wunit) select 1))/2];
			_distT = 600/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2));
			_eClose1 = [_Wunit,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);
			_eClose2 = [_halfway,(_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),_distT] call EFUNC(common,closeEnemy);				
			if ((_eClose1) or (_eClose2)) then {_noenemy = false};

			if not ((group _Wunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then
				{
				_UL = leader (group _Wunit);
				if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_MedReq),"MedReq"] call EFUNC(common,AIChatter)}};	
				};
			
			if (not ((group _Wunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) and ((_Wunit distance _ambulance) <= _a) and (_noenemy) and (_x in _ambulances)) then 
				{
				if ((_a > 2500) and ((_airMedAv isNotEqualTo [])) and not (_x in _airMedAv)) exitWith {};
				if ((_a <= 2500) and ((_landMedAv isNotEqualTo [])) and not (_x in _landMedAv)) exitWith {};
				if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppAss),"SuppAss"] call EFUNC(common,AIChatter)};
				if (_x in _airMedAv) then {_airMedAv = _airMedAv - [_x]} else {_landMedAv = _landMedAv - [_x]};
				_ambulances = _ambulances - [_x];
				_Wunits = _Wunits - [_Wunit];
				
				_supported = _HQ getVariable [QEGVAR(core,supportedG),[]];
				_supported pushBack (group _Wunit);
				_HQ setVariable [QEGVAR(core,supportedG),_supported];
				
				//_HQ setVariable ["RydHQ_SupportedG",(_HQ getVariable ["RydHQ_SupportedG",[]]) set [(count (_HQ getVariable ["RydHQ_SupportedG",[]])),(group _Wunit)]];
				//[_ambulance,_Wunit,_wounded,_HQ] spawn FUNC(goMedSupp); 
				[[_ambulance,_Wunit,_wounded,_HQ],FUNC(goMedSupp)] call EFUNC(common,spawn);
				}
			else
				{
				if (_a >= 10000) then 
					{
					if not ((group _Wunit) in (_HQ getVariable [QEGVAR(core,supportedG),[]])) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),GVAR(aIC_SuppDen),"SuppDen"] call EFUNC(common,AIChatter)}};
					_Wunits = _Wunits - [_Wunit]
					};
				};
			
			if (((_ambulances isEqualTo [])) or ((_Wunits isEqualTo []))) exitWith {};
			};
			
		if (((_ambulances isEqualTo [])) or ((_Wunits isEqualTo []))) exitWith {};
		}
	forEach _ambulances2;
	};
