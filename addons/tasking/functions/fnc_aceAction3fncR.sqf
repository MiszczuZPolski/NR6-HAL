#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:184 (ACEAction3fncR)
/**
 * @description Removes ACE interaction menu action for slot 3: Enable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionP","HALEnableTasking"]] call ace_interact_menu_fnc_removeActionFromObject;
	[_Unit,1,["ACE_SelfActions","ACEActionP"]] call ace_interact_menu_fnc_removeActionFromObject;
