#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1049 (ACEAction11fncR)
/**
 * @description Removes ACE interaction menu action for slot 11: Request ambulance (ground medical)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionL","HALReqMSupp"]] call ace_interact_menu_fnc_removeActionFromObject;
