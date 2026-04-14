#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:688 (Action8ct)
/**
 * @description Server-side condition/execution handler for slot 8: Request ammunition drop (air supply)
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

	[_unit, 'Command, requesting ammunition drop - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

	sleep 5;

	private _FlyBoy = objNull;

	{
		private _unitvar = str _x;
		if ( not (_x getVariable [("Busy" + _unitvar),false]) and not (_x == _grp) and not (_x getVariable ["Unable",false]) and not (_x isEqualTo grpNull) and (canMove (vehicle (leader _x))) and not ((vehicle (leader _x)) == (leader _x))) exitWith {_FlyBoy = _x};
	} forEach (_HQ getVariable [QEGVAR(core,ammoDrop),[]]);

	if (_FlyBoy isEqualTo objNull) exitWith {[leader _HQ, (groupId _grp) + ', negative. No supply services are currently available - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	if not ((count (_HQ getVariable [QEGVAR(core,ammoBoxes),[]])) > 0) exitWith {[leader _HQ, (groupId _grp) + ', negative. Supplies have been depleted - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};

	private _ammoBox = (_HQ getVariable [QEGVAR(core,ammoBoxes),[]]) select 0;
	_HQ setVariable [QEGVAR(core,ammoBoxes),(_HQ getVariable [QEGVAR(core,ammoBoxes),[]]) - [_ammoBox]];

	[[assignedVehicle (leader _FlyBoy),(vehicle _unit),[],[],true,_ammoBox,_HQ],EFUNC(hac,goAmmoSupp)] call EFUNC(common,spawn);

	[leader _HQ, (groupId _grp) + ', affirmative. Supplies are on their way - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
