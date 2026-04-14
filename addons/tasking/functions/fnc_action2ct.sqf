#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:50 (Action2ct)
/**
 * @description Server-side condition/execution handler for slot 2: Disable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

[_unit,'Command, we are unavailable for further tasking - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
_grp setVariable ['Unable',true];
_grp setVariable ['BUnable',true];
