#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "cba_main",
            "hal_main",
            "hal_data",
            "hal_hac",
            "hal_boss",
            "hal_tasking",
            "hal_missionmodules"
        };
        author = "MiszczuZPolski";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"

// ============================================================================
// LEGACY CLASSNAME INVENTORY (audited from nr6_hal/config.cpp, 2026-04-10)
// Per D-13, D-14: inventory only in Phase 1. Actual CfgVehicles old->new
// class mappings will be written in Phase 5 (D-15) when new classnames stable.
// ============================================================================
//
// --- CfgPatches unit classnames (9 editor-placeable modules) ---
// NR6_HAL_Core_Module                -> hal_missionmodules_Core_Module
// NR6_HAL_Leader_Module              -> hal_missionmodules_Leader_Module
// NR6_HAL_Leader_Settings_Module     -> hal_missionmodules_Leader_Settings_Module
// NR6_HAL_GenSettings_Module         -> hal_missionmodules_GenSettings_Module
// NR6_HAL_Leader_BehSettings_Module  -> hal_missionmodules_Leader_BehSettings_Module
// NR6_HAL_Objective_Module           -> hal_missionmodules_Leader_Objective_Module
// NR6_HAL_BBObjective_Module         -> hal_missionmodules_BBLeader_Objective_Module
// NR6_HAL_BBLeader_Module            -> hal_missionmodules_BBLeader_Module
// NR6_HAL_Front_Module               -> hal_missionmodules_Leader_Front_Module
//
// --- CfgFunctions legacy class bindings (~45 entries under class NR6) ---
// HALcore, HALGenset, HALLead, HALLeadset, HALLeadBeh, HALLeadPers,
// HALLeadSup, HALLeadObj, HALObj, HALSObj, HALNObj, HALBBObj, HALBB,
// HALBBZone, HALAmmoDepot, HALBBSet, HALExclude, HALFront, HALIdleDecoy,
// HALInclude, HALRestDecoy, HALSuppDecoy, AmmoDrop, AlwaysKnownU, AOnly,
// CargoOnly, ExReammo, ExMedic, AlwaysUnKnownU, ExRefuel, FirstToFight,
// RTBRRR, ExRepair, Garrison, NoAttack, NoCargo, NoDef, NoRecon, NoReports,
// NoFlank, ROnly, SFBodyGuard, Unable, RCAS, RCAP
// -> To be mapped to PREP-compiled hal_*_fnc_* functions in Phase 5 via compat_vars.sqf.
//
// --- CfgRadio sound classes (~100+ HAC_* and HAC_SILENTM_* classes) ---
// Prefixes: HAC_OrdConf*, HAC_OrdDen*, HAC_OrdFinal*, HAC_OrdEnd*,
//           HAC_SuppReq*, HAC_MedReq*, HAC_ArtyReq*, HAC_SmokeReq*,
//           HAC_IllumReq*, HAC_InDanger*, HAC_SILENTM_*, HAC_SILENTM_HQ_ord_*
// -> Called programmatically by HAL SQF code. Missions do not reference by classname.
// -> No compat mapping required for radio sounds.
// ============================================================================
