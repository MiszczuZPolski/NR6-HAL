#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:481 (Action6fnc)
/**
 * @description Adds addAction for slot 6: Request armored support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Supports] Request Armored Support",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action6ct',2]
		"
		, 
		_Unit,-3.2,false,false,"","_target isEqualTo (vehicle player)",0.01];
	
	_Unit setVariable ["HAL_ReqArmID",_Action];
