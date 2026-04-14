#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQReset.sqf

_SCRname = "Reset";

private ["_HQ","_Edistance","_LE","_LEvar","_trg","_mLoss","_lastObj","_lost","_AllV20","_Civs20","_AllV2","_Civs20","_Civs2","_NearEnemies","_AllV0","_Civs0","_AllV","_Civs","_NearAllies","_objectives",
	"_captLimit","_enRoute","_captDiff","_isC","_amountC","_reserve","_exhausted","_unitvar","_nominal","_current","_ex","_Aex","_unitvarA","_nominalA","_currentA","_AAO","_taken","_cTaken","_oTaken",
	"_garrPool","_UnableArr","_noGarrAround","_fG","_chosen","_dstMin","_actDst","_actG","_code","_unitG","_ct","_MIAPass","_garrison","_setTaken","_SideAllies","_SideEnemies","_Navaltaken","_Navalobjectives"];

_HQ = _this select 0;

_AAO = _HQ getVariable [QEGVAR(boss,chosenAAO),false];
		
_Edistance = false;

	{
	if ((_x distance (_HQ getVariable ["leaderHQ",leader _HQ])) < 2000) exitWith {_Edistance = true};
	}
forEach (_HQ getVariable [QEGVAR(core,knEnemies),[]]);
_HQ setVariable [QEGVAR(core,reconDone),false];
_HQ setVariable [QEGVAR(core,reconStage),1];

if (_Edistance) then
	{
		{
		_LE = (leader _x);
		_LEvar = str _LE;
		_LE setVariable [("Checked" + _LEvar), false]
		}
	forEach ((_HQ getVariable [QGVAR(enemies),[]]) - (_HQ getVariable [QEGVAR(common,knEnemiesG),[]]))
	};

_HQ setVariable [QEGVAR(core,defDone),false];
/*
if (not ((_HQ getVariable ["RydHQ_Order","ATTACK"]) == "DEFEND") or ((random 100) > 95)) then 
	{
		{
		_x setVariable ["Defending", false];
		_x setvariable ["SPRTD",0];
		_x setvariable ["Reinforcing",GrpNull];
		}
	foreach (_HQ getVariable ["RydHQ_Friends",[]])
	};
*/
_trg = _HQ getVariable ["leaderHQ",(leader _HQ)];
_nObj = _HQ getVariable [QEGVAR(core,nObj),1];

_objectives = [(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])];
_Navalobjectives = [];

if (_HQ getVariable [QEGVAR(core,simpleMode),false]) then {

	_objectives = _HQ getVariable [QEGVAR(core,objectives),[]];
	_Navalobjectives = _HQ getVariable [QEGVAR(core,navalObjectives),[]];

};

switch (_nObj) do
	{
	case (1) : {_trg = _HQ getVariable [QEGVAR(core,obj1),(leader _HQ)];_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])]};
	case (2) : {_trg = _HQ getVariable [QEGVAR(core,obj2),(leader _HQ)];_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])]};
	case (3) : {_trg = _HQ getVariable [QEGVAR(core,obj3),(leader _HQ)];_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])]};
	default {_trg = _HQ getVariable [QEGVAR(core,obj4),(leader _HQ)];_HQ setVariable [QEGVAR(core,obj),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])]};
	};

_mLoss = 10;
if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs)) then {_mLoss = 0};

_lastObj = _HQ getVariable [QEGVAR(core,nObj),1];

_lost = objNull;
_taken = _HQ getVariable [QEGVAR(common,taken),[]];
_Navaltaken = _HQ getVariable [QGVAR(takenNaval),[]];

{
	if not (_x in _objectives) then {_taken = _taken - [_x]}
} forEach _taken;

{
	if not (_x in _Navalobjectives) then {_Navaltaken = _Navaltaken - [_x]}
} forEach _Navaltaken;

{
	if (_x getVariable ["PatrolPoint",false]) then {
		_objectives = _objectives - [_x];
		if not (_x in _taken) then {_taken pushBack _x};
		};
} forEach _objectives;

{
	if (_x getVariable ["PatrolPoint",false]) then {
		_Navalobjectives = _Navalobjectives - [_x];
		if not (_x in _Navaltaken) then {_Navaltaken pushBack _x};
		};
} forEach _Navalobjectives;

_oTaken = +_taken;
_cTaken = count _taken;

_SideAllies = [];
_SideEnemies = [];

