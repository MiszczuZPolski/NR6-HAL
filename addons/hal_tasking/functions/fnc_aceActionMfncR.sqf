#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1290 (ACEActionMfncR)
/**
 * @description Removes HAL communication menu ACE action from unit
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit"];

	_Unit = _this select 0;

	[_Unit,1,["ACE_SelfActions","HALMenu"]] call ace_interact_menu_fnc_removeActionFromObject;
