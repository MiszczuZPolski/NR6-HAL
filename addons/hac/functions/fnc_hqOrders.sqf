#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQOrders.sqf

//kto si� nadaje do zwiadu, ataku i wsparcia
//cztery (albo tyle, ile cel�w) dywizje
//w kazdej recon i atak
//dodatkowo dywizja rezerwowa dla wzmocnienia ataku najbardziej udanego i oskrzydlenia reszty frontu
//wsparcie strategicznie - lotnictwo i artyleria

_SCRname = "Orders";

private ["_HQ","_nObj","_Trg","_vHQ","_landE","_dstMin","_dstAct","_dstMin","_PosObj1","_ReconAv","_onlyL","_unitvar","_busy","_Unable","_vehready","_solready","_effective","_ammo","_Gdamage",
	"_nominal","_current","_veh","_forRRes","_RRp","_AttackAv","_FlankAv","_exhausted","_inD","_ResC","_stages","_rcheckArr","_gps","_LMCUA","_reserve","_recvar","_resting","_allT",
	"_deployed","_capturing","_reconthreat","_FOthreat","_snipersthreat","_ATinfthreat","_AAinfthreat","_Infthreat","_Artthreat","_HArmorthreat","_LArmorthreat","_Carsthreat","_reconNr",
	"_Airthreat","_Navalthreat","_Staticthreat","_StaticAAthreat","_StaticATthreat","_Supportthreat","_Cargothreat","_Otherthreat","_GE","_GEvar","_checked","_FPool","_constant",
	"_isAttacked","_captCount","_captLimit","_forCapt","_groupCount","_LMCU","_WADone","_WAchance","_armored","_WAAv","_where","_heldBy","_howMuch","_AAO","_toTake",
	"_taken","_objectives","_BBAOObj","_IsAPlayer","_takenNav","_totakeNav","_forNavCapt","_Navalobjectives"];

_HQ = _this select 0;

_AAO = _HQ getVariable [QEGVAR(boss,chosenAAO),false];

_HQ setVariable [QEGVAR(core,defDone),false];

_distances = [];

_HQ setVariable [QGVAR(nearestE),objNull];

_nObj = _HQ getVariable [QEGVAR(core,nObj),1];
_BBAOObj = _HQ getVariable [QEGVAR(core,bBAOObj),1];

switch (_nObj) do
	{
	case (1) : {_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])]};
	case (2) : {_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])]};
	case (3) : {_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])]};
	default {_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])]};
	case (5) : {_HQ setVariable [QEGVAR(core,obj),(leader _HQ)]};
	};

//if (_HQ getVariable ["BBDEF",false]) then {_HQ setVariable ["RydHQ_Obj",objNull]};

_Trg = _HQ getVariable [QEGVAR(core,obj), (leader _HQ)];

_vHQ = vehicle (leader _HQ);

_landE = (_HQ getVariable [QEGVAR(common,knEnemiesG),[]]) - ((_HQ getVariable [QGVAR(enNavalG),[]]) + (_HQ getVariable [QEGVAR(boss,enAirG),[]]));
if ((_landE isNotEqualTo [])) then 
	{
	_HQ setVariable [QGVAR(nearestE),_landE select 0];
	_dstMin = (vehicle (leader (_landE select 0))) distance _vHQ;
	
		{
		_dstAct = (vehicle (leader _x)) distance _vHQ;
		if (_dstAct < _dstMin) then
			{
			_dstMin = _dstAct;
			_HQ setVariable [QGVAR(nearestE),_x];
			}
		
		}
	forEach _landE;

	_Trg = vehicle (leader (_HQ getVariable [QGVAR(nearestE),grpNull]));
	};

_ReconAv = [];
_onlyL = (_HQ getVariable [QEGVAR(boss,lArmorG),[]]) - (_HQ getVariable [QGVAR(mArmorG),[]]);

if not ((_HQ getVariable [QEGVAR(core,reconReserve),0]) > 0) then {_HQ setVariable [QGVAR(reconG),[]];};

	{
	if not (isNull _x) then
		{
		_unitvar = str _x;
		if (_HQ getVariable [QGVAR(orderfirst),true]) then {_x setVariable ["Nominal" + _unitvar,(count (units _x))]};
		_busy = false;
		_Unable = false;
		_busy = _x getVariable ("Busy" + _unitvar);
		_Unable = _x getVariable "Unable";
		if (isNil ("_Unable")) then {_Unable = false};
		if (isNil ("_busy")) then {_busy = false};
		_vehready = true;
		_solready = true;
		_effective = true;
		_ammo = true;
		_Gdamage = 0;

		_IsAPlayer = false;
		if (EGVAR(core,noRestPlayers) and (isPlayer (leader _x))) then {_IsAPlayer = true};
		
		if (([_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])] call EFUNC(common,ammoFullCount)) < 0.15) then 
			{
			_ammo = false
			}
		else
			{
				{
				_Gdamage = _Gdamage + (damage _x);
				if ((((magazines _x) isEqualTo [])) and (((isNull objectParent _x)) or ((vehicle _x) in (_HQ getVariable [QEGVAR(core,nCVeh),[]])))) exitWith {_ammo = false};
				if (((damage _x) > 0.5) or not (canStand _x)) exitWith {_effective = false};
				}
			forEach (units _x)
			};
			
		_nominal = _x getVariable ("Nominal" + (str _x));if (isNil "_nominal") then {_x setVariable ["Nominal" + _unitvar,(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
		_current = count (units _x);
		_Gdamage = _Gdamage + (_nominal - _current);

		if (((_Gdamage/(_current + 0.1)) > (0.4*(((_HQ getVariable [QEGVAR(core,recklessness),0.5])/1.2) + 1))) or not (_effective) or not (_ammo)) then 
			{
			_solready = false;
			if not (_ammo) then
				{
				_x setVariable ["LackAmmo",true]
				}
			};

		_ammo = 0;
		_veh = objNull;

			{
			_veh = assignedVehicle _x;
			if (not (isNull _veh) and (not (canMove _veh) or ((fuel _veh) <= 0.1) or ((damage _veh) > 0.5) or (((group _x) in (((_HQ getVariable [QEGVAR(core,airG),[]]) - ((_HQ getVariable [QEGVAR(boss,nCAirG),[]]) + (_HQ getVariable [QGVAR(rAirG),[]]))) + ((_HQ getVariable [QEGVAR(boss,hArmorG),[]]) + (_HQ getVariable [QEGVAR(boss,lArmorG),[]]) + ((_HQ getVariable [QEGVAR(boss,carsG),[]]) - ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]])))))) and (((magazines _veh) isEqualTo []))))) exitWith {_vehready = false};
			}
		forEach (units _x);

		if (_IsAPlayer) then {_vehready = true; _solready = true;};

		if (not (_x in (_ReconAv + (_HQ getVariable [QGVAR(specForG),[]]))) and not (_busy) and not (_Unable) and (_vehready) and ((_solready) or (_x in (_HQ getVariable [QGVAR(rAirG),[]])))) then {_ReconAv pushBack _x};
		}
	}