{
	if (((side _HQ) getFriend _x) >= 0.6) then {_SideAllies pushBack _x} else {_SideEnemies pushBack _x};
} forEach [west,east,resistance];


	{

	if ((_HQ getVariable [QEGVAR(core,simpleMode),false]) and not (EGVAR(missionmodules,active))) then {_trg = _x};

	_AllV20 = _x nearEntities [["AllVehicles"],(_HQ getVariable [QEGVAR(core,objRadius1),300])];
	_Civs20 = _x nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius1),300])];

	_AllV2 = [];

		{
		_AllV2 = _AllV2 + (crew _x)
		}
	forEach _AllV20;

	_Civs20 = _trg nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];

	_Civs2 = [];

		{
		_Civs2 = _Civs2 + (crew _x)
		}
	forEach _Civs20;

	_AllV2 = _AllV2 - _Civs2;

	_AllV20 = +_AllV2;

		{
		if not (_x isKindOf "Man") then
			{
			if (((crew _x) isEqualTo [])) then {_AllV2 = _AllV2 - [_x]}
			}
		}
	forEach _AllV20;

//	_NearEnemies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countenemy _AllV2;
	_NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);
	_AllV0 = _x nearEntities [["AllVehicles"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];
	_Civs0 = _x nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];

	_AllV = [];

		{
		_AllV = _AllV + (crew _x)
		}
	forEach _AllV0;

	_Civs = [];

		{
		_Civs = _Civs + (crew _x)
		}
	forEach _Civs0;

	_AllV = _AllV - _Civs;
	_AllV0 = +_AllV;

		{
		if not (_x isKindOf "Man") then
			{
			if (((crew _x) isEqualTo [])) then {_AllV = _AllV - [_x]}
			}
		}
	forEach _AllV0;

