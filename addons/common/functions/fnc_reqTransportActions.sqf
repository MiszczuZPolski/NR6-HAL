#include "..\script_component.hpp"

private ["_ChosenOne","_unitG","_GD","_actionID","_VActArr","_ActArr","_isAir"];

	_ChosenOne = _this select 0;
	_LeaderG = _this select 1;
	_GD = _this select 2;
	_isAir = false;
	if ((count _this) > 3) then {_isAir = _this select 3};


	_ActArr = (_LeaderG getVariable ["HAL_ReqTraActs",[]]);
	_VActArr = (_LeaderG getVariable ["HAL_ReqTraVActs",[]]);

	_actionID = _ChosenOne addAction ["Select New Transport Destination",
	{

	(_this select 1) onMapSingleClick "(group _this) setvariable ['HALReqDest',_pos,true]; _this onMapSingleClick ''; hint 'Destination Selected'";

	openMap true;

	hintC "You can now select the destination on your map. Only select the destination once everyone is aboard as this will order the departure of the vehicle. You can select a new destination at any time as long as the transport support was not terminated.";

	}
	,
	_GD,5,false,false,"","_target isEqualTo (vehicle _this)",15];

	_VActArr pushBack _actionID;

	_actionID = _ChosenOne addAction ["Transport Stealth Mode",
	{

	[(_this select 3),"STEALTH"] remoteExecCall ["setBehaviour",leader (_this select 3)];
	[(_this select 3),"GREEN"] remoteExecCall ["setCombatMode",leader (_this select 3)];

	}
	,
	_GD,5,false,false,"","_target isEqualTo (vehicle _this)",15];

	_VActArr pushBack _actionID;

	_actionID = _ChosenOne addAction ["Transport Normal Mode",
	{

	[(_this select 3),"CARELESS"] remoteExecCall ["setBehaviour",leader (_this select 3)];
	[(_this select 3),"YELLOW"] remoteExecCall ["setCombatMode",leader (_this select 3)];

	}
	,
	_GD,5,false,false,"","_target isEqualTo (vehicle _this)",15];

	_VActArr pushBack _actionID;

	_actionID = _LeaderG addAction ["Dismiss Transport Support [" + (groupId _GD) + "]",
	{

	(_this select 3) setVariable ['HALReqDone',true,true];

	(_this select 0) removeAction (_this select 2);

	}
	,
	_GD,-1.7,false,false,"","true",0.01];

	if (_isAir) then
		{

		_actionID = _LeaderG addAction ["Force Immediate Full-Stop Landing [" + (groupId _GD) + "]",
		{

		[(_this select 3), (currentWaypoint (_this select 3))] setWaypointPosition [getPosATL (vehicle (leader (_this select 3))),0];
		(vehicle (leader (_this select 3))) land 'land';

		}
		,
		_GD,-2,false,false,"","(_this distance ((group _this) getVariable ['AssignedCargo' + (str (group _this)),objNull])) < 250",0.01];

		_ActArr pushBack _actionID;
	};

	_LeaderG setVariable ["HAL_ReqTraActs",_ActArr,true];
	_LeaderG setVariable ["HAL_ReqTraVActs",_VActArr,true];

	true
