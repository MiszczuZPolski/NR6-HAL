#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1129 (Action12fncR)
/**
 * @description Removes addAction for slot 12: Request aerial medical support (MEDEVAC)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_Unit","_Action"];

	_Unit = _this select 0;

	_Action = _Unit getVariable "HAL_ReqMASuppID";
	_Unit removeAction _Action;