//	_NearAllies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countfriendly _AllV;
	_NearAllies = ({(side _x) in _SideAllies} count _AllV);

	if (_x == _trg) then
		{
		_captLimit = (_HQ getVariable [QEGVAR(core,captLimit),10]) * (1 + ((_HQ getVariable [QEGVAR(core,circumspection),0.5])/(2 + (_HQ getVariable [QEGVAR(core,recklessness),0.5]))));
		_enRoute = 0;

			{
			if not (isNull _x) then
				{
				if (_x getVariable [("Capt" + (str _x)),false]) then
					{
					_enRoute = _enRoute + (count (units _x))
					}
				}
			}
		forEach (_HQ getVariable [QEGVAR(core,friends),[]]);

		_captDiff = _captLimit - _enRoute;

		if (_captDiff > 0) then
			{	
			_isC = _trg getVariable ("Capturing" + (str _trg) + (str _HQ));if (isNil "_isC") then {_isC = [0,0]};

			_amountC = _isC select 1;
			_isC = _isC select 0;
			if (_isC > 3) then {_isC = 3};
			_trg setVariable [("Capturing" + (str _trg) + (str _HQ)),[_isC,_amountC - _captDiff]];
			}
		};

	if (not (_HQ getVariable [QEGVAR(core,unlimitedCapt),false]) and (_NearAllies >= (_HQ getVariable [QEGVAR(core,captLimit),10])) and (_NearEnemies < (_NearAllies*0.25))) then {
		_taken pushBackUnique _x;
	};

	if ((_NearEnemies > _NearAllies) and not (_AAO)) exitWith {_lost = _x};
	if (_NearEnemies > _NearAllies) then {
		_taken = _taken - [_x];
		if ((str (leader _HQ)) == "LeaderHQ") then {_x setVariable ["SetTakenA",false]};
		if ((str (leader _HQ)) == "LeaderHQB") then {_x setVariable ["SetTakenB",false]};
		if ((str (leader _HQ)) == "LeaderHQC") then {_x setVariable ["SetTakenC",false]};
		if ((str (leader _HQ)) == "LeaderHQD") then {_x setVariable ["SetTakenD",false]};
		if ((str (leader _HQ)) == "LeaderHQE") then {_x setVariable ["SetTakenE",false]};
		if ((str (leader _HQ)) == "LeaderHQF") then {_x setVariable ["SetTakenF",false]};
		if ((str (leader _HQ)) == "LeaderHQG") then {_x setVariable ["SetTakenG",false]};
		if ((str (leader _HQ)) == "LeaderHQH") then {_x setVariable ["SetTakenH",false]};	
	};


	_garrPool = 0;
	_UnableArr = [];
	_noGarrAround = true;
	_setTaken = false;

	if ((str (leader _HQ)) == "LeaderHQ") then {_setTaken = (_x getVariable ["SetTakenA",false])};
	if ((str (leader _HQ)) == "LeaderHQB") then {_setTaken = (_x getVariable ["SetTakenB",false])};
	if ((str (leader _HQ)) == "LeaderHQC") then {_setTaken = (_x getVariable ["SetTakenC",false])};
	if ((str (leader _HQ)) == "LeaderHQD") then {_setTaken = (_x getVariable ["SetTakenD",false])};
	if ((str (leader _HQ)) == "LeaderHQE") then {_setTaken = (_x getVariable ["SetTakenE",false])};
	if ((str (leader _HQ)) == "LeaderHQF") then {_setTaken = (_x getVariable ["SetTakenF",false])};
	if ((str (leader _HQ)) == "LeaderHQG") then {_setTaken = (_x getVariable ["SetTakenG",false])};
	if ((str (leader _HQ)) == "LeaderHQH") then {_setTaken = (_x getVariable ["SetTakenH",false])};	

		
	{
		if ((_trg distance (leader _x)) < (_HQ getVariable [QEGVAR(core,objRadius2),500])) exitWith {_noGarrAround = false};
	} forEach (_HQ getVariable [QEGVAR(core,garrison),[]]);

	if ((_noGarrAround) and not (EGVAR(missionmodules,active)) and (_x in _taken) and not (_setTaken)) then
		{
		_UnableArr = [];

		_fG = (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - ((_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_HQ getVariable [QEGVAR(core,aOnly),[]]) + (_HQ getVariable [QEGVAR(core,rOnly),[]]) + (_HQ getVariable [QEGVAR(core,garrison),[]]));

		{
			if (((_x getVariable ["Unable",false]) or (isPlayer (leader _x))) or (_x getVariable ["Busy" + (str _x),false])) then {_UnableArr pushBack _x};
		} forEach _fG;

		_fG = _fG - (_UnableArr);

		if ((((count _fG)/5) >= 1) and (_noGarrAround)) then
			{
			_chosen = _fG select 0;

			_dstMin = _trg distance (vehicle (leader _chosen));

				{
				_actG = _x;
				_actDst = _trg distance (vehicle (leader _actG));
		
				if (_actDst < _dstMin) then 
					{
					_dstMin = _actDst;
					_chosen = _actG
					}
				}
			forEach _fG;
					
			_code =
				{
				_unitG = _this select 0;
				_HQ = _this select 1;
		
				_busy = _unitG getVariable [("Busy" + (str _unitG)),false];

				_alive = true;

				if (_busy) then 
					{
					_unitG setVariable [QEGVAR(common,mIA),true];
					_ct = time;
							
					waitUntil
						{
						sleep 0.1;
							
						switch (true) do
							{
							case (isNull (_unitG)) : {_alive = false};
							case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
							case ((time - _ct) > 60) : {_alive = false};
							};
									
						_MIApass = false;
						if (_alive) then
							{
							_MIAPass = not (_unitG getVariable [QEGVAR(common,mIA),false]);
							};
									
						(not (_alive) or (_MIApass))	
						}
					};
							
				_unitG setVariable ["Busy" + (str _unitG),true];
				_garrison = _HQ getVariable [QEGVAR(core,garrison),[]];
				_garrison pushBack _unitG;
				_HQ setVariable [QEGVAR(core,garrison),_garrison];
				};
						
			if ((_trg distance (vehicle (leader _chosen))) < (_HQ getVariable [QEGVAR(core,objRadius2),500])) then {[[_chosen,_HQ],_code] call EFUNC(common,spawn)};
			}
		};

	}
forEach _objectives;

	{

	if ((_HQ getVariable [QEGVAR(core,simpleMode),false]) and not (EGVAR(missionmodules,active))) then {_trg = _x};

	_AllV20 = _x nearEntities [["AllVehicles"],(_HQ getVariable [QEGVAR(core,objRadius1),300])];
	_Civs20 = _x nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius1),300])];

	_AllV2 = [];

		{
		_AllV2 = _AllV2 + (crew _x)
		}
	forEach _AllV20;

	_Civs20 = _trg nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];

	_Civs2 = [];

		{
		_Civs2 = _Civs2 + (crew _x)
		}
	forEach _Civs20;

	_AllV2 = _AllV2 - _Civs2;

	_AllV20 = +_AllV2;

		{
		if not (_x isKindOf "Man") then
			{
			if (((crew _x) isEqualTo [])) then {_AllV2 = _AllV2 - [_x]}
			}
		}
	forEach _AllV20;

