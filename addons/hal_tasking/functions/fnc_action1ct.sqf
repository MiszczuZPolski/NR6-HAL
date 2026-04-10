#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:3 (Action1ct)
/**
 * @description Server-side condition/execution handler for slot 1: Deny/cancel assigned task
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	(group (_this select 0)) setVariable [('Resting' + (str (group (_this select 0)))),false]; 
	(group (_this select 0)) setVariable [('Garrisoned' + (str (group (_this select 0)))),false];
	(group (_this select 0)) setVariable [('NOGarrisoned' + (str (group (_this select 0)))),true];


	[(_this select 0),RydxHQ_AIC_OrdDen,'OrdDen'] call EFUNC(common,AIChatter);
	deleteWaypoint [(group (_this select 0)),(currentWaypoint (group (_this select 0)))];

	{
	[_x,'CANCELED',true] call BIS_fnc_taskSetState;
	} forEach ((group (_this select 0)) getVariable ['HACAddedTasks',[]]);

	if ((group (_this select 0)) getVariable ["Busy" + str (group (_this select 0)),true]) then {(group (_this select 0)) setVariable ["Break",true]};
