#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:856 (Action9fncR)
/**
 * @description Removes addAction for slot 9: Request ammunition truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqASuppID";
	_Unit removeAction _Action;
