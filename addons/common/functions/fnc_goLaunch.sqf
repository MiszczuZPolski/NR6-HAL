#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_GoLaunch)

/**
 * @description Returns the attack function code block for the given unit type.
 * @param {String} Unit type - "INF", "ARM", "SNP", "AIR", "AIRCAP", or "NAVAL"
 * @return {Code} Attack function code block, or empty code {} if type is unknown
 */

params ["_kind"];

private _lookup = createHashMapFromArray [
    ["INF",    HAL_GoAttInf],
    ["ARM",    HAL_GoAttArmor],
    ["SNP",    HAL_GoAttSniper],
    ["AIR",    HAL_GoAttAir],
    ["AIRCAP", HAL_GoAttAirCAP],
    ["NAVAL",  HAL_GoAttNaval]
];

_lookup getOrDefault [_kind, {}]
