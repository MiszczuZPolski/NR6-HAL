#include "script_component.hpp"

// ---------------------------------------------------------------------------
// HQSitRep dispatch seeds (Phase 6 — replacement for compat_nr6hal/XEH_postInit.sqf:69-76)
//
// fnc_init.sqf dispatches HQSitRep loops by runtime string concatenation:
//     missionNamespace getVariable (_codeSign + "_HQSitRep")
// where _codeSign is "A".."H". Because the suffix is selected at runtime,
// this cannot be rewritten to EFUNC() — the 8 handles must live on
// missionNamespace. Previously compat_nr6hal seeded them; with compat gone,
// core owns them directly. isNil guards keep us safe on JIP re-entry.
// ---------------------------------------------------------------------------
if (isNil "A_HQSitRep") then { A_HQSitRep = EFUNC(core,HQSitRep)  };
if (isNil "B_HQSitRep") then { B_HQSitRep = EFUNC(core,HQSitRepB) };
if (isNil "C_HQSitRep") then { C_HQSitRep = EFUNC(core,HQSitRepC) };
if (isNil "D_HQSitRep") then { D_HQSitRep = EFUNC(core,HQSitRepD) };
if (isNil "E_HQSitRep") then { E_HQSitRep = EFUNC(core,HQSitRepE) };
if (isNil "F_HQSitRep") then { F_HQSitRep = EFUNC(core,HQSitRepF) };
if (isNil "G_HQSitRep") then { G_HQSitRep = EFUNC(core,HQSitRepG) };
if (isNil "H_HQSitRep") then { H_HQSitRep = EFUNC(core,HQSitRepH) };
