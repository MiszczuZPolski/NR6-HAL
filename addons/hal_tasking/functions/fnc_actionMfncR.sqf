#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1279 (ActionMfncR)
/**
 * @description Removes HAL communication menu addAction from unit
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit","_Action"];

	_Unit = _this select 0;

	_Action = _Unit getVariable "HAL_ReqMenuID";
	_Unit removeAction _Action;