forEach (((_HQ getVariable [QGVAR(rAirG),[]]) + (_HQ getVariable [QGVAR(reconG),[]]) + (_HQ getVariable [QGVAR(fOG),[]]) + (_HQ getVariable [QGVAR(snipersG),[]]) + (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - ((_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,nCCargoG),[]])) + _onlyL) - ((_HQ getVariable [QEGVAR(core,noRecon),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]])));

_ReconAv = [_ReconAv] call EFUNC(common,randomOrd);

_ReconAv = _ReconAv - (_HQ getVariable [QEGVAR(core,aOnly),[]]);

if not (_HQ getVariable [QGVAR(chosenEBDoctrine),false]) then
	{
	if ((_HQ getVariable [QEGVAR(core,reconReserve),0]) > 0) then 
		{
		_forRRes = (_ReconAv - (_HQ getVariable [QGVAR(rAirG),[]]));
		for [{_b = 0},{_b < (floor ((count _forRRes)*(_HQ getVariable [QEGVAR(core,reconReserve),0])))},{_b = _b + 1}] do
			{
			_RRp = _forRRes select _b;
			_ReconAv = _ReconAv - [_RRp];
			}
		}
	};
		
_HQ setVariable [QGVAR(reconAv),_ReconAv];

_AttackAv = [];
_FlankAv = [];
_exhausted = _HQ getVariable [QEGVAR(core,exhausted),[]];

{

	if not (_x getVariable [("Resting" + (str _x)),false]) then {_exhausted = _exhausted - [_x]}
} forEach _exhausted;

	{
	if ((typeName _x) in [(typeName grpNull)]) then
		{
		if not (isNull _x) then
			{
			_unitvar = str _x;
			if (_HQ getVariable [QGVAR(orderfirst),true]) then {_x setVariable [("Nominal" + _unitvar),(count (units _x))]};
			_busy = false;
			_Unable = false;
			_busy = _x getVariable ("Busy" + _unitvar);
			_Unable = _x getVariable "Unable";
			if (isNil ("_Unable")) then {_Unable = false};
			if (isNil ("_busy")) then {_busy = false};
			_vehready = true;
			_solready = true;
			_effective = true;
			_ammo = true;
			_Gdamage = 0;

			_IsAPlayer = false;
			if (EGVAR(core,noRestPlayers) and (isPlayer (leader _x))) then {_IsAPlayer = true};
			
			if (([_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])] call EFUNC(common,ammoFullCount)) < 0.15) then 
				{
				_ammo = false
				}
			else
				{
					{
					_Gdamage = _Gdamage + (damage _x);
					if ((((magazines _x) isEqualTo [])) and (((isNull objectParent _x)) or ((vehicle _x) in (_HQ getVariable [QEGVAR(core,nCVeh),[]])))) exitWith {_ammo = false};
					if (((damage _x) > 0.5) or not (canStand _x)) exitWith {_effective = false};
					}
				forEach (units _x)
				};
				
			_nominal = _x getVariable ("Nominal" + (str _x));if (isNil "_nominal") then {_x setVariable ["Nominal" + _unitvar,(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
			_current = count (units _x);
			_Gdamage = _Gdamage + (_nominal - _current);
			if (((_Gdamage/(_current + 0.1)) > (0.4*(((_HQ getVariable [QEGVAR(core,recklessness),0.5])/1.2) + 1))) or not (_effective) or not (_ammo)) then {_solready = false};
			_ammo = 0;

				{
				_veh = assignedVehicle _x;
				if (not (isNull _veh) and (not (canMove _veh) or ((fuel _veh) <= 0.1) or ((damage _veh) > 0.5) or (((group _x) in (((_HQ getVariable [QEGVAR(core,airG),[]]) - (_HQ getVariable [QEGVAR(boss,nCAirG),[]])) + ((_HQ getVariable [QEGVAR(boss,hArmorG),[]]) + (_HQ getVariable [QEGVAR(boss,lArmorG),[]]) + ((_HQ getVariable [QEGVAR(boss,carsG),[]]) - ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]])))))) and (((magazines _veh) isEqualTo []))))) exitWith {_vehready = false};
				}
			forEach (units _x);

			if (_IsAPlayer) then {_vehready = true; _solready = true;};
			
			if (not (_x in _AttackAv) and not (_busy) and not (_Unable) and not (_x in _FlankAv) and (_vehready) and (_solready) and not (_x in ((_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,navalG),[]])))) then {_AttackAv pushBack _x};
			if (not (_x in _exhausted) and ((_HQ getVariable [QEGVAR(core,withdraw),1]) > 0) and not (_IsAPlayer) and (not (_vehready) or not (_solready))) then 
				{
				_exhausted pushBack _x;
				};
	 
			if (((_HQ getVariable [QEGVAR(core,withdraw),1]) > 0) and not (_x in ((_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QGVAR(snipersG),[]])))) then
				{
				_inD = _x getVariable "NearE";
				if (isNil "_inD") then {_inD = 0};
				if (not (_x in _exhausted) and (((random (2 + (_HQ getVariable [QEGVAR(core,recklessness),0.5]))) max 0.5) < (_inD * (_HQ getVariable [QEGVAR(core,withdraw),1])))) then 
					{
					_recvar = str _x;
					_resting = _x getVariable ("Resting" + _recvar);
					if (isNil ("_resting")) then {_resting = false};
					_Unable = _x getVariable "Unable";
					if (isNil ("_Unable")) then {_Unable = false};
					
					if (not (_resting) and not (_Unable) and not (_IsAPlayer)) then
						{
						[[_x,_HQ,true],EFUNC(hac,goRest)] call EFUNC(common,spawn);
						//_exhausted pushBack _x
						}
					}; 
				};
			}
		}
	}
forEach (((_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QGVAR(reconG),[]]) + (_HQ getVariable [QGVAR(fOG),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - (_HQ getVariable [QEGVAR(core,nCrewInfG),[]])) + (_HQ getVariable [QEGVAR(core,supportG),[]]))) - (_HQ getVariable [QEGVAR(core,noAttack),[]]));
_AttackAv = [_AttackAv] call EFUNC(common,randomOrd);

_AttackAv = _AttackAv - (_HQ getVariable [QEGVAR(core,rOnly),[]]);

if (_HQ getVariable [QGVAR(chosenEBDoctrine),false]) exitWith {[_HQ,_ReconAv,_AttackAv] call FUNC(hqOrdersEast)};

