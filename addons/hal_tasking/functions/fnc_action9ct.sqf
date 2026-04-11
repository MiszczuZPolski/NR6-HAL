#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:786 (Action9ct)
/**
 * @description Server-side condition/execution handler for slot 9: Request ammunition truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_unit"];

	private _grp = group _unit;
	private _HQ = grpNull;

	if not (isNil "LeaderHQ") then {if (_grp in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if (_grp in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if (_grp in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if (_grp in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if (_grp in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if (_grp in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if (_grp in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if (_grp in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

	[_unit, 'Command, requesting ammunition truck - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	sleep 5;

	private _Pool = RHQ_Ammo + RYD_WS_ammo - RHQs_Ammo;

	private _AmmoBoy = objNull;

	{
		private _unitvar = str (group _x);
		if ( not ((group _x) getVariable [("Busy" + _unitvar),false]) and not ((group _x) == _grp) and not ((group _x) getVariable ["Unable",false]) and not ((group _x) isEqualTo grpNull) and (canMove _x) and ((toLower (typeOf (assignedVehicle (leader (group _x))))) in _Pool) and not ((group _x) in ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]))))  exitWith {_AmmoBoy = _x};
	} forEach (_HQ getVariable ["RydHQ_Support",[]]);

	if (_AmmoBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId _grp) + ', negative. No rearming services are currently available - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	[[_AmmoBoy,(vehicle _unit),[],[],false,objNull,_HQ,true],HAL_GoAmmoSupp] call EFUNC(common,spawn);

	[leader _HQ, (groupId _grp) + ', affirmative. Ammunition truck is on its way - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
