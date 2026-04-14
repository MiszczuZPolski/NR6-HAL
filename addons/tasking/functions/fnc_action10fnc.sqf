#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:913 (Action10fnc)
/**
 * @description Adds addAction for slot 10: Request fuel truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Fuel Truck",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action10ct',2]
		"
		,
		_Unit,-4.2,false,false,"","_target isEqualTo (vehicle player)",0.01];

	_Unit setVariable ["HAL_ReqFSuppID",_Action];
