#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Seed missionmodules namespace defaults. These variables are read unconditionally
// by boss/hac/core functions before the Big Boss editor module fires (which sets
// active=true) or before bbSettings runs (which sets lRelocating). Without these
// defaults the runtime raises "Undefined variable" on any mission that does not
// use the Big Boss high-commander feature.
GVAR(active)              = false;
GVAR(debug)               = false;
GVAR(lRelocating)         = true;
GVAR(lRelocating_Instant) = false;
GVAR(bBOnMap)             = false;
GVAR(mapLng)              = 0;
GVAR(mapXMax)             = 0;
GVAR(mapXMin)             = 0;
GVAR(mapYMax)             = 0;
GVAR(mapYMin)             = 0;
GVAR(mapC)                = [];
GVAR(mapReady)            = false;
GVAR(sectors)             = [];
// civF and mC are intentionally NOT seeded here — both are guarded by
// isNil QEGVAR(missionmodules,*) checks in fnc_boss.sqf. Seeding them
// with a placeholder would make those guards always-true and break the
// "no BB zone placed" detection logic.
GVAR(takenLeader)         = "";

ADDON = true;
