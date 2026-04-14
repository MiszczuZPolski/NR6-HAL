#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:90 (Action3ct)
/**
 * @description Server-side condition/execution handler for slot 3: Enable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

[_unit,'Command, we are available for further tasking - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
_grp setVariable ['Unable',false];
_grp setVariable ['BUnable',false];
