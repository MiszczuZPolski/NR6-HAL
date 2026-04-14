#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:163 (ACEAction2fncR)
/**
 * @description Removes ACE interaction menu action for slot 2: Disable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	[_Unit,1,["ACE_SelfActions","ACEActionP","HALDisableTasking"]] call ace_interact_menu_fnc_removeActionFromObject;
