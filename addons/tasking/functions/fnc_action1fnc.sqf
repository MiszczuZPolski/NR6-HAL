#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:23 (Action1fnc)
/**
 * @description Adds addAction for slot 1: Deny/cancel assigned task
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit addAction ["[HAL Tasking] Deny Assigned Task","[_this select 3] remoteExec ['hal_tasking_fnc_action1ct',2]",_Unit,-2,false,false,"","_target isEqualTo (vehicle player)",0.01];
_Unit setVariable ["HAL_TaskAddedID",_Action];
