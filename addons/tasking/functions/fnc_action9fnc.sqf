#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:822 (Action9fnc)
/**
 * @description Adds addAction for slot 9: Request ammunition truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Ammunition Truck",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action9ct',2]
		"
		, 
		_Unit,-4.1,false,false,"","_target isEqualTo (vehicle player)",0.01];
	
	_Unit setVariable ["HAL_ReqASuppID",_Action];
