#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1004 (Action11fnc)
/**
 * @description Adds addAction for slot 11: Request ambulance (ground medical)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Ambulance",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action11ct',2]
		"
		,
		_Unit,-4.3,false,false,"","_target isEqualTo (vehicle player)",0.01];

	_Unit setVariable ["HAL_ReqMSuppID",_Action];
