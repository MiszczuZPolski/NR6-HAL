#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:50 (Action2ct)
/**
 * @description Server-side condition/execution handler for slot 2: Disable HAL tasking for this group
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	[(_this select 0),'Command, we are unavailable for further tasking - Over'] remoteExecCall ["RYD_MP_Sidechat"];
	group (_this select 0) setVariable ['Unable',true];
	group (_this select 0) setVariable ['BUnable',true];
