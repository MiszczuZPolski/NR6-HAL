#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1059 (Action12ct)
/**
 * @description Server-side condition/execution handler for slot 12: Request aerial medical support (MEDEVAC)
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

	[_unit, 'Command, requesting aerial medical support - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	sleep 5;

	private _Pool = EGVAR(data,med) + EGVAR(data,wS_med) - RHQs_Med;

	private _MedBoy = objNull;

	{
		private _unitvar = str (group _x);
		if ( not ((group _x) getVariable [("Busy" + _unitvar),false]) and not ((group _x) == _grp) and not ((group _x) getVariable ["Unable",false]) and not ((group _x) isEqualTo grpNull) and (canMove _x) and ((toLower (typeOf (assignedVehicle (leader (group _x))))) in _Pool) and (_x in (_HQ getVariable [QEGVAR(core,airG),[]])) and not ((group _x) in ((_HQ getVariable [QEGVAR(hac,specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]))))  exitWith {_MedBoy = _x};
	} forEach (_HQ getVariable [QEGVAR(hac,support),[]]);

	if (_MedBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId _grp) + ', negative. No MEDEVAC helicopters are currently available - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	[[_MedBoy,(vehicle _unit),[],_HQ,true],EFUNC(hac,goMedSupp)] call EFUNC(common,spawn);

	[leader _HQ, (groupId _grp) + ', affirmative. Helicopter is on its way - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
