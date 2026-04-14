#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:385 (ACEAction5fnc)
/**
 * @description Adds ACE interaction menu action for slot 5: Request infantry support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALReqInf","Request Infantry Support","",{

		[_target] remoteExec ['hal_tasking_fnc_action5ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionR"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
