#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:173 (Action3fncR)
/**
 * @description Removes addAction for slot 3: Enable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit getVariable "HAL_TaskEnabledID";
_Unit removeAction _Action;
