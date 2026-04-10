#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:786 (Action9ct)
/**
 * @description Server-side condition/execution handler for slot 9: Request ammunition truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_unitvar","_chosen","_HQ","_dist","_AmmoBoy"];

	_HQ = grpNull;

	if not (isNil "LeaderHQ") then {if ((group (_this select 0)) in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if ((group (_this select 0)) in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if ((group (_this select 0)) in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if ((group (_this select 0)) in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if ((group (_this select 0)) in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if ((group (_this select 0)) in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if ((group (_this select 0)) in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if ((group (_this select 0)) in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

	[(_this select 0), 'Command, requesting ammunition truck - Over'] remoteExecCall ["RYD_MP_Sidechat"];

	sleep 5;

	_Pool = RHQ_Ammo + RYD_WS_ammo - RHQs_Ammo;

	_AmmoBoy = objNull;

	{
		_unitvar = str (group _x);
		if ( not ((group _x) getVariable [("Busy" + _unitvar),false]) and not ((group _x) == (group (_this select 0))) and not ((group _x) getVariable ["Unable",false]) and not ((group _x) isEqualTo grpNull) and (canMove _x) and ((toLower (typeOf (assignedVehicle (leader (group _x))))) in _Pool) and not ((group _x) in ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]))))  exitWith {_AmmoBoy = _x};
	} forEach (_HQ getVariable ["RydHQ_Support",[]]);

	if (_AmmoBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId (group (_this select 0))) + ', negative. No rearming services are currently available - Out'] remoteExecCall ["RYD_MP_Sidechat"]};

	[[_AmmoBoy,(vehicle (_this select 0)),[],[],false,objNull,_HQ,true],HAL_GoAmmoSupp] call EFUNC(common,spawn);

	[leader _HQ, (groupId (group (_this select 0))) + ', affirmative. Ammunition truck is on its way - Out'] remoteExecCall ["RYD_MP_Sidechat"];
