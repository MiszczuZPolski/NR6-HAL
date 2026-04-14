#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/GoDefRecon.sqf
_SCRname = "GoDefRecon";

_i = "";

_unitG = _this select 0;_Spos = _unitG getVariable ("START" + (str _unitG));if (isNil ("_Spos")) then {_unitG setVariable [("START" + (str _unitG)),(getPosATL (vehicle (leader _unitG)))];_Spos = _unitG getVariable ("START" + (str _unitG))};
_DefPos = _this select 1;
_angleV = _this select 2;
_HQ = _this select 3;

_unitvar = str _unitG;
_busy = false;
_busy = _unitG getVariable ("Busy" + _unitvar);
_isAPlayer = false;

if (isNil ("_busy")) then {_busy = false};

_alive = true;

if (_busy) exitWith {_defSpot = _HQ getVariable [QEGVAR(core,defSpot),[]];
	_defSpot = _defSpot - [_unitG];
	_HQ setVariable [QEGVAR(core,defSpot),_defSpot];
	_def = _HQ getVariable [QEGVAR(core,def),[]];
	_def = _def - [_unitG];
	_HQ setVariable [QEGVAR(core,def),_def];};


/*
if (_busy) then
	{
	_unitG setVariable ["RydHQ_MIA",true];
	_ct = time;

	waitUntil
		{
		sleep 0.1;

		switch (true) do
			{
			case (isNull (_unitG)) : {_alive = false};
			case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
			case ((time - _ct) > 300) : {_alive = false};
			};

		_MIApass = false;
		if (_alive) then
			{
			_MIAPass = not (_unitG getVariable ["RydHQ_MIA",false]);
			};

		(not (_alive) or (_MIApass))
		}
	};
*/


[_unitG] call CBA_fnc_clearWaypoints;

_attackAllowed = attackEnabled _unitG;
_unitG enableAttack false;

_unitG setVariable [("Deployed" + (str _unitG)),false];_unitG setVariable [("Capt" + (str _unitG)),false];
_unitG setVariable [("Busy" + _unitvar), true];
_unitG setVariable ["Defending", true];


_UL = leader _unitG;
_AV = assignedVehicle _UL;
_DAV = assignedDriver _AV;
_GDV = group _DAV;

if not (isNull _AV) then {

	{
		if (isNull (assignedVehicle _x)) then {_x assignAsCargo _AV};
	} forEach (units _unitG);
};

_posX = (_DefPos select 0) + (random 40) - 20;
_posY = (_DefPos select 1) + (random 40) - 20;
_DefPos = [_posX,_posY];

_isWater = surfaceIsWater _DefPos;

while {((_isWater) and ((leader _HQ) distance _DefPos >= 10))} do
	{
	_PosX = ((_DefPos select 0) + ((getPosATL (leader _HQ)) select 0))/2;
	_PosY = ((_DefPos select 1) + ((getPosATL (leader _HQ)) select 1))/2;
	_DefPos = [_posX,_posY]
	};

_isWater = surfaceIsWater _DefPos;

if (_isWater) then {_DefPos = getPosATL (vehicle (leader _unitG))};

[_unitG,[_posX,_posY,0],"HQ_ord_defend",_HQ] call EFUNC(common,orderPause);

if ((isPlayer (leader _unitG)) and (EGVAR(common,gPauseActive))) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;

_nE = _UL findNearestEnemy _UL;

if not (isNull _nE) then
	{
	if ((_HQ getVariable [QEGVAR(core,smoke),true]) and ((_nE distance (vehicle _UL)) <= 500) and not (isPlayer _UL)) then
		{
		_posSL = getPosASL _UL;
		_posSL2 = getPosASL _nE;

		_angle = [_posSL,_posSL2,15] call EFUNC(common,angleTowards);

		_dstB = _posSL distance _posSL2;
		_pos = [_posSL,_angle,_dstB/4 + (random 100) - 50] call EFUNC(common,positionTowards2D);

		_CFF = false;

		if ((_HQ getVariable [QEGVAR(core,artyShells),1]) > 0) then
			{
			_CFF = ([_pos,(_HQ getVariable [QEGVAR(core,artG),[]]),"SMOKE",9,_UL] call EFUNC(common,artyMission)) select 0;
			if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_SmokeReq),"SmokeReq"] call EFUNC(common,AIChatter)}};
			};

		if (_CFF) then
			{
			if ((_HQ getVariable [QEGVAR(core,artyShells),1]) > 0) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),EGVAR(common,aIC_ArtAss),"ArtAss"] call EFUNC(common,AIChatter)}};
			sleep 60
			}
		else
			{
			if ((_HQ getVariable [QEGVAR(core,artyShells),1]) > 0) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[(leader _HQ),EGVAR(common,aIC_ArtDen),"ArtDen"] call EFUNC(common,AIChatter)}};
			//[_unitG,_nE] spawn RYD_Smoke;
			[[_unitG,_nE],EFUNC(common,smoke)] call EFUNC(common,spawn);
			sleep 10;
			if ((isNull objectParent _UL)) then {sleep 25}
			}
		}
	};

_UL = leader _unitG;

if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,EGVAR(boss,aIC_OrdConf),"OrdConf"] call EFUNC(common,AIChatter)}};

if (_HQ getVariable [QEGVAR(common,debug),false]) then
	{
	_signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
	_i = [_DefPos,_unitG,"markDef","ColorBrown","ICON","waypoint","REC " + (groupId _unitG) + " " + _signum," - WATCH FOREGROUND",[0.5,0.5]] call EFUNC(common,mark)
	};

_AV = assignedVehicle _UL;

