#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:786 (Action9ct)
/**
 * @description Server-side condition/execution handler for slot 9: Request ammunition truck
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

	[_unit, 'Command, requesting ammunition truck - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	sleep 5;

	private _Pool = EGVAR(data,ammo) + EGVAR(data,wS_ammo) - RHQs_Ammo;

	private _AmmoBoy = objNull;

	{
		private _unitvar = str (group _x);
		if ( not ((group _x) getVariable [("Busy" + _unitvar),false]) and not ((group _x) == _grp) and not ((group _x) getVariable ["Unable",false]) and not ((group _x) isEqualTo grpNull) and (canMove _x) and ((toLower (typeOf (assignedVehicle (leader (group _x))))) in _Pool) and not ((group _x) in ((_HQ getVariable [QEGVAR(hac,specForG),[]]) + (_HQ getVariable [QEGVAR(core,cargoOnly),[]]))))  exitWith {_AmmoBoy = _x};
	} forEach (_HQ getVariable [QEGVAR(hac,support),[]]);

	if (_AmmoBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId _grp) + ', negative. No rearming services are currently available - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	[[_AmmoBoy,(vehicle _unit),[],[],false,objNull,_HQ,true],EFUNC(hac,goAmmoSupp)] call EFUNC(common,spawn);

	[leader _HQ, (groupId _grp) + ', affirmative. Ammunition truck is on its way - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
