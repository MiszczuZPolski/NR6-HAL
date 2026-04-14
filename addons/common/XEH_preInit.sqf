#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(handles) = [];

// Seed per-HQ debug flags. EGVAR(common,debug) is registered as a CBA setting
// (default false) in core/initSettings.inc.sqf. debugB..H are not CBA settings —
// they are seeded here so fnc_init.sqf:183 can read them unconditionally before
// any HQSitRep function runs (which has its own lazy nil-guard but fires later).
GVAR(debugB) = false;
GVAR(debugC) = false;
GVAR(debugD) = false;
GVAR(debugE) = false;
GVAR(debugF) = false;
GVAR(debugG) = false;
GVAR(debugH) = false;

ADDON = true;
