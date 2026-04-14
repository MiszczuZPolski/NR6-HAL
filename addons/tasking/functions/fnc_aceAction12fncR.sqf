#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1140 (ACEAction12fncR)
/**
 * @description Removes ACE interaction menu action for slot 12: Request aerial medical support (MEDEVAC)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionL","HALReqMASupp"]] call ace_interact_menu_fnc_removeActionFromObject;
