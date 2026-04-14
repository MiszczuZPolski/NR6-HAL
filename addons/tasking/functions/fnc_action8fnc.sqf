#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:727 (Action8fnc)
/**
 * @description Adds addAction for slot 8: Request ammunition drop (air supply)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Ammunition Drop",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action8ct',2]
		"
		, 
		_Unit,-4,false,false,"","_target isEqualTo (vehicle player)",0.01];
	
	_Unit setVariable ["HAL_ReqDSuppID",_Action];
