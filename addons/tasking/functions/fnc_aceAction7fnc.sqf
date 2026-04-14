#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:647 (ACEAction7fnc)
/**
 * @description Adds ACE interaction menu action for slot 7: Request air transport (airlift)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALReqTra","Request Transport Support","",{

		[_target] remoteExec ['hal_tasking_fnc_action7ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionR"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
