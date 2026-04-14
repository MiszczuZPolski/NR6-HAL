#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {
            QGVAR(Core_Module),
            QGVAR(GenSettings_Module),
            QGVAR(Leader_Module),
            QGVAR(Leader_Settings_Module),
            QGVAR(Leader_BehSettings_Module),
            QGVAR(Leader_PersSettings_Module),
            QGVAR(Leader_SupSettings_Module),
            QGVAR(Leader_ObjSettings_Module),
            QGVAR(Leader_IdleDecoy_Module),
            QGVAR(Leader_WithdrawDecoy_Module),
            QGVAR(Leader_SuppDecoy_Module),
            QGVAR(Leader_Front_Module),
            QGVAR(Leader_Objective_Module),
            QGVAR(Leader_SimpleObjective_Module),
            QGVAR(Leader_NavalObjective_Module),
            QGVAR(Leader_AmmoDepot_Module),
            QGVAR(Leader_Include_Module),
            QGVAR(Leader_Exclude_Module),
            QGVAR(Squad_AmmoDrop_Module),
            QGVAR(Squad_AOnly_Module),
            QGVAR(Squad_CargoOnly_Module),
            QGVAR(Squad_ROnly_Module),
            QGVAR(Squad_ExReammo_Module),
            QGVAR(Squad_ExMedic_Module),
            QGVAR(Squad_ExRefuel_Module),
            QGVAR(Squad_FirstToFight_Module),
            QGVAR(Squad_RTBRRR_Module),
            QGVAR(Squad_ExRepair_Module),
            QGVAR(Squad_Garrison_Module),
            QGVAR(Squad_NoAttack_Module),
            QGVAR(Squad_NoCargo_Module),
            QGVAR(Squad_NoDef_Module),
            QGVAR(Squad_NoReports_Module),
            QGVAR(Squad_Unable_Module),
            QGVAR(Squad_NoRecon_Module),
            QGVAR(Squad_NoFlank_Module),
            QGVAR(Squad_SFBodyGuard_Module),
            QGVAR(Squad_AlwaysKnownU_Module),
            QGVAR(Squad_AlwaysUnKnownU_Module),
            QGVAR(Squad_RCAS_Module),
            QGVAR(Squad_RCAP_Module),
            QGVAR(BBLeader_Module),
            QGVAR(BBSettings_Module),
            QGVAR(BBZone_Module),
            QGVAR(BBLeader_Objective_Module)
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "cba_main",
            "hal_main",
            "A3_Modules_F"
        };
        author = "MiszczuZPolski";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgFactionClasses.hpp"
#include "CfgVehicles.hpp"
