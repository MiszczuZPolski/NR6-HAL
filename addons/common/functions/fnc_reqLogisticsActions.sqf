private ["_ChosenOne","_Type","_actionID"];

	_ChosenOne = _this select 0;

	_Type = _this select 1;

	_actionID = _ChosenOne addAction ["Dismiss " + _Type + " Support [" + (groupId (group (_ChosenOne))) + "]",
	{

	(_this select 3) setVariable ["HAL_Requested",false,true];
	[(_this select 0)] remoteExecCall ["RYD_ReqLogisticsDelete_Actions"];

	}
	,
	_ChosenOne,5,false,false,"","true",15];

	_ChosenOne setVariable ["HAL_ReqTraAct",_actionID];

	true
