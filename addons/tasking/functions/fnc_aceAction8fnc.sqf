#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:744 (ACEAction8fnc)
/**
 * @description Adds ACE interaction menu action for slot 8: Request ammunition drop (air supply)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];


	private _ACEActionL = ["ACEActionL","HAL Logistics","",{},{true}] call ace_interact_menu_fnc_createAction;
	[_Unit, 1, ["ACE_SelfActions"], _ACEActionL] call ace_interact_menu_fnc_addActionToObject;

	private _ACEAction = ["HALReqDSupp","Request Ammunition Drop","",{

		[_target] remoteExec ['hal_tasking_fnc_action8ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions","ACEActionL"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
