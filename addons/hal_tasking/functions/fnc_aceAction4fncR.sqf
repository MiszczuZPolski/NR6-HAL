#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:299 (ACEAction4fncR)
/**
 * @description Removes ACE interaction menu action for slot 4: Request close air support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit"];

	_Unit = _this select 0;

	[_Unit,1,["ACE_SelfActions","ACEActionR","HALReqAir"]] call ace_interact_menu_fnc_removeActionFromObject;
