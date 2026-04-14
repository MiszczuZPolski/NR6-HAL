#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:537 (Action7ct)
/**
 * @description Server-side condition/execution handler for slot 7: Request air transport (airlift)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

private _HQ = grpNull;

if not (isNil "LeaderHQ") then {if (_grp in ((group LeaderHQ) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQ)}};
if not (isNil "LeaderHQB") then {if (_grp in ((group LeaderHQB) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQB)}};
if not (isNil "LeaderHQC") then {if (_grp in ((group LeaderHQC) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQC)}};
if not (isNil "LeaderHQD") then {if (_grp in ((group LeaderHQD) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQD)}};
if not (isNil "LeaderHQE") then {if (_grp in ((group LeaderHQE) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQE)}};
if not (isNil "LeaderHQF") then {if (_grp in ((group LeaderHQF) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQF)}};
if not (isNil "LeaderHQG") then {if (_grp in ((group LeaderHQG) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQG)}};
if not (isNil "LeaderHQH") then {if (_grp in ((group LeaderHQH) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQH)}};

[_unit, 'Command, requesting airlift - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

private _unitG = _grp;
private _unitvar = str _unitG;

if not (_unitG getVariable [("CC" + _unitvar), true]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', negative. Transport already assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};
if (_unitG getVariable ["CargoCheckLoopActive", false]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', request pending. You are already on standby for transport - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

_unitG setVariable ["CargoCheckLoopActive", true,true];

_unitG setVariable [("CC" + _unitvar), false, true];

private _TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityAir),[]];
_TransportPriority pushBackUnique _grp;
(leader _HQ) setVariable [QGVAR(transportPriorityAir),_TransportPriority,true];

[[_unitG,_HQ,getPos _unit,false,true],EFUNC(hac,sCargo)] call EFUNC(common,spawn);

sleep 15;

if (_unitG getVariable ["CargoChosen", false]) exitWith {
	[leader _HQ, (groupId _grp) + ', affirmative. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
	_TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityAir),[]];
	_TransportPriority = _TransportPriority - [_grp];
	(leader _HQ) setVariable [QGVAR(transportPriorityAir),_TransportPriority,true];

	_unitG setVariable ["CargoCheckLoopActive", false,true];
	};

if (not (_unitG getVariable ["CargoChosen", false])) then {

	[leader _HQ, (groupId _unitG) + ', copy. No air transport is available at this time. if transport becomes available in the next ' + (str (EGVAR(core,playerCargoCheckLoopTime))) + ' minutes, it will be assigned to you - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	private _AbortAction = _unit addAction ["Cancel " + "Air" + " Transport Request",
	{
		params ["_target", "_caller", "_id", "_args"];

		[_args, 'Command, cancel air transport request - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

		(group _args) setVariable ["CargoCheckLoopAbort",true,true];

		_target removeAction _id;

	}
	,
	_unit,5,false,false,"","_this == _target",15];

	private _timer = 0;

	waitUntil {
		if not ((_unitG getVariable ["CargoCheckPending" + _unitvar,false]) and (_unitG getVariable [("CC" + _unitvar), false]) and not (_unitG getVariable ["CargoChosen", false])) then {
			_unitG setVariable [("CC" + _unitvar), false, true];
			[[_unitG,_HQ,getPos _unit,false,true],EFUNC(hac,sCargo)] call EFUNC(common,spawn);
			};

		sleep 5;

		_timer = _timer + 5;

		(_unitG getVariable ["CargoChosen", false]) or (_timer > (EGVAR(core,playerCargoCheckLoopTime)*60)) or (_unitG getVariable ["CargoCheckLoopAbort",false]);
	};

	_unit removeAction _AbortAction;

};

_TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityAir),[]];
_TransportPriority = _TransportPriority - [_grp];
(leader _HQ) setVariable [QGVAR(transportPriorityAir),_TransportPriority,true];

_unitG setVariable ["CargoCheckLoopActive", false,true];

if (_unitG getVariable ["CargoCheckLoopAbort",false]) exitWith {_unitG setVariable ["CargoCheckLoopAbort",false,true]; [leader _HQ, (groupId _unitG) + ', copy. Air transport request canceled - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];};

if (_unitG getVariable ["CargoChosen", false]) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];};
if (not (_unitG getVariable ["CargoChosen", false])) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. No air transport available. - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};