if not (isNull _AV) then {

	{
		if (isNull (assignedVehicle _x)) then {_x assignAsCargo _AV};
	} forEach (units _unitG);
};

_task = [(leader _unitG),["Take a defensive position and search for hostile targets.", "Scout The Area", ""],_DefPos,"scout"] call EFUNC(common,addTask);

_formation = formation _unitG;
if not (isPlayer (leader _unitG)) then {_formation = "FILE"};_tp = "MOVE";

_wp = [_unitG,_DefPos,_tp,"AWARE","GREEN","FULL",["true","deletewaypoint [(group this), 0];"],true,0.001,[0,0,0],_formation] call EFUNC(common,WPadd);

if not (_isAPlayer) then {_unitG setVariable ["InfGetinCheck" + (str _unitG),true]};
_cause = [_unitG,6,true,0,24,[],false] call EFUNC(common,wait);
_alive = _cause select 1;

if not (_alive) exitWith
	{
	if ((_HQ getVariable [QEGVAR(common,debug),false]) or (isPlayer (leader _unitG))) then
		{
		deleteMarker ("markDef" + str (_unitG))
		};

	_RecDefSpot = _HQ getVariable [QEGVAR(core,recDefSpot),[]];
	_RecDefSpot = _RecDefSpot - [_unitG];
	_unitG setVariable [("Busy" + (str _unitG)),false];
	_unitG setVariable ["Defending", false];
	_HQ setVariable [QEGVAR(core,recDefSpot),_RecDefSpot]
	};
/*
if ((_unitG in ((_HQ getVariable ["RydHQ_CargoG",[]]) - ((_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - (_HQ getVariable ["RydHQ_NCCargoG",[]]))))) or (not (isNull _AV) and not (_unitG == (group (assigneddriver _AV))))) then
	{
	(units _unitG) allowGetIn false;
	(units _unitG) orderGetIn false
	};
*/
_formation = formation _unitG;
if not (isPlayer (leader _unitG)) then {_formation = "WEDGE"};

_wp = [_unitG,_DefPos,"SENTRY","STEALTH","YELLOW","FULL",["true","deletewaypoint [(group this), 0];"],true,0.001,[0,0,0],_formation] call EFUNC(common,WPadd);

_TED = getPosATL (leader _HQ);

_dX = 2000 * (sin _angleV);
_dY = 2000 * (cos _angleV);

_posX = ((getPosATL (leader _HQ)) select 0) + _dX + (random 2000) - 1000;
_posY = ((getPosATL (leader _HQ)) select 1) + _dY + (random 2000) - 1000;

_TED = [_posX,_posY];

if ((_HQ getVariable [QEGVAR(common,debug),false]) or (isPlayer (leader _unitG))) then
	{
	_signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
	_i = [_TED,_unitG,"markWatch","Default","ICON","waypoint", (groupId _unitG) + _signum,_signum,[0.2,0.2]] call EFUNC(common,mark)
	};

_dir = [(getPosATL (vehicle (leader _unitG))),_TED,10] call EFUNC(common,angleTowards);
if (_dir < 0) then {_dir = _dir + 360};

_unitG setFormDir _dir;
(units _unitG) doWatch _TED;

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_OrdFinal),"OrdFinal"] call EFUNC(common,AIChatter)}};

//[_unitG,(_HQ getVariable ["RydHQ_Flare",true]),(_HQ getVariable ["RydHQ_ArtG",[]]),(_HQ getVariable ["RydHQ_ArtyShells",1]),(leader _HQ)] spawn RYD_Flares;
[[_unitG,(_HQ getVariable [QEGVAR(core,flare),true]),(_HQ getVariable [QEGVAR(core,artG),[]]),(_HQ getVariable [QEGVAR(core,artyShells),1]),(leader _HQ)],EFUNC(common,flares)] call EFUNC(common,spawn);

_alive = true;
/*
waituntil
	{
	sleep 10;
	_endThis = false;

	switch (true) do
		{
		case not (_unitG getVariable "Defending") : {_endThis = true};
		case (isNull _unitG) : {_endThis = true;_alive = false};
		case (({alive _x} count (units _unitG)) < 1) : {_endThis = true;_alive = false};
		};

	(_endThis)
	};
*/
if not (_alive) exitWith
	{
	if ((_HQ getVariable [QEGVAR(common,debug),false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markDef" + _unitVar);deleteMarker ("markWatch" + _unitVar)};
	_RecDefSpot = _HQ getVariable [QEGVAR(core,recDefSpot),[]];
	_RecDefSpot = _RecDefSpot - [_unitG];
	_unitG setVariable [("Busy" + (str _unitG)),false];
	_unitG setVariable ["Defending", false];
	_HQ setVariable [QEGVAR(core,recDefSpot),_RecDefSpot]
	};

//if not (_task isEqualTo taskNull) then {[_task,"SUCCEEDED",true] call BIS_fnc_taskSetState};

if ((_HQ getVariable [QEGVAR(common,debug),false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markDef" + (str _unitG));deleteMarker ("markWatch" + (str _unitG))};

(units _unitG) doWatch objNull;
//(units _unitG) allowGetIn true;
//(units _unitG) orderGetIn true;
if (_attackAllowed) then {_unitG enableAttack true};

_RecDefSpot = _HQ getVariable [QEGVAR(core,recDefSpot),[]];
_RecDefSpot = _RecDefSpot - [_unitG];
_HQ setVariable [QEGVAR(core,recDefSpot),_RecDefSpot];

_unitG setVariable [("Busy" + _unitvar), false];
_unitG setVariable ["Defending", false];

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_OrdEnd),"OrdEnd"] call EFUNC(common,AIChatter)}};
