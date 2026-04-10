#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:515 (Action6fncR)
/**
 * @description Removes addAction for slot 6: Request armored support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit","_Action"];

	_Unit = _this select 0;

	_Action = _Unit getVariable "HAL_ReqArmID";
	_Unit removeAction _Action;
