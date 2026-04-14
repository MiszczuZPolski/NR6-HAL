#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:413 (ACEAction5fncR)
/**
 * @description Removes ACE interaction menu action for slot 5: Request infantry support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionR","HALReqInf"]] call ace_interact_menu_fnc_removeActionFromObject;
