#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:33 (ACEAction1fnc)
/**
 * @description Adds ACE interaction menu action for slot 1: Deny/cancel assigned task
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEActionP = ["ACEActionP","HAL Tasking","",{},{true}] call ace_interact_menu_fnc_createAction;
	private _ACEAction = ["HALDenyAssignedTask","Deny Assigned Task","",{

		[_target] remoteExec ['hal_tasking_fnc_action1ct',2]
				
		},{true},{}] call ace_interact_menu_fnc_createAction;
	[_Unit, 1, ["ACE_SelfActions"], _ACEActionP] call ace_interact_menu_fnc_addActionToObject;
	[_Unit, 1, ["ACE_SelfActions","ACEActionP"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
