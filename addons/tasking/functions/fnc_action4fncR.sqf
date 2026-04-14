#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:288 (Action4fncR)
/**
 * @description Removes addAction for slot 4: Request close air support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit getVariable "HAL_ReqAirID";
_Unit removeAction _Action;
