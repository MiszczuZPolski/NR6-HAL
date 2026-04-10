#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1059 (Action12ct)
/**
 * @description Server-side condition/execution handler for slot 12: Request aerial medical support (MEDEVAC)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_unitvar","_chosen","_HQ","_dist","_MedBoy"];

	_HQ = grpNull;

	if not (isNil "LeaderHQ") then {if ((group (_this select 0)) in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if ((group (_this select 0)) in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if ((group (_this select 0)) in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if ((group (_this select 0)) in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if ((group (_this select 0)) in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if ((group (_this select 0)) in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if ((group (_this select 0)) in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if ((group (_this select 0)) in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

	[(_this select 0), 'Command, requesting aerial medical support - Over'] remoteExecCall ["RYD_MP_Sidechat"];

	sleep 5;

	_Pool = RHQ_Med + RYD_WS_med - RHQs_Med;

	_MedBoy = objNull;

	{
		_unitvar = str (group _x);
		if ( not ((group _x) getVariable [("Busy" + _unitvar),false]) and not ((group _x) == (group (_this select 0))) and not ((group _x) getVariable ["Unable",false]) and not ((group _x) isEqualTo grpNull) and (canMove _x) and ((toLower (typeOf (assignedVehicle (leader (group _x))))) in _Pool) and (_x in (_HQ getVariable ["RydHQ_AirG",[]])) and not ((group _x) in ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]))))  exitWith {_MedBoy = _x};
	} forEach (_HQ getVariable ["RydHQ_Support",[]]);

	if (_MedBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId (group (_this select 0))) + ', negative. No MEDEVAC helicopters are currently available - Out'] remoteExecCall ["RYD_MP_Sidechat"]};

	[[_MedBoy,(vehicle (_this select 0)),[],_HQ,true],HAL_GoMedSupp] call EFUNC(common,spawn);

	[leader _HQ, (groupId (group (_this select 0))) + ', affirmative. Helicopter is on its way - Out'] remoteExecCall ["RYD_MP_Sidechat"];
