#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:537 (Action7ct)
/**
 * @description Server-side condition/execution handler for slot 7: Request air transport (airlift)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_unitvar","_chosen","_HQ","_dist","_TransportPriority","_timer","_AbortAction","_unitG"];

	_HQ = grpNull;

	if not (isNil "LeaderHQ") then {if ((group (_this select 0)) in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if ((group (_this select 0)) in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if ((group (_this select 0)) in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if ((group (_this select 0)) in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if ((group (_this select 0)) in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if ((group (_this select 0)) in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if ((group (_this select 0)) in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if ((group (_this select 0)) in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

	[(_this select 0), 'Command, requesting airlift - Over'] remoteExecCall ["RYD_MP_Sidechat"];

	_unitG = (group (_this select 0));
	_unitvar = str _unitG;

	if not (_unitG getVariable [("CC" + _unitvar), true]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', negative. Transport already assigned - Out'] remoteExecCall ["RYD_MP_Sidechat"]};
	if (_unitG getVariable ["CargoCheckLoopActive", false]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', request pending. You are already on standby for transport - Over'] remoteExecCall ["RYD_MP_Sidechat"]};

	_unitG setVariable ["CargoCheckLoopActive", true,true];

	_unitG setVariable [("CC" + _unitvar), false, true];

	_TransportPriority = (leader _HQ) getVariable ["RydHQ_TransportPriorityAir",[]];
	_TransportPriority pushBackUnique (group (_this select 0));
	(leader _HQ) setVariable ["RydHQ_TransportPriorityAir",_TransportPriority,true];

	[[_unitG,_HQ,getPos (_this select 0),false,true],HAL_SCargo] call EFUNC(common,spawn);

	sleep 15;

	if (_unitG getVariable ["CargoChosen", false]) exitWith {
		[leader _HQ, (groupId (group (_this select 0))) + ', affirmative. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["RYD_MP_Sidechat"];
		_TransportPriority = (leader _HQ) getVariable ["RydHQ_TransportPriorityAir",[]];
		_TransportPriority = _TransportPriority - [(group (_this select 0))];
		(leader _HQ) setVariable ["RydHQ_TransportPriorityAir",_TransportPriority,true];

		_unitG setVariable ["CargoCheckLoopActive", false,true];
		};

	if (not (_unitG getVariable ["CargoChosen", false])) then {

		[leader _HQ, (groupId _unitG) + ', copy. No air transport is available at this time. if transport becomes available in the next ' + (str (RydxHQ_PlayerCargoCheckLoopTime)) + ' minutes, it will be assigned to you - Over'] remoteExecCall ["RYD_MP_Sidechat"];

		_AbortAction = (_this select 0) addAction ["Cancel " + "Air" + " Transport Request",
		{

		[(_this select 3), 'Command, cancel air transport request - Over'] remoteExecCall ["RYD_MP_Sidechat"];

		(group (_this select 3)) setVariable ["CargoCheckLoopAbort",true,true];

		(_this select 0) removeAction (_this select 2);

		}
		, 
		(_this select 0),5,false,false,"","_this == _target",15];

		_timer = 0;

		waitUntil {
			if not ((_unitG getVariable ["CargoCheckPending" + _unitvar,false]) and (_unitG getVariable [("CC" + _unitvar), false]) and not (_unitG getVariable ["CargoChosen", false])) then {
				_unitG setVariable [("CC" + _unitvar), false, true];
				[[_unitG,_HQ,getPos (_this select 0),false,true],HAL_SCargo] call EFUNC(common,spawn);
				};

			sleep 5;

			_timer = _timer + 5;

			(_unitG getVariable ["CargoChosen", false]) or (_timer > (RydxHQ_PlayerCargoCheckLoopTime*60)) or (_unitG getVariable ["CargoCheckLoopAbort",false]);
		};

		(_this select 0) removeAction _AbortAction;

	};

	_TransportPriority = (leader _HQ) getVariable ["RydHQ_TransportPriorityAir",[]];
	_TransportPriority = _TransportPriority - [(group (_this select 0))];
	(leader _HQ) setVariable ["RydHQ_TransportPriorityAir",_TransportPriority,true];

	_unitG setVariable ["CargoCheckLoopActive", false,true];

	if (_unitG getVariable ["CargoCheckLoopAbort",false]) exitWith {_unitG setVariable ["CargoCheckLoopAbort",false,true]; [leader _HQ, (groupId _unitG) + ', copy. Air transport request canceled - Out'] remoteExecCall ["RYD_MP_Sidechat"];};	

	if (_unitG getVariable ["CargoChosen", false]) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["RYD_MP_Sidechat"];};
	if (not (_unitG getVariable ["CargoChosen", false])) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. No air transport available. - Out'] remoteExecCall ["RYD_MP_Sidechat"]};
