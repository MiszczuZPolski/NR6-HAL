#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:515 (Action6fncR)
/**
 * @description Removes addAction for slot 6: Request armored support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqArmID";
	_Unit removeAction _Action;