if ((_HQ getVariable [QEGVAR(core,attackReserve),0]) > 0) then 
	{
	for [{_g = 0},{_g < floor ((count _AttackAv)*(_HQ getVariable [QEGVAR(core,attackReserve),0.5]))},{_g = _g + 1}] do
		{
		_ResC = _AttackAv select _g;
		if (not (_ResC in (_HQ getVariable [QEGVAR(core,firstToFight),[]])) and not (isPlayer (leader _ResC))) then 
			{
			_AttackAv = _AttackAv - [_ResC];
			if not (_HQ getVariable [QEGVAR(core,flankingDone),false]) then {if ((random 100 > (30/(0.5 + (_HQ getVariable [QEGVAR(core,fineness),0.5])))) and not (_ResC in _FlankAv)) then {_FlankAv pushBack _ResC}}
			};
		}
	};

{
	if ((({alive _x} count (units _x)) == 0) or (_x == grpNull)) then {_exhausted = _exhausted - [_x]};
} forEach _exhausted;
	
_FlankAv = _FlankAv - ((_HQ getVariable [QEGVAR(core,noFlank),[]]) + (_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]));
_HQ setVariable [QGVAR(attackAv),_AttackAv];
_HQ setVariable [QGVAR(flankAv),_FlankAv];
_HQ setVariable [QGVAR(combatAv),_FlankAv + _AttackAv];
_HQ setVariable [QEGVAR(core,exhausted),_exhausted];
_timeStamp = _HQ getVariable [QGVAR(flankingTimeStamp),0];

if not (_HQ getVariable [QEGVAR(core,flankingInit),false]) then 
	{
	if not ((_HQ getVariable [QEGVAR(core,order),"ATTACK"]) == "DEFEND") then
		{
		if (_HQ getVariable [QGVAR(flankReady),false]) then
			{
			if ((_HQ getVariable [QGVAR(flankingTimeStamp),0]) == 0) then {_HQ setVariable [QGVAR(flankingTimeStamp),time]};
			_timeStamp = _HQ getVariable [QGVAR(flankingTimeStamp),0];
			if ((count (_HQ getVariable [QEGVAR(core,knEnemies),[]])) > 0) then
				{
				if not (_HQ getVariable [QEGVAR(core,defDone),false]) then
					{
					_obj = getPosATL (_HQ getVariable [QEGVAR(core,obj),(leader _HQ)]);

					if ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
						{
						_obj = _HQ getVariable [QEGVAR(core,eyeOfBattle),getPosATL (vehicle (leader _HQ))]
						};
				
					_gap = (time - _timeStamp) - (60 * (1 + ((vehicle (leader _HQ)) distance _obj)/1000));
					if (_gap > 0) then
						{
						_HQ setVariable [QEGVAR(core,flankingInit),true];
						[_HQ] call FUNC(flanking)
						}
					}
				}
			}
		}
	};
	
_toRecon = [_HQ getVariable QEGVAR(core,obj)];

