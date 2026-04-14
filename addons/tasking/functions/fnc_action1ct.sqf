#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:3 (Action1ct)
/**
 * @description Server-side condition/execution handler for slot 1: Deny/cancel assigned task
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

_grp setVariable [('Resting' + (str _grp)),false];
_grp setVariable [('Garrisoned' + (str _grp)),false];
_grp setVariable [('NOGarrisoned' + (str _grp)),true];


[_unit,EGVAR(common,aIC_OrdDen),'OrdDen'] call EFUNC(common,AIChatter);
deleteWaypoint [_grp,(currentWaypoint _grp)];

{
[_x,'CANCELED',true] call BIS_fnc_taskSetState;
} forEach (_grp getVariable ['HACAddedTasks',[]]);

if (_grp getVariable ["Busy" + str _grp,true]) then {_grp setVariable ["Break",true]};
