#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:267 (ACEAction4fnc)
/**
 * @description Adds ACE interaction menu action for slot 4: Request close air support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEActionR = ["ACEActionR","HAL Supports","",{},{true}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions"], _ACEActionR] call ace_interact_menu_fnc_addActionToObject;

	private _ACEAction = ["HALReqAir","Request Air Support","",{

		[_target] remoteExec ['hal_tasking_fnc_action4ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionR"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
