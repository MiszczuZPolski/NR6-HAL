#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:3233-3241 (RYD_PresentRHQLoop)

/**
 * @description Periodic RHQ auto-fill loop — waits 60 seconds, then repeatedly
 *              waits for all HQs to finish pending work and re-presents RHQ assets.
 *              Runs while RydxHQ_RHQAutoFill is true.
 * @return {nil}
 */
params [];

sleep 60;
while {EGVAR(core,rHQAutoFill)} do {
    waitUntil {sleep 5; (({(_x getVariable [QEGVAR(core,pending),false])} count EGVAR(core,allHQ)) == 0)};
    [] spawn FUNC(presentRHQ);
    sleep 60;
};
