#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1262 (ACEActionMfnc)
/**
 * @description Adds HAL communication menu ACE interaction action to unit
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _ACEAction = ["HALMenu","[HAL] Show Communication Menu","",{

		showCommandingMenu '#USER:NR6_Player_Menu';

		},{true},{}] call ace_interact_menu_fnc_createAction;

	[_Unit, 1, ["ACE_SelfActions"], _ACEAction] call ace_interact_menu_fnc_addActionToObject;
