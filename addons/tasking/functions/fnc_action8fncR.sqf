#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:765 (Action8fncR)
/**
 * @description Removes addAction for slot 8: Request ammunition drop (air supply)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqDSuppID";
	_Unit removeAction _Action;