//	_NearEnemies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countenemy _AllV2;
	_NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);
	_AllV0 = _x nearEntities [["AllVehicles"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];
	_Civs0 = _x nearEntities [["Civilian"],(_HQ getVariable [QEGVAR(core,objRadius2),500])];

	_AllV = [];

		{
		_AllV = _AllV + (crew _x)
		}
	forEach _AllV0;

	_Civs = [];

		{
		_Civs = _Civs + (crew _x)
		}
	forEach _Civs0;

	_AllV = _AllV - _Civs;
	_AllV0 = +_AllV;

		{
		if not (_x isKindOf "Man") then
			{
			if (((crew _x) isEqualTo [])) then {_AllV = _AllV - [_x]}
			}
		}
	forEach _AllV0;

//	_NearAllies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countfriendly _AllV;
	_NearAllies = ({(side _x) in _SideAllies} count _AllV);

	if (_x == _trg) then
		{
		_captLimit = 1 * (1 + ((_HQ getVariable [QEGVAR(core,circumspection),0.5])/(2 + (_HQ getVariable [QEGVAR(core,recklessness),0.5]))));
		_enRoute = 0;

			{
			if not (isNull _x) then
				{
				if (_x getVariable [("Capt" + (str _x)),false]) then
					{
					_enRoute = _enRoute + (count (units _x))
					}
				}
			}
		forEach (_HQ getVariable [QEGVAR(core,navalG),[]]);

		_captDiff = _captLimit - _enRoute;

		if (_captDiff > 0) then
			{	
			_isC = _trg getVariable ("Capturing" + (str _trg) + (str _HQ));if (isNil "_isC") then {_isC = [0,0]};

			_amountC = _isC select 1;
			_isC = _isC select 0;
			if (_isC > 3) then {_isC = 3};
			_trg setVariable [("Capturing" + (str _trg) + (str _HQ)),[_isC,_amountC - _captDiff]];
			}
		};

	if (not (_HQ getVariable [QEGVAR(core,unlimitedCapt),false]) and (_NearAllies >= (_HQ getVariable [QEGVAR(core,captLimit),10])) and (_NearEnemies < (_NearAllies*0.25))) then {
		_Navaltaken pushBackUnique _x;
	};

	if ((_NearEnemies > _NearAllies) and not (_AAO)) exitWith {_lost = _x};
	if (_NearEnemies > _NearAllies) then {
		_Navaltaken = _Navaltaken - [_x];
		if ((str (leader _HQ)) == "LeaderHQ") then {_x setVariable ["SetTakenA",false]};
		if ((str (leader _HQ)) == "LeaderHQB") then {_x setVariable ["SetTakenB",false]};
		if ((str (leader _HQ)) == "LeaderHQC") then {_x setVariable ["SetTakenC",false]};
		if ((str (leader _HQ)) == "LeaderHQD") then {_x setVariable ["SetTakenD",false]};
		if ((str (leader _HQ)) == "LeaderHQE") then {_x setVariable ["SetTakenE",false]};
		if ((str (leader _HQ)) == "LeaderHQF") then {_x setVariable ["SetTakenF",false]};
		if ((str (leader _HQ)) == "LeaderHQG") then {_x setVariable ["SetTakenG",false]};
		if ((str (leader _HQ)) == "LeaderHQH") then {_x setVariable ["SetTakenH",false]};	
	};


	}
forEach _Navalobjectives;

