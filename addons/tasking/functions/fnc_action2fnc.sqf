#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:58 (Action2fnc)
/**
 * @description Adds addAction for slot 2: Disable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit addAction ["[HAL Tasking] Disable Tasking",
	"
	[_this select 3] remoteExecCall ['hal_tasking_fnc_action2ct',2]
	"
	,
	_Unit,-2.1,false,false,"","_target isEqualTo (vehicle player)",0.01];

_Unit setVariable ["HAL_TaskDisabledID",_Action];
