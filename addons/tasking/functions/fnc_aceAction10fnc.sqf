#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:930 (ACEAction10fnc)
/**
 * @description Adds ACE interaction menu action for slot 10: Request fuel truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALReqFSupp","Request Fuel Truck","",{

		[_target] remoteExec ['hal_tasking_fnc_action10ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionL"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
