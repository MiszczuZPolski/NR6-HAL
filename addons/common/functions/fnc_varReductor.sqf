#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_VarReductor)

/**
 * @description Increments the attack counter for a given unit type on a target group,
 *              and decrements the per-group attack slot variable.
 * @param {Object} Target unit
 * @param {String} Attack type: "InfAttacked", "SnpAttacked", "ArmorAttacked", "AirAttacked", "NavAttacked"
 */

params ["_trg", "_kind"];

private _HAC_Attacked = (group _trg) getVariable ["HAC_Attacked", [0,0,0,0,0]];
_HAC_Attacked params ["_infEnough", "_armEnough", "_airEnough", "_snpEnough", "_navEnough"];

switch (_kind) do {
    case "InfAttacked":   { _infEnough   = _infEnough   + 1 };
    case "SnpAttacked":   { _snpEnough   = _snpEnough   + 1 };
    case "ArmorAttacked": { _armEnough   = _armEnough   + 1 };
    case "AirAttacked":   { _airEnough   = _airEnough   + 1 };
    case "NavAttacked":   { _navEnough   = _navEnough   + 1 };
};

(group _trg) setVariable ["HAC_Attacked", [_infEnough, _armEnough, _airEnough, _snpEnough, _navEnough]];

if (_kind != "AirAttacked") then {
    private _isAttacked = (group _trg) getVariable [_kind + str (group _trg), 0];
    if (_isAttacked > 0) then {
        (group _trg) setVariable [_kind + str (group _trg), _isAttacked - 1];
    };
};
