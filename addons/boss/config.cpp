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
            "hal_hac"
        };
        author = "MiszczuZPolski";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
