#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:152 (Action2fncR)
/**
 * @description Removes addAction for slot 2: Disable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit getVariable "HAL_TaskDisabledID";
_Unit removeAction _Action;
