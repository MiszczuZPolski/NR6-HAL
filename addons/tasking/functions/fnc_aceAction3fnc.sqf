#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:115 (ACEAction3fnc)
/**
 * @description Adds ACE interaction menu action for slot 3: Enable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALEnableTasking","Enable Tasking","",{

			[_target] remoteExecCall ['hal_tasking_fnc_action3ct',2]

		},{true},{}] call ace_interact_menu_fnc_createAction;
		[_Unit, 1, ["ACE_SelfActions","ACEActionP"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
