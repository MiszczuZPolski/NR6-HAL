#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:402 (Action5fncR)
/**
 * @description Removes addAction for slot 5: Request infantry support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit","_Action"];

	_Unit = _this select 0;

	_Action = _Unit getVariable "HAL_ReqInfID";
	_Unit removeAction _Action;
