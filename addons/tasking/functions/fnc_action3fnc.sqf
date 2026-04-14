#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:98 (Action3fnc)
/**
 * @description Adds addAction for slot 3: Enable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit addAction ["[HAL Tasking] Enable Tasking",
	"
	[_this select 3] remoteExecCall ['hal_tasking_fnc_action3ct',2]
	"
	,
	_Unit,-2.2,false,false,"","_target isEqualTo (vehicle player)",0.01];

_Unit setVariable ["HAL_TaskEnabledID",_Action];
