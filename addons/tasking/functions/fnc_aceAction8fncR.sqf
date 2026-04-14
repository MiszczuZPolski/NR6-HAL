#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:776 (ACEAction8fncR)
/**
 * @description Removes ACE interaction menu action for slot 8: Request ammunition drop (air supply)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionL","HALReqDSupp"]] call ace_interact_menu_fnc_removeActionFromObject;
