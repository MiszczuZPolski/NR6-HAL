#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1221 (Action13fncR)
/**
 * @description Removes addAction for slot 13: Request repair support truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqRSuppID";
	_Unit removeAction _Action;
