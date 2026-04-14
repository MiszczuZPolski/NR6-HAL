#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:526 (ACEAction6fncR)
/**
 * @description Removes ACE interaction menu action for slot 6: Request armored support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionR","HALReqArm"]] call ace_interact_menu_fnc_removeActionFromObject;
//	[_Unit,1,["ACE_SelfActions","ACEActionR"]] call ace_interact_menu_fnc_removeActionFromObject;
