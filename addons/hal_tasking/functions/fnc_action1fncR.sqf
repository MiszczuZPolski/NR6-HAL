#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:131 (Action1fncR)
/**
 * @description Removes addAction for slot 1: Deny/cancel assigned task
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit","_Action"];

	_Unit = _this select 0;

	_Action = _Unit getVariable "HAL_TaskAddedID";
	_Unit removeAction _Action;