if (_BBAOObj > 1) then {

	_toRecon = [_HQ getVariable QEGVAR(core,obj1),_HQ getVariable QEGVAR(core,obj2),_HQ getVariable QEGVAR(core,obj3),_HQ getVariable QEGVAR(core,obj4)];

	_toRecon resize _BBAOObj;

	if ((_HQ getVariable ["BBObj1Done",false]) and ((_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)]) in _toRecon)) then {_toRecon = _toRecon - [(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj2Done",false]) and ((_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)]) in _toRecon)) then {_toRecon = _toRecon - [(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj3Done",false]) and ((_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]) in _toRecon)) then {_toRecon = _toRecon - [(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj4Done",false]) and ((_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)]) in _toRecon)) then {_toRecon = _toRecon - [(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])]};
};

if (_nObj == 5) then {_toRecon = []};

//if (_toRecon isEqualTo [(leader _HQ)]) then {_toRecon = []};

_objectives = _HQ getVariable [QEGVAR(core,objectives),[]];

_stages = 3;
if ([] call EFUNC(common,isNight)) then {_stages = 5};

if ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
	{
	_taken = _HQ getVariable [QEGVAR(common,taken),[]];
	_toRecon = _objectives - _taken;

	_toRecon = [_toRecon,(leader _HQ),250000] call EFUNC(common,distOrdD);
	if ((_HQ getVariable [QEGVAR(core,maxSimpleObjs),5]) < (count _toRecon)) then {_toRecon resize (_HQ getVariable [QEGVAR(core,maxSimpleObjs),5])};

	if not (_HQ getVariable [QEGVAR(core,unlimitedCapt),false]) then
		{
		_allAttackers = 0;
			
			{
			_allAttackers = _allAttackers + (count (units _x))
			}
		forEach _AttackAv;

		/*

		while {(((_allAttackers/(_HQ getVariable ["RydHQ_CaptLimit",10])) < (count _toRecon)) or ((count _AttackAv) < (((1.5 + _stages) * (count _toRecon)))))} do
			{
			if ((count _toRecon) < 2) exitWith {};
			_toRecon resize ((count _toRecon) - 1)
			}
		*/
		}
	};

	
if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {EGVAR(core,allHQ) = EGVAR(core,allHQ) - [_HQ]};
	
if (((_HQ getVariable [QEGVAR(core,noRec),1]) * ((_HQ getVariable [QEGVAR(core,recklessness),0.5]) + 0.01)) < (random 100)) then 
	{
	if (((count (_HQ getVariable [QEGVAR(common,knEnemiesG),[]])) == 0) and not (_toRecon isEqualTo [(leader _HQ)])) then
		{
			{
			_HQ setVariable [QEGVAR(core,reconStage2),1];
			_reconNr = [_foreachIndex,_stages];
			_PosObj1 = getPosATL (vehicle _x);
			_rcheckArr = [(_HQ getVariable [QEGVAR(core,garrison),[]]),_ReconAv,_FlankAv,(_HQ getVariable [QEGVAR(core,noRecon),[]]),_exhausted,(_HQ getVariable [QEGVAR(core,nCCargoG),[]]),_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])];
			if (not ((count (_HQ getVariable [QGVAR(rAirG),[]])) == 0) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([(_HQ getVariable [QGVAR(rAirG),[]]),"R",_rcheckArr,200000,true] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,true],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			if (not ((count (_HQ getVariable [QGVAR(reconG),[]])) == 0) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([(_HQ getVariable [QGVAR(reconG),[]]),"R",_rcheckArr,50000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,true],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			if (not ((count (_HQ getVariable [QGVAR(fOG),[]])) == 0) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([(_HQ getVariable [QGVAR(fOG),[]]),"R",_rcheckArr,50000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,true],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			if (not ((count (_HQ getVariable [QGVAR(snipersG),[]])) == 0) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([(_HQ getVariable [QGVAR(snipersG),[]]),"R",_rcheckArr,50000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,true],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			_onlyL = (_HQ getVariable [QEGVAR(boss,lArmorG),[]]) - (_HQ getVariable [QGVAR(mArmorG),[]]);
			if (not ((_onlyL isEqualTo [])) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([_onlyL,"R",_rcheckArr,200000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,true],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			if (not ((count ((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QGVAR(specForG),[]]))) == 0) and ((count (_HQ getVariable [QGVAR(reconAv),[]])) > 0) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QGVAR(specForG),[]])),"NR",_rcheckArr,100000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					//[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false] spawn EFUNC(hac,goRecon);
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,false],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				};

			_LMCUA = (_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,noRecon),[]]) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]));
			if (not ((_LMCUA isEqualTo [])) and not (_HQ getVariable [QEGVAR(core,reconDone),false]) and not ((_HQ getVariable [QEGVAR(core,reconStage),1]) > (_stages * (count _toRecon)))) then
				{
				_gps = (([_LMCUA,"NR",_rcheckArr,200000,false] call EFUNC(common,recon)) - (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) - (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) - (_HQ getVariable [QEGVAR(core,artG),[]]));

					{
					if ((_HQ getVariable [QEGVAR(core,reconStage2),1]) > _stages) exitWith {};
					_HQ setVariable [QEGVAR(core,reconStage),(_HQ getVariable [QEGVAR(core,reconStage),1]) + 1];
					_HQ setVariable [QEGVAR(core,reconStage2),(_HQ getVariable [QEGVAR(core,reconStage2),1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable [QGVAR(reconAv),[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable [QGVAR(reconAv),_reconAv];
					//[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false] spawn EFUNC(hac,goRecon);
					[[_x,_PosObj1,(_HQ getVariable [QEGVAR(core,reconStage),1]),_HQ,_reconNr,false],EFUNC(hac,goRecon)] call EFUNC(common,spawn);
					}
				forEach _gps
				}
			}
		forEach _toRecon
		}
	}
else
	{
	_HQ setVariable [QEGVAR(core,reconDone),true]
	};
	
_reserve = (_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]) + (_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,airG),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - ((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]))));
if (not ((_HQ getVariable [QEGVAR(core,reconDone),false])) and ((count (_HQ getVariable [QEGVAR(core,knEnemies),[]])) == 0)) exitWith 
	{
	if (_HQ getVariable [QGVAR(orderfirst),true]) then 
		{
		_HQ setVariable [QGVAR(orderfirst),false]
		};

		{
		_recvar = str _x;
		_resting = false;
		_resting = _x getVariable ("Resting" + _recvar);
		if (isNil ("_resting")) then {_resting = false};
		_Unable = _x getVariable "Unable";
		if (isNil ("_Unable")) then {_Unable = false};
		_IsAPlayer = false;
		if (EGVAR(core,noRestPlayers) and (isPlayer (leader _x))) then {_IsAPlayer = true};
		if (not (_resting) and not (_Unable) and not (_IsAPlayer)) then 
			{
			//[_x,_HQ] spawn EFUNC(hac,goRest)
			[[_x,_HQ],EFUNC(hac,goRest)] call EFUNC(common,spawn);
			}
		}
	forEach ((_HQ getVariable [QEGVAR(core,exhausted),[]]) - ((_HQ getVariable [QEGVAR(core,airG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]])));

	if (_HQ getVariable [QEGVAR(core,idleOrd),true]) then
		{

			{
			_recvar = str _x;
			_busy = false;
			_Unable = false;
			_isDef = false;
			_deployed = false;
			_capturing = false;
			_capturing = _x getVariable ("Capt" + _recvar);
			if (isNil ("_capturing")) then {_capturing = false};
			_deployed = _x getVariable ("Deployed" + _recvar);
			_busy = _x getVariable ("Busy" + _recvar);
			_isDef = _x getVariable "Defending";
			_Unable = _x getVariable "Unable";
			if (isNil ("_Unable")) then {_Unable = false};
			if (isNil ("_isDef")) then {_isDef = false};
			if (isNil ("_busy")) then {_busy = false};
			if (isNil ("_deployed")) then {_deployed = false};
			if (not (_busy) and not (_Unable) and ((count (waypoints _x)) <= 1) and not (_deployed) and not (_isDef) and not (_capturing) and (not (_x in ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,airG),[]]))) or ((count (units _x)) > 1))) then 
				{
				deleteWaypoint ((waypoints _x) select 0);
				//[_x,_HQ] spawn EFUNC(hac,goIdle)

				if ((_HQ getVariable [QEGVAR(core,idleDef),true]) and not (isPlayer (leader _x)) and not ((_HQ getVariable [QEGVAR(common,taken),[]]) isEqualTo [])) then {
					[[_x,selectRandom (_HQ getVariable [QEGVAR(common,taken),[]]),_HQ],EFUNC(hac,goDefRes)] call EFUNC(common,spawn);
					} else {
					[[_x,_HQ],EFUNC(hac,goIdle)] call EFUNC(common,spawn);
					};
				};
			}
		forEach _reserve;
		}
	};

_HQ setVariable [QGVAR(flankReady),true];

_reconthreat = [];
_FOthreat = [];
_snipersthreat = [];
_ATinfthreat = [];
_AAinfthreat = [];
_Infthreat = [];
_Artthreat = [];
_HArmorthreat = [];
_LArmorthreat = [];
_LArmorATthreat = [];
_Carsthreat = [];
_Airthreat = [];
_Navalthreat = [];
_Staticthreat = [];
_StaticAAthreat = [];
_StaticATthreat = [];
_Supportthreat = [];
_Cargothreat = [];
_Otherthreat = [];

	{
	_GE = (group _x);
	_GEvar = str _GE;
	_checked = _GE getVariable ("Checked" + _GEvar);
	if (isNil ("_checked")) then {_GE setVariable [("Checked" + _GEvar),false]};
	_checked = false;

	if ((_x in (_HQ getVariable [QGVAR(enrecon),[]])) and not (_GE in _reconthreat) and not (_checked)) then {_reconthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enFO),[]])) and not (_GE in _FOthreat) and not (_checked)) then {_FOthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(ensnipers),[]])) and not (_GE in _snipersthreat) and not (_checked)) then {_snipersthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enATinf),[]])) and not (_GE in _ATinfthreat) and not (_checked)) then {_ATinfthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enAAinf),[]])) and not (_GE in _AAinfthreat) and not (_checked)) then {_AAinfthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enInf),[]])) and not (_GE in _Infthreat) and not (_checked)) then {_Infthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enArt),[]])) and not (_GE in _Artthreat) and not (_checked)) then {_Artthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enHArmor),[]])) and not (_GE in _LArmorthreat) and not (_checked)) then {_LArmorthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enLArmor),[]])) and not (_GE in _reconthreat) and not (_checked)) then {_reconthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enLArmorAT),[]])) and not (_GE in _LArmorATthreat) and not (_checked)) then {_LArmorATthreat pushBack _GE;};
	if ((_x in (_HQ getVariable [QGVAR(enCars),[]])) and not (_GE in _Carsthreat) and not (_checked)) then {_Carsthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enAir),[]])) and not (_GE in _Airthreat) and not (_checked)) then {_Airthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enNaval),[]])) and not (_GE in _Navalthreat) and not (_checked)) then {_Navalthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enStatic),[]])) and not (_GE in _Staticthreat) and not (_checked)) then {_Staticthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enStaticAA),[]])) and not (_GE in _StaticAAthreat) and not (_checked)) then {_StaticAAthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enStaticAT),[]])) and not (_GE in _StaticATthreat) and not (_checked)) then {_StaticATthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enSupport),[]])) and not (_GE in _Supportthreat) and not (_checked)) then {_Supportthreat pushBack _GE};
	if ((_x in (_HQ getVariable [QGVAR(enCargo),[]])) and not (_GE in _Cargothreat) and not (_checked)) then {_Cargothreat pushBack _GE};

	if ((_x in (_HQ getVariable [QGVAR(enInf),[]])) and ((vehicle _x) in (_HQ getVariable [QGVAR(enCargo),[]])) and not (_x in (_HQ getVariable [QGVAR(enCrew),[]])) and not (_GE in _Infthreat) and not (_checked)) then {_Infthreat pushBack _GE};

	if ((isNil ("_checked")) or not (_checked)) then {_GE setVariable [("Checked" + _GEvar), true]};
	}
