#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1232 (ACEAction13fncR)
/**
 * @description Removes ACE interaction menu action for slot 13: Request repair support truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionL","HALReqRSupp"]] call ace_interact_menu_fnc_removeActionFromObject;
	[_Unit,1,["ACE_SelfActions","ACEActionL"]] call ace_interact_menu_fnc_removeActionFromObject;
