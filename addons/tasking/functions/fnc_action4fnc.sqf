#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:250 (Action4fnc)
/**
 * @description Adds addAction for slot 4: Request close air support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_Unit"];

private _Action = _Unit addAction ["[HAL Supports] Request Air Support",
	"
	[_this select 3] remoteExec ['hal_tasking_fnc_action4ct',2]
	"
	,
	_Unit,-3,false,false,"","_target isEqualTo (vehicle player)",0.01];

_Unit setVariable ["HAL_ReqAirID",_Action];