forEach (_HQ getVariable [QEGVAR(core,knEnemies),[]]);

_HQ setVariable [QEGVAR(core,aAthreat),(_AAinfthreat + _StaticAAthreat)];
_HQ setVariable [QEGVAR(core,aTthreat),(_ATinfthreat + _StaticATthreat + _HArmorthreat + _LArmorATthreat)];
_HQ setVariable [QEGVAR(core,airthreat),_Airthreat];
_reconthreat = _reconthreat - _Airthreat;

_FPool = 
	[
	(_HQ getVariable [QGVAR(snipersG),[]]),
	(_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QGVAR(specForG),[]]),
	(_HQ getVariable [QEGVAR(core,airG),[]]) - ((_HQ getVariable [QEGVAR(boss,nCAirG),[]]) + (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]])),
	(_HQ getVariable [QEGVAR(boss,lArmorG),[]]),
	(_HQ getVariable [QEGVAR(boss,hArmorG),[]]),
	(_HQ getVariable [QEGVAR(boss,carsG),[]]) - ((_HQ getVariable [QEGVAR(tasking,aTInfG),[]]) + (_HQ getVariable [QEGVAR(tasking,aAInfG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,nCCargoG),[]])),
	(_HQ getVariable [QGVAR(lArmorATG),[]]),
	(_HQ getVariable [QEGVAR(tasking,aTInfG),[]]),
	(_HQ getVariable [QEGVAR(tasking,aAInfG),[]]),
	(_HQ getVariable [QEGVAR(core,recklessness),0.5]),
	(_HQ getVariable [QGVAR(attackAv),[]]),
	(_HQ getVariable [QEGVAR(core,garrison),[]]),
	(_HQ getVariable [QEGVAR(core,garrR),500]),
	(_HQ getVariable [QGVAR(flankAv),[]]),
	(_HQ getVariable [QEGVAR(core,airG),[]]),
	(_HQ getVariable [QEGVAR(core,nCVeh),[]]),
	(_HQ getVariable [QEGVAR(core,navalG),[]]),
	(_HQ getVariable [QEGVAR(core,rCAS),[]]),
	(_HQ getVariable [QEGVAR(core,rCAP),[]]),
	(_HQ getVariable [QGVAR(bAirG),[]])
	];

_constant = [(_HQ getVariable [QEGVAR(core,aAthreat),[]]),(_HQ getVariable [QEGVAR(core,aTthreat),[]]),_HArmorthreat + _LArmorATthreat,_FPool];

if (count (_reconthreat + _FOthreat + _snipersthreat) > 0) then 
	{
	([_reconthreat + _FOthreat + _snipersthreat,"Recon",_HQ,0,0,0] + _constant) call FUNC(dispatcher);
	};

if (_ATinfthreat isNotEqualTo []) then 
	{
	([_ATinfthreat,"ATInf",_HQ,0,0,85] + _constant) call FUNC(dispatcher);
	};

if (_Infthreat isNotEqualTo []) then 
	{
	([_Infthreat,"Inf",_HQ,75,80,85] + _constant) call FUNC(dispatcher);
	};

if (count (_LArmorthreat + _HArmorthreat) > 0) then 
	{
	([_LArmorthreat + _HArmorthreat,"Armor",_HQ,50,0,85] + _constant) call FUNC(dispatcher);
	};

if (_Carsthreat isNotEqualTo []) then 
	{
	([_Carsthreat,"Cars",_HQ,75,80,85] + _constant) call FUNC(dispatcher);
	};

if (_Artthreat isNotEqualTo []) then 
	{
	([_Artthreat,"Art",_HQ,70,75,75] + _constant) call FUNC(dispatcher);
	};

if (_Airthreat isNotEqualTo []) then 
	{
	([_Airthreat,"Air",_HQ,0,0,75] + _constant) call FUNC(dispatcher);
	};

if (count (_Staticthreat - _Artthreat) > 0) then 
	{
	([_Staticthreat - _Artthreat,"Static",_HQ,75,80,85] + _constant) call FUNC(dispatcher);
	};

if (_Navalthreat isNotEqualTo []) then 
	{
	([_Navalthreat,"Naval",_HQ,0,0,0] + _constant) call FUNC(dispatcher);
	};

/////////////////////////////////////////
// Capture Objective

_toTake = [_HQ getVariable QEGVAR(core,obj)];

if (_BBAOObj > 1) then {

	_toTake = [_HQ getVariable QEGVAR(core,obj1),_HQ getVariable QEGVAR(core,obj2),_HQ getVariable QEGVAR(core,obj3),_HQ getVariable QEGVAR(core,obj4)];

	_toTake resize _BBAOObj;

	if ((_HQ getVariable ["BBObj1Done",false]) and ((_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)]) in _toTake)) then {_toTake = _toTake - [(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj2Done",false]) and ((_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)]) in _toTake)) then {_toTake = _toTake - [(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj3Done",false]) and ((_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]) in _toTake)) then {_toTake = _toTake - [(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])]};
	if ((_HQ getVariable ["BBObj4Done",false]) and ((_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)]) in _toTake)) then {_toTake = _toTake - [(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])]};
};

if (_nObj == 5) then {_toTake = []};

//if (_toTake isEqualTo [(leader _HQ)]) then {_toTake = []};

if ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
	{
	_taken = _HQ getVariable [QEGVAR(common,taken),[]]; 
	_toTake = _objectives - _taken;

	_toTake = [_toTake,(leader _HQ),250000] call EFUNC(common,distOrdD);
	if ((_HQ getVariable [QEGVAR(core,maxSimpleObjs),5]) < (count _toTake)) then {_toTake resize (_HQ getVariable [QEGVAR(core,maxSimpleObjs),5])};
	
		{
		if not (_x in _toRecon) then
			{
			_toTake set [_foreachIndex,objNull];
			}
		}
	forEach _toTake;
	
	_toTake = _toTake - [objNull];
		
	_allAttackers = 0;
		
		{
		_allAttackers = _allAttackers + (count (units _x))
		}
	forEach _AttackAv;

	/*			
	while {(((_allAttackers/(_HQ getVariable ["RydHQ_CaptLimit",10])) < (count _toTake)) or ((count _AttackAv) < ((1.5 * (count _toTake)))))} do
		{
		if ((count _toTake) < 2) exitWith {};
		_toTake resize ((count _toTake) - 1)
		}
	*/
	};
	
	{
	if (isNil {_x}) then {_toTake set [_foreachIndex,objNull]};
	}
forEach _toTake;

_toTake = _toTake - [objNull];
	
	{
	_Trg = _x;

	if not ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
		{
			{
			_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]
			}
		forEach (_objectives - [(_HQ getVariable [QEGVAR(core,obj),nil])]);
		};

	_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));

	if (isNil ("_isAttacked")) then {_isAttacked = [0,0]};

	_captCount = _isAttacked select 1;
	_isAttacked = _isAttacked select 0;
	_captLimit = (_HQ getVariable [QEGVAR(core,captLimit),10]) * (1 + ((_HQ getVariable [QEGVAR(core,circumspection),0.5])/(2 + (_HQ getVariable [QEGVAR(core,recklessness),0.5]))));
	if ((_isAttacked <= 3) or (_captCount < _captLimit)) then
		{
		_allT = _HQ getVariable [QEGVAR(core,nObj),1];
		if ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
			{
			_allT = ((count _taken)/(count _objectives))*5
			};
		
		if  ((not (_allT >= 5) and ((random 100) > ((count (_HQ getVariable [QEGVAR(core,knEnemies),[]]))*(5/(0.5 + (2*(_HQ getVariable [QEGVAR(core,recklessness),0.5])))))) and  
				(_HQ getVariable [QEGVAR(core,reconDone),false])) or
					((((_HQ getVariable [QEGVAR(core,rapidCapt),10]) * ((_HQ getVariable [QEGVAR(core,recklessness),0.5]) + 0.01)) > (random 100)) and ((_HQ getVariable [QEGVAR(core,nObj),1]) <= 4))) then   
			{
			_checked = [];
			_forCapt = (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - ((_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,garrison),[]]));
			_forCapt = _forCapt - ((_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]));
			_forCapt = [_forCapt] call EFUNC(common,sizeOrd);

			if (not ((_forCapt isEqualTo [])) and ((count (_HQ getVariable [QGVAR(attackAv),[]])) > 0) and not (_toTake isEqualTo [(leader _HQ)])) then
				{
				for [{_m = 500},{_m <= 50000},{_m = _m + 500}] do
					{
					_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
					if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
					_captCount = _isAttacked select 1;
					_isAttacked = _isAttacked select 0;

					if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

						{
						_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
						if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
						_captCount = _isAttacked select 1;
						_isAttacked = _isAttacked select 0;

						if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

						if (_x in (_HQ getVariable [QGVAR(attackAv),[]])) then
							{

							if (((leader _x) distance _Trg) <= _m) then
								{
								if (not (_x in (_HQ getVariable [QEGVAR(core,nCCargoG),[]])) or ((count (units _x)) > 1)) then 
									{
									_ammo = [_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])] call EFUNC(common,ammoCount);

									if (_ammo > 0) then
										{
										_busy = _x getVariable [("Busy" + (str _x)),false];
										_Unable = _x getVariable ["Unable",false];

										if (not (_busy) and not (_Unable)) then
											{
											_x setVariable [("Busy" + (str _x)),true];
											_HQ setVariable [QGVAR(attackAv),(_HQ getVariable [QGVAR(attackAv),[]]) - [_x]];
											_checked pushBack _x;
											_groupCount = count (units _x);

											switch (_isAttacked) do
												{
												case (4) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[5,_captCount + _groupCount]]};
												case (3) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[4,_captCount + _groupCount]]};
												case (2) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[3,_captCount + _groupCount]]};
												case (1) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[2,_captCount + _groupCount]]};
												case (0) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[1,_captCount + _groupCount]]};
												};

											//[_x,_isAttacked,_HQ,_Trg] spawn EFUNC(hac,goCapture);
											[[_x,_isAttacked,_HQ,_Trg],EFUNC(hac,goCapture)] call EFUNC(common,spawn);
											}
										}
									}
								}
							}
						}
					forEach _forCapt;
					_forCapt = _forCapt - _checked
					}
				};

			if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

			_LMCU = (_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QEGVAR(core,exhausted),[]]) + ((_HQ getVariable [QEGVAR(core,airG),[]]) - (_HQ getVariable [QEGVAR(core,nCrewInfG),[]])) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,garrison),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - ((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QEGVAR(core,supportG),[]]))));
			_LMCU = _LMCU - ((_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]));
			_LMCU = [_LMCU] call EFUNC(common,sizeOrd);
			if (not ((_LMCU isEqualTo [])) and ((count (_HQ getVariable [QGVAR(attackAv),[]])) > 0) and not (_toRecon isEqualTo [(leader _HQ)])) then
				{
				for [{_m = 1000},{_m <= 200000},{_m = _m + 1000}] do
					{
					_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
					if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
					_captCount = _isAttacked select 1;
					_isAttacked = _isAttacked select 0;
					if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

						{
						_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
						if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
						_captCount = _isAttacked select 1;
						_isAttacked = _isAttacked select 0;

						if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};
						if (_x in (_HQ getVariable [QGVAR(attackAv),[]])) then
							{
							if (((leader _x) distance _Trg) <= _m) then
								{
								_ammo = [_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])] call EFUNC(common,ammoCount);
								if (_ammo > 0) then
									{
									_busy = _x getVariable [("Busy" + (str _x)),false];
									_Unable = _x getVariable ["Unable",false];

									if (not (_busy) and not (_Unable)) then
										{
										_x setVariable [("Busy" + (str _x)),true];
										_HQ setVariable [QGVAR(attackAv),(_HQ getVariable [QGVAR(attackAv),[]]) - [_x]];
										_checked pushBack _x;
										_groupCount = count (units _x);

										switch (_isAttacked) do
											{
											case (4) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[5,_captCount + _groupCount]]};
											case (3) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[4,_captCount + _groupCount]]};
											case (2) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[3,_captCount + _groupCount]]};
											case (1) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[2,_captCount + _groupCount]]};
											case (0) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[1,_captCount + _groupCount]]};
											};

										//[_x,_isAttacked,_HQ,_Trg] spawn EFUNC(hac,goCapture);
										[[_x,_isAttacked,_HQ,_Trg],EFUNC(hac,goCapture)] call EFUNC(common,spawn);
										}
									}
								}
							}
						}
					forEach _LMCU;
					_LMCU = _LMCU - _checked
					}
				}
			}
		}
	}
