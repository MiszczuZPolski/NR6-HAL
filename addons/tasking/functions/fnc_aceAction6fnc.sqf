#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:498 (ACEAction6fnc)
/**
 * @description Adds ACE interaction menu action for slot 6: Request armored support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALReqArm","Request Armored Support","",{

		[_target] remoteExec ['hal_tasking_fnc_action6ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionR"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
