#include "..\script_component.hpp"
// Phase 1 no-op stub — real implementation migrates in Phase 3 (FUNC-04)
// TODO Phase 3: port RYD_RandomAround from nr6_hal/HAC_fnc.sqf — returns a random position within radius of given center
// Call sites: addons/common/functions/fnc_flares.sqf:121, fnc_smoke.sqf:73, fnc_wait.sqf:272

/**
 * @description [STUB] Returns a random position within given radius of a center point. Phase 1 no-op — returns input position unchanged.
 * @param {Array} Center position [x, y] or [x, y, z]
 * @param {Number} Radius (ignored in stub)
 * @return {Array} Center position (pass-through)
 */
params [["_center", [0, 0, 0], [[]]], ["_radius", 0, [0]]];

// Phase 1: return center unchanged. Legacy RYD_RandomAround still runs via
// nr6_hal/ layer until Phase 5 cutover.
_center