forEach _toTake;

// NAVAL OBJECTIVES

_Navalobjectives = _HQ getVariable [QEGVAR(core,navalObjectives),[]];
_toTakeNav = [];

if (((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false]))) then
	{
	_takenNav = _HQ getVariable [QGVAR(takenNaval),[]]; 
	_toTakeNav = _Navalobjectives - _takenNav;

	_toTakeNav = [_toTakeNav,(leader _HQ),250000] call EFUNC(common,distOrdD);
	if ((_HQ getVariable [QGVAR(maxNavalObjs),5]) < (count _toTakeNav)) then {_toTakeNav resize (_HQ getVariable [QGVAR(maxNavalObjs),5])};
		
/*	_allAttackers = 0;
		
		{
		_allAttackers = _allAttackers + (count (units _x))
		}
	foreach _AttackAvNav;
*/

	};
	
	{
	if (isNil {_x}) then {_toTakeNav set [_foreachIndex,objNull]};
	}
forEach _toTakeNav;

_toTakeNav = _toTakeNav - [objNull];
	
	{
	_Trg = _x;

	_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));

	if (isNil ("_isAttacked")) then {_isAttacked = [0,0]};

	_captCount = _isAttacked select 1;
	_isAttacked = _isAttacked select 0;
	_captLimit = 1 * (1 + ((_HQ getVariable [QEGVAR(core,circumspection),0.5])/(2 + (_HQ getVariable [QEGVAR(core,recklessness),0.5]))));
	if ((_isAttacked <= 3) or (_captCount < _captLimit)) then
		{
		_allT = 5;
		if ((_AAO) or (_HQ getVariable [QEGVAR(core,simpleMode),false])) then
			{
			_allT = ((count _taken)/(count _Navalobjectives))*5
			};
		
		if ((not (_allT >= 5) and ((random 100) > ((count (_HQ getVariable [QGVAR(enNaval),[]]))*(5/(0.5 + (2*(_HQ getVariable [QEGVAR(core,recklessness),0.5])))))) and 
				(true)) or
					((((_HQ getVariable [QEGVAR(core,rapidCapt),10]) * ((_HQ getVariable [QEGVAR(core,recklessness),0.5]) + 0.01)) > (random 100)) and ((_HQ getVariable [QEGVAR(core,nObj),1]) <= 4))) then   
			{
			_checked = [];
			_forNavCapt = (_HQ getVariable [QEGVAR(core,navalG),[]]) - ((_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,garrison),[]]));
			_forNavCapt = _forNavCapt - ((_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]));
			_forNavCapt = [_forNavCapt] call EFUNC(common,sizeOrd);

			if (not ((_forNavCapt isEqualTo []))) then
				{
				for [{_m = 500},{_m <= 50000},{_m = _m + 500}] do
					{
					_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
					if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
					_captCount = _isAttacked select 1;
					_isAttacked = _isAttacked select 0;

					if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

						{
						_isAttacked = _Trg getVariable ("Capturing" + (str _Trg) + (str _HQ));
						if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
						_captCount = _isAttacked select 1;
						_isAttacked = _isAttacked select 0;

						if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitWith {};

						if (true) then
							{

							if (((vehicle (leader _x)) distance _Trg) <= _m) then
								{
								if (not (_x in (_HQ getVariable [QEGVAR(core,nCCargoG),[]])) or ((count (units _x)) > 1)) then 
									{
									_ammo = [_x,(_HQ getVariable [QEGVAR(core,nCVeh),[]])] call EFUNC(common,ammoCount);

									if (_ammo > 0) then
										{
										_busy = _x getVariable [("Busy" + (str _x)),false];
										_Unable = _x getVariable ["Unable",false];

										if (not (_busy) and not (_Unable)) then
											{
											_x setVariable [("Busy" + (str _x)),true];
											_HQ setVariable [QGVAR(attackAv),(_HQ getVariable [QGVAR(attackAv),[]]) - [_x]];
											_checked pushBack _x;
											_groupCount = count (units _x);

											switch (_isAttacked) do
												{
												case (4) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[5,_captCount + _groupCount]]};
												case (3) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[4,_captCount + _groupCount]]};
												case (2) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[3,_captCount + _groupCount]]};
												case (1) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[2,_captCount + _groupCount]]};
												case (0) : {_Trg setVariable [("Capturing" + (str  _Trg) + (str _HQ)),[1,_captCount + _groupCount]]};
												};

											[[_x,_isAttacked,_HQ,_Trg],EFUNC(hac,goCaptureNaval)] call EFUNC(common,spawn);
											}
										}
									}
								}
							}
						}
					forEach _forNavCapt;
					_forNavCapt = _forNavCapt - _checked
					}
				};
			}
		}
	}
forEach _toTakeNav;

