#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1095 (Action12fnc)
/**
 * @description Adds addAction for slot 12: Request aerial medical support (MEDEVAC)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_Unit"];

	private _Action = _Unit addAction ["[HAL Logistics] Request Aerial Medical Support",
		"
		[_this select 3] remoteExec ['hal_tasking_fnc_action12ct',2]
		"
		,
		_Unit,-4.4,false,false,"","_target isEqualTo (vehicle player)",0.01];

	_Unit setVariable ["HAL_ReqMASuppID",_Action];
