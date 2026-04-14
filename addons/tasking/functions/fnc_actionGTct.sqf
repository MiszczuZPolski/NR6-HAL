#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1300 (ActionGTct)
/**
 * @description Ground transport task condition handler - requests ground cargo transport for group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_unit"];

	private _HQ = grpNull;

	if not (isNil "LeaderHQ") then {if ((group _unit) in ((group LeaderHQ) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if ((group _unit) in ((group LeaderHQB) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if ((group _unit) in ((group LeaderHQC) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if ((group _unit) in ((group LeaderHQD) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if ((group _unit) in ((group LeaderHQE) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if ((group _unit) in ((group LeaderHQF) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if ((group _unit) in ((group LeaderHQG) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if ((group _unit) in ((group LeaderHQH) getVariable [QEGVAR(core,friends),[]])) then {_HQ = (group LeaderHQH)}};

	[_unit, 'Command, requesting ground transport - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	private _unitG = group _unit;
	private _unitvar = str _unitG;

	if not (_unitG getVariable [("CC" + _unitvar), true]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', negative. Transport already assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};
	if (_unitG getVariable ["CargoCheckLoopActive", false]) exitWith {sleep 5; [leader _HQ, (groupId _unitG) + ', request pending. You are already on standby for transport - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	_unitG setVariable ["CargoCheckLoopActive", true,true];

	_unitG setVariable [("CC" + _unitvar), false, true];

	private _TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityGnd),[]];
	_TransportPriority pushBackUnique _unitG;
	(leader _HQ) setVariable [QGVAR(transportPriorityGnd),_TransportPriority,true];

	[[_unitG,_HQ,getPos _unit,false,true,true],EFUNC(hac,sCargo)] call EFUNC(common,spawn);

	sleep 15;

	if (_unitG getVariable ["CargoChosen", false]) exitWith {
		[leader _HQ, (groupId _unitG) + ', affirmative. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
		_TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityGnd),[]];
		_TransportPriority = _TransportPriority - [_unitG];
		(leader _HQ) setVariable [QGVAR(transportPriorityGnd),_TransportPriority,true];

		_unitG setVariable ["CargoCheckLoopActive", false,true];
		};

	if (not (_unitG getVariable ["CargoChosen", false])) then {

		[leader _HQ, (groupId _unitG) + ', copy. No ground transport is available at this time. if transport becomes available in the next ' + (str (EGVAR(core,playerCargoCheckLoopTime))) + ' minutes, it will be assigned to you - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

		private _AbortAction = _unit addAction ["Cancel " + "Ground" + " Transport Request",
		{

		[(_this select 3), 'Command, cancel ground transport request - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

		(group (_this select 3)) setVariable ["CargoCheckLoopAbort",true,true];

		(_this select 0) removeAction (_this select 2);

		}
		,
		_unit,5,false,false,"","_this == _target",15];

		private _timer = 0;

		waitUntil {
			if not ((_unitG getVariable ["CargoCheckPending" + _unitvar,false]) and (_unitG getVariable [("CC" + _unitvar), false]) and not (_unitG getVariable ["CargoChosen", false])) then {
				_unitG setVariable [("CC" + _unitvar), false, true];
				[[_unitG,_HQ,getPos _unit,false,true,true],EFUNC(hac,sCargo)] call EFUNC(common,spawn);
				};

			sleep 5;

			_timer = _timer + 5;

			(_unitG getVariable ["CargoChosen", false]) or (_timer > (EGVAR(core,playerCargoCheckLoopTime)*60)) or (_unitG getVariable ["CargoCheckLoopAbort",false]);
		};

		_unit removeAction _AbortAction;

	};

	_TransportPriority = (leader _HQ) getVariable [QGVAR(transportPriorityGnd),[]];
	_TransportPriority = _TransportPriority - [_unitG];
	(leader _HQ) setVariable [QGVAR(transportPriorityGnd),_TransportPriority,true];

	_unitG setVariable ["CargoCheckLoopActive", false,true];

	if (_unitG getVariable ["CargoCheckLoopAbort",false]) exitWith {_unitG setVariable ["CargoCheckLoopAbort",false,true]; [leader _HQ, (groupId _unitG) + ', copy. Ground transport request canceled - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];};

	if (_unitG getVariable ["CargoChosen", false]) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. ' + (groupId (group (_unitG getVariable ["AssignedCargo" + (str _unitG),objNull]))) + ' has been assigned - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];};
	if (not (_unitG getVariable ["CargoChosen", false])) exitWith {[leader _HQ, (groupId _unitG) + ', update on your request. No ground transport available. - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};