/*if (_HQ getVariable ["RydHQ_WA",true]) then
	{
	_WADone = _HQ getVariable ["RydHQ_WADone",0];
	_WAchance = ((1 + (_HQ getVariable ["RydHQ_Activity",0.5]) + (_HQ getVariable ["RydHQ_Recklessness",0.5]))^2)/(10 + (10 * (_WADone^2)));

	if (_WAchance > (random 1)) then
		{
		_armored = (_HQ getVariable [QEGVAR(boss,hArmorG),[]]) + (_HQ getVariable [QEGVAR(boss,lArmorG),[]]);
		_LMCU = (_HQ getVariable [QEGVAR(core,friends),[]]) - (((_HQ getVariable [QEGVAR(core,airG),[]]) - (_HQ getVariable [QEGVAR(core,nCrewInfG),[]])) + (_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,noAttack),[]]) + (_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,garrison),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - ((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QEGVAR(core,supportG),[]]))));
		
		_WAAv = [];
		
			{
			if not (_x getVariable ["Busy" + (str _x),false]) then
				{
				_WAAv pushBack _x
				}
			}
		foreach _LMCU;
		
		if ((_WAAv isEqualTo [])) exitWith {};
		
		_WAAv = [_WAAv] call EFUNC(common,randomOrd);
		
		_where = [];
		
			{
			_heldBy = _x getVariable ["RydHQ_HeldBy",0];
			if not (_heldBy > ((random 4) * (0.5 + (_HQ getVariable ["RydHQ_Consistency",0.5])))) then
				{
				if (((1 + (_HQ getVariable ["RydHQ_Consistency",0.5]) + (_HQ getVariable ["RydHQ_Fineness",0.5]))/4) > (random 1)) then
					{
					_where pushBack _x
					}
				}
			}
		foreach [(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])];
		
		if ((_where isEqualTo [])) then {_where = [(_HQ getVariable ["RydHQ_Obj",(leader _HQ)])]};
		
		_howMuch = ((_HQ getVariable ["RydHQ_Recklessness",[]]) + (random 0.5))/1.5;
		if (_howMuch > 1) then {_howMuch = 1};
		_howMuch = floor (_howMuch * (count _WAAv));
		
		while {((_howMuch > 0) and ((_WAAv isNotEqualTo [])))} do
			{
				{
				_gp = _WAAv select 0;
				// TODO Phase 6+: HAL_GoHoldInf/HAL_GoHoldArmor targets missing in hal_hac — pre-existing bug, not introduced by this plan.
				// These handles were NOT in compat_nr6hal Part A and no fnc_goHoldInf/fnc_goHoldArmor exist in addons/hac/functions/.
				// The block below is disabled until the functions are implemented.
				//_code = EFUNC(hac,goHoldInf);
				//if (_gp in _armored) then {_code = EFUNC(hac,goHoldArmor)};
				_WAAv = _WAAv - [_gp];
				_gp setVariable ["Busy" + (str _gp),true];

				//[_gp,_x] spawn _code;
				
				_howMuch = _howMuch - 1;
				
				if ((_howMuch < 1) or ((count _WAAv) < 1)) exitWith {}
				}
			foreach _where
			}
		}
	};*/
		
if (_HQ getVariable [QEGVAR(core,idleOrd),true]) then
	{
	_reserve = (_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QGVAR(specForG),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]) + (_HQ getVariable [QEGVAR(core,noRecon),[]]) + (_HQ getVariable [QEGVAR(core,noAttack),[]]) + (_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,airG),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - (_HQ getVariable [QEGVAR(core,nCrewInfG),[]])));

		{
		_recvar = str _x;
		_busy = false;
		_Unable = false;
		_deployed = false;
		_capturing = false;
		_capturing = _x getVariable ("Capt" + _recvar);
		if (isNil ("_capturing")) then {_capturing = false};
		_deployed = _x getVariable ("Deployed" + _recvar);
		_isDef = _x getVariable "Defending";
		_busy = _x getVariable ("Busy" + _recvar);
		_Unable = _x getVariable "Unable";
		if (isNil ("_Unable")) then {_Unable = false};
		if (isNil ("_isDef")) then {_isDef = false};
		if (isNil ("_busy")) then {_busy = false};
		if (isNil ("_deployed")) then {_deployed = false};
		if (not (_busy) and not (_Unable) and ((count (waypoints _x)) <= 1) and not (_deployed) and not (_isDef) and not (_capturing) and (not (_x in ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) + (_HQ getVariable [QEGVAR(core,supportG),[]]) + (_HQ getVariable [QEGVAR(core,airG),[]]))) or ((count (units _x)) > 1))) then 
			{
			deleteWaypoint ((waypoints _x) select 0);
			//[_x,_HQ] spawn EFUNC(hac,goIdle)

			if ((_HQ getVariable [QEGVAR(core,idleDef),true]) and not (isPlayer (leader _x)) and not ((_HQ getVariable [QEGVAR(common,taken),[]]) isEqualTo [])) then {
				[[_x,selectRandom (_HQ getVariable [QEGVAR(common,taken),[]]),_HQ],EFUNC(hac,goDefRes)] call EFUNC(common,spawn);
				} else {
				[[_x,_HQ],EFUNC(hac,goIdle)] call EFUNC(common,spawn);
				};
			};
		}
	forEach _reserve;

		{
		_recvar = str _x;
		_busy = false;
		_Unable = false;
		_deployed = false;
		_capturing = false;
		_capturing = _x getVariable ("Capt" + _recvar);
		if (isNil ("_capturing")) then {_capturing = false};
		_deployed = _x getVariable ("Deployed" + _recvar);
		_isDef = _x getVariable "Defending";
		_busy = _x getVariable ("Busy" + _recvar);
		_Unable = _x getVariable "Unable";
		if (isNil ("_Unable")) then {_Unable = false};
		if (isNil ("_isDef")) then {_isDef = false};
		if (isNil ("_busy")) then {_busy = false};
		if (isNil ("_deployed")) then {_deployed = false};
		if (not (_busy) and not (_Unable) and ((count (waypoints _x)) <= 1) and not (_deployed) and not (_isDef) and not (_capturing) and (not (_x in (_HQ getVariable [QEGVAR(core,nCCargoG),[]])) or ((count (units _x)) > 1))) then 
			{
			deleteWaypoint ((waypoints _x) select 0);
			//[_x,_HQ] spawn EFUNC(hac,goIdle)

			if ((_HQ getVariable [QEGVAR(core,idleDef),true]) and not (isPlayer (leader _x)) and not ((_HQ getVariable [QGVAR(takenNaval),[]]) isEqualTo [])) then {
				[[_x,selectRandom (_HQ getVariable [QGVAR(takenNaval),[]]),_HQ],EFUNC(hac,goDefNav)] call EFUNC(common,spawn);
				};
			};
		}
	forEach (_HQ getVariable [QEGVAR(core,navalG),[]]);

	};

	{
	_recvar = str _x;
	_resting = false;
	_Unable = false;
	_resting = _x getVariable ("Resting" + _recvar);
	if (isNil ("_resting")) then {_resting = false};
	_Unable = _x getVariable "Unable";
	if (isNil ("_Unable")) then {_Unable = false};
	_IsAPlayer = false;
	if (EGVAR(core,noRestPlayers) and (isPlayer (leader _x))) then {_IsAPlayer = true};
	if (not (_resting) and not (_Unable) and not (_IsAPlayer)) then 
		{
		if not (_x in (_HQ getVariable [QEGVAR(core,garrison),[]])) then
			{
			//[_x,_HQ] spawn EFUNC(hac,goRest)
			[[_x,_HQ],EFUNC(hac,goRest)] call EFUNC(common,spawn);
			}
		}
	}
forEach ((_HQ getVariable [QEGVAR(core,exhausted),[]]) - ((_HQ getVariable [QEGVAR(core,airG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]]) + (_HQ getVariable [QEGVAR(core,navalG),[]])));


	{
	_GE = (group _x);
	_GEvar = str _GE;
	_GE setVariable [("Checked" + _GEvar),false];
	}
forEach (_HQ getVariable [QEGVAR(core,knEnemies),[]]);

if (_HQ getVariable [QGVAR(orderfirst),true]) then {_HQ setVariable [QGVAR(orderfirst),false]};
