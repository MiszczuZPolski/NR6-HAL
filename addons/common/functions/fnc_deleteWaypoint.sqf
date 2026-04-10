#include "..\script_component.hpp"
// Phase 1 no-op stub — real implementation migrates in Phase 3 (FUNC-04)
// TODO Phase 3: port RYD_DeleteWP from nr6_hal/HAC_fnc.sqf — deletes all waypoints from a group
// Call sites: addons/common/functions/fnc_wait.sqf lines 292, 299, 312

/**
 * @description [STUB] Deletes all waypoints from a group. Phase 1 no-op.
 * @param {Group} Group whose waypoints should be deleted
 * @return {Nothing}
 */
params [["_group", grpNull, [grpNull]]];

// Phase 1: deliberately does nothing. Legacy behavior preserved by the
// nr6_hal/ layer still loaded in parallel until Phase 5 cutover.
nil
