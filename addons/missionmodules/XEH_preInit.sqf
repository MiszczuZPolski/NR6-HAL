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

// RydBBa_HQs / RydBBb_HQs are bare-global arrays populated by fnc_bbLeader when a Big Boss
// Leader module is placed in the editor. hac functions (fnc_goCapture, fnc_hqReset,
// fnc_statusQuo_doctrine, fnc_statusQuo_hqReloc) read these arrays unconditionally on every
// HQ tick — even when no Big Boss module is present (active=false). Without a seed value of
// [] the concatenation (RydBBa_HQs + RydBBb_HQs) crashes with "Undefined variable".
// fnc_bbLeader already has isNil guards; seeding [] here is safe — bbLeader will pushBackUnique
// into these arrays when modules are placed.
if (isNil "RydBBa_HQs") then { RydBBa_HQs = [] };
if (isNil "RydBBb_HQs") then { RydBBb_HQs = [] };

// RydBBa_SAL / RydBBb_SAL are editor-placed unit objects (the "Sector Attack Leader"
// debug relay unit). They are never assigned in code — mission designers place a unit
// and give it the editor variable name RydBBa_SAL / RydBBb_SAL.
// fnc_boss.sqf reads them at lines 264-265 (_BBSAL = RydBBa_SAL) and uses them in
// globalChat calls and as argument to synchronizedObjects.
// If the mission has no SAL unit placed, these are nil → synchronizedObjects nil crashes.
// Seed as objNull so synchronizedObjects returns [] (no crash) and globalChat is a no-op.
if (isNil "RydBBa_SAL") then { RydBBa_SAL = objNull };
if (isNil "RydBBb_SAL") then { RydBBb_SAL = objNull };

ADDON = true;
