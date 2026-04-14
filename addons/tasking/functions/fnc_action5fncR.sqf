#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:402 (Action5fncR)
/**
 * @description Removes addAction for slot 5: Request infantry support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqInfID";
	_Unit removeAction _Action;
