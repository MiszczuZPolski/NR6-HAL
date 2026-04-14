#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];

{
    if ((typeOf _x) == QGVAR(Leader_Module)) then {_commanders pushBack _x};
} forEach (synchronizedObjects _logic);

{
    private _leaderName = (_x getVariable "LeaderType");

    private _letter = switch (_leaderName) do {
        case "LeaderHQ":  {""};
        case "LeaderHQB": {"B"};
        case "LeaderHQC": {"C"};
        case "LeaderHQD": {"D"};
        case "LeaderHQE": {"E"};
        case "LeaderHQF": {"F"};
        case "LeaderHQG": {"G"};
        case "LeaderHQH": {"H"};
        default {""};
    };

    private _leaderObj = call compile _leaderName;

    // Editor module overrides the CBA setting when the attribute is present on
    // the logic. When absent, the CBA setting (registered in
    // addons/core/initSettings.inc.sqf) is used as the fallback default.

    missionNamespace setVariable [QEGVAR(core,smoke)           + _letter, _logic getVariable [QEGVAR(core,smoke),           EGVAR(core,smoke)]];
    missionNamespace setVariable [QEGVAR(core,flare)           + _letter, _logic getVariable [QEGVAR(core,flare),           EGVAR(core,flare)]];
    missionNamespace setVariable [QEGVAR(core,garrVehAb)       + _letter, _logic getVariable [QEGVAR(core,garrVehAb),       EGVAR(core,garrVehAb)]];
    missionNamespace setVariable [QEGVAR(core,idleOrd)         + _letter, _logic getVariable [QEGVAR(core,idleOrd),         EGVAR(core,idleOrd)]];
    missionNamespace setVariable [QEGVAR(core,idleDef)         + _letter, _logic getVariable [QEGVAR(core,idleDef),         EGVAR(core,idleDef)]];
    missionNamespace setVariable [QEGVAR(core,flee)            + _letter, _logic getVariable [QEGVAR(core,flee),            EGVAR(core,flee)]];
    missionNamespace setVariable [QEGVAR(core,surr)            + _letter, _logic getVariable [QEGVAR(core,surr),            EGVAR(core,surr)]];
    missionNamespace setVariable [QEGVAR(core,muu)             + _letter, _logic getVariable [QEGVAR(core,muu),             EGVAR(core,muu)]];
    missionNamespace setVariable [QEGVAR(core,rush)            + _letter, _logic getVariable [QEGVAR(core,rush),            EGVAR(core,rush)]];
    missionNamespace setVariable [QEGVAR(core,withdraw)        + _letter, _logic getVariable [QEGVAR(core,withdraw),        EGVAR(core,withdraw)]];
    missionNamespace setVariable [QEGVAR(core,airDist)         + _letter, _logic getVariable [QEGVAR(core,airDist),         EGVAR(core,airDist)]];
    missionNamespace setVariable [QEGVAR(core,dynForm)         + _letter, _logic getVariable [QEGVAR(core,dynForm),         EGVAR(core,dynForm)]];
    missionNamespace setVariable [QEGVAR(core,defRange)        + _letter, _logic getVariable [QEGVAR(core,defRange),        EGVAR(core,defRange)]];
    missionNamespace setVariable [QEGVAR(core,garrRange)       + _letter, _logic getVariable [QEGVAR(core,garrRange),       EGVAR(core,garrRange)]];
    missionNamespace setVariable [QEGVAR(core,attInfDistance)  + _letter, _logic getVariable [QEGVAR(core,attInfDistance),  EGVAR(core,attInfDistance)]];
    missionNamespace setVariable [QEGVAR(core,attArmDistance)  + _letter, _logic getVariable [QEGVAR(core,attArmDistance),  EGVAR(core,attArmDistance)]];
    missionNamespace setVariable [QEGVAR(core,attSnpDistance)  + _letter, _logic getVariable [QEGVAR(core,attSnpDistance),  EGVAR(core,attSnpDistance)]];
    missionNamespace setVariable [QEGVAR(core,flankDistance)   + _letter, _logic getVariable [QEGVAR(core,flankDistance),   EGVAR(core,flankDistance)]];
    missionNamespace setVariable [QEGVAR(core,attSFDistance)   + _letter, _logic getVariable [QEGVAR(core,attSFDistance),   EGVAR(core,attSFDistance)]];
    missionNamespace setVariable [QEGVAR(core,reconDistance)   + _letter, _logic getVariable [QEGVAR(core,reconDistance),   EGVAR(core,reconDistance)]];
    missionNamespace setVariable [QEGVAR(core,captureDistance) + _letter, _logic getVariable [QEGVAR(core,captureDistance), EGVAR(core,captureDistance)]];
    missionNamespace setVariable [QEGVAR(common,uAVAlt)        + _letter, _logic getVariable [QEGVAR(common,uAVAlt),        EGVAR(common,uAVAlt)]];
    missionNamespace setVariable [QEGVAR(core,combining)       + _letter, _logic getVariable [QEGVAR(core,combining),       EGVAR(core,combining)]];

} forEach _commanders;
