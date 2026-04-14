#include "..\script_component.hpp"
// Phase 1 no-op stub — real implementation migrates in Phase 3 (FUNC-04)
// TODO Phase 3: port RYD_WPadd from nr6_hal/HAC_fnc.sqf — adds a waypoint with full config (type, behaviour, speed, statements, completion radius, timeout, formation)
// Call sites: addons/common/functions/fnc_wait.sqf:274, fnc_garrisonP.sqf:22, fnc_garrisonP.sqf:31

/**
 * @description [STUB] Adds a configured waypoint to a group. Phase 1 no-op — returns empty array.
 * @param {Array} Groups array
 * @param {Array} Position
 * @param {String} Waypoint type (MOVE, CYCLE, ...)
 * @param {String} Behaviour
 * @param {String} Combat mode
 * @param {String} Speed
 * @param {Array} Statements [condition, onActivation]
 * @param {Boolean} Show
 * @param {Number} Completion radius
 * @param {Array} [Optional] Timeout [min, mid, max]
 * @param {String} [Optional] Formation
 * @return {Array} Empty array (pass-through)
 */
params [
    ["_groups", grpNull, [grpNull]],
    ["_pos", [0, 0, 0]],
    ["_type", "MOVE", [""]],
    ["_behaviour", "AWARE", [""]],
    ["_combatMode", "YELLOW", [""]],
    ["_speed", "NORMAL", [""]],
    ["_statements", ["true", ""], [[]]],
    ["_show", false, [false]],
    ["_completionRadius", 0, [0]],
    ["_timeout", [0, 0, 0], [[]]],
    ["_formation", "NO CHANGE", [""]]
];

// Phase 1: return empty array. Legacy RYD_WPadd still runs via nr6_hal/ layer
// until Phase 5 cutover. DO NOT add real waypoint creation logic here.
[]
