#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:958 (ACEAction10fncR)
/**
 * @description Removes ACE interaction menu action for slot 10: Request fuel truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionL","HALReqFSupp"]] call ace_interact_menu_fnc_removeActionFromObject;
