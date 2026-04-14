#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:947 (Action10fncR)
/**
 * @description Removes addAction for slot 10: Request fuel truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqFSuppID";
	_Unit removeAction _Action;