if not ((EGVAR(missionmodules,active)) and ((leader _HQ) in (RydBBa_HQs + RydBBb_HQs))) then
	{
	_HQ setVariable [QEGVAR(common,taken),_taken]; 
	_HQ setVariable [QGVAR(takenNaval),_Navaltaken]; 

	if not (_AAO) then
		{
		if (isNull _lost)	then {_HQ setVariable [QEGVAR(core,nObj),_lastObj]} else {
			if (_lost == (_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])) then {_HQ setVariable [QEGVAR(core,nObj),1];{_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]}forEach ([(_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])])} else {
				if ((_lost == (_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])) and ((_HQ getVariable [QEGVAR(core,nObj),1]) > 2)) then {_HQ setVariable [QEGVAR(core,nObj),2];{_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]}forEach ([(_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])])} else {
					if ((_lost == (_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])) and ((_HQ getVariable [QEGVAR(core,nObj),1]) > 3)) then {_HQ setVariable [QEGVAR(core,nObj),3];{_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]}forEach ([(_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)]),(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])])} else {
						if ((_lost == (_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])) and ((_HQ getVariable [QEGVAR(core,nObj),1]) >= 4)) then {_HQ setVariable [QEGVAR(core,nObj),4];{_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]}forEach ([(_HQ getVariable [QEGVAR(core,obj4),(leader _HQ)])])}}}}};
		
		if ((_HQ getVariable [QEGVAR(core,nObj),1]) < 1) then {_HQ setVariable [QEGVAR(core,nObj),1]};
		if ((_HQ getVariable [QEGVAR(core,nObj),1]) > 5) then {_HQ setVariable [QEGVAR(core,nObj),5]};

		_HQ setVariable [QEGVAR(core,progress),0];
		if (_lastObj > (_HQ getVariable [QEGVAR(core,nObj),1])) then {_HQ setVariable [QEGVAR(core,progress),-1];_HQ setVariable [QEGVAR(core,morale),(_HQ getVariable [QEGVAR(core,morale),0]) - _mLoss]};	
		if (_lastObj < (_HQ getVariable [QEGVAR(core,nObj),1])) then {_HQ setVariable [QEGVAR(core,progress),1]};	
		}
	else
		{
		_nTaken = count _taken;
		
			{
			if (_x in _oTaken) then
				{
				_x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]]
				}
			}
		forEach (_objectives - _taken);
		
		if (_nTaken < _cTaken) then
			{
			_HQ setVariable [QEGVAR(core,morale),(_HQ getVariable [QEGVAR(core,morale),0]) - (_mLoss * (_cTaken - _nTaken))]
			}
		}
	};

_reserve = (_HQ getVariable [QEGVAR(core,friends),[]]) - ((_HQ getVariable [QEGVAR(core,artG),[]]) + ((_HQ getVariable [QEGVAR(core,airG),[]]) - (_HQ getVariable [QEGVAR(core,supportG),[]])) + (_HQ getVariable [QEGVAR(core,navalG),[]]) + (_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]));

	{
	_x setVariable [("Deployed" + (str _x)),false];
	}
forEach _reserve;

	{
	if ((random 100) > 95) then {_x setVariable [("Garrisoned" + (str _x)),false]};
	}
forEach (_HQ getVariable [QEGVAR(core,garrison),[]]);

if ((_HQ getVariable [QEGVAR(core,combining),false])) then 
	{
	_exhausted = +(_HQ getVariable [QEGVAR(core,exhausted),[]]);
	
		{
		if (not (isNull _x) and (({alive _x} count (units _x)) >= 1) and not (_x getVariable [("isCaptive" + (str _x)),false])) then 
			{
			_unitvar = str _x;
			_nominal = _x getVariable ("Nominal" + (str _x)); 
			if (isNil ("_nominal")) then 
			{
			_x setVariable [("Nominal" + (str _x)),(count (units _x))]; 
			_nominal = _x getVariable ("Nominal" + (str _x))
			};
			_current = count (units _x);
			if (((_nominal/(_current + 0.1)) > 2) and (isNull (assignedVehicle (leader _x)))) then 
				{
				_ex = ((_HQ getVariable [QEGVAR(core,exhausted),[]]) - [_x]);
				for [{private _a = 0}, {(_a < (count _ex))}, {_a = _a + 1}] do
					{
					_Aex = _ex select _a;
					_unitvarA = str _Aex;
					
					if not (_Aex getVariable [("isCaptive" + _unitvarA),false]) then
						{
						_nominalA = _Aex getVariable ("Nominal" + (str _Aex));
						if (isNil ("_nominalA")) then {
							_Aex setVariable [("Nominal" + _unitvarA),(count (units _Aex)),true];
							_nominalA = _Aex getVariable ("Nominal" + (str _Aex))
							};
						_currentA = count (units _Aex);
						//diag_log _nominalA;
						if (((_nominalA/(_currentA + 0.1)) > 2) and (isNull (assignedVehicle (leader _Aex))) and (((vehicle (leader _x)) distance (vehicle (leader _Aex))) < 200)) then 
							{
							(units _x) joinSilent _Aex;
							sleep 0.05;
							_Aex setVariable [("Nominal" + (str _Aex)),(count (units _Aex)),true];
							}
						};
					};
				};
			}
		else
			{
			_exhausted = _exhausted - [_x]
			};
		}
	forEach (_HQ getVariable [QEGVAR(core,exhausted),[]]);
	_HQ setVariable [QEGVAR(core,exhausted),_exhausted];
	};
