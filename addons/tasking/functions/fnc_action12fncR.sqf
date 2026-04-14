#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1129 (Action12fncR)
/**
 * @description Removes addAction for slot 12: Request aerial medical support (MEDEVAC)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqMASuppID";
	_Unit removeAction _Action;
