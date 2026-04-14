#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1187 (Action13fnc)
/**
 * @description Adds addAction for slot 13: Request repair support truck
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Repair Support",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action13ct',2]
		"
		,
		_Unit,-4.5,false,false,"","_target isEqualTo (vehicle player)",0.01];

	_Unit setVariable ["HAL_ReqRSuppID",_Action];
