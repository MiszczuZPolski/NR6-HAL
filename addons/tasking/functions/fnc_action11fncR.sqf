#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1038 (Action11fncR)
/**
 * @description Removes addAction for slot 11: Request ambulance (ground medical)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit getVariable "HAL_ReqMSuppID";
	_Unit removeAction _Action;
