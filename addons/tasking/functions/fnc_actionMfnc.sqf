#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1245 (ActionMfnc)
/**
 * @description Adds HAL communication menu addAction to unit
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL] Show Communication Menu",
		"
		showCommandingMenu '#USER:NR6_Player_Menu';
		"
		, 
		_Unit,-4.5,false,false,"","_target isEqualTo (vehicle player)",50];
	
	_Unit setVariable ["HAL_ReqMenuID",_Action];
