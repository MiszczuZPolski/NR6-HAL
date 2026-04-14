#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_GoLaunch)

/**
 * @description Returns the attack function code block for the given unit type.
 * @param {String} Unit type - "INF", "ARM", "SNP", "AIR", "AIRCAP", or "NAVAL"
 * @return {Code} Attack function code block, or empty code {} if type is unknown
 */

params ["_kind"];

private _lookup = createHashMapFromArray [
    ["INF",    EFUNC(hac,goAttInf)],
    ["ARM",    EFUNC(hac,goAttArmor)],
    ["SNP",    EFUNC(hac,goAttSniper)],
    ["AIR",    EFUNC(hac,goAttAir)],
    ["AIRCAP", EFUNC(hac,goAttAirCAP)],
    ["NAVAL",  EFUNC(hac,goAttNaval)]
];

_lookup getOrDefault [_kind, {}]
