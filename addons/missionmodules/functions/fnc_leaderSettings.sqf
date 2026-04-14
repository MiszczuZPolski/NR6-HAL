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

    missionNamespace setVariable [QEGVAR(core,fast)          + _letter, _logic getVariable [QEGVAR(core,fast),          EGVAR(core,fast)]];
    missionNamespace setVariable [QEGVAR(core,commDelay)     + _letter, _logic getVariable [QEGVAR(core,commDelay),     EGVAR(core,commDelay)]];
    missionNamespace setVariable [QEGVAR(common,chatDebug)   + _letter, _logic getVariable [QEGVAR(common,chatDebug),   EGVAR(common,chatDebug)]];
    missionNamespace setVariable [QEGVAR(core,exInfo)        + _letter, _logic getVariable [QEGVAR(core,exInfo),        EGVAR(core,exInfo)]];
    missionNamespace setVariable [QEGVAR(core,resetTime)     + _letter, _logic getVariable [QEGVAR(core,resetTime),     EGVAR(core,resetTime)]];
    missionNamespace setVariable [QEGVAR(core,resetOnDemand) + _letter, _logic getVariable [QEGVAR(core,resetOnDemand), EGVAR(core,resetOnDemand)]];
    missionNamespace setVariable [QEGVAR(core,subAll)        + _letter, _logic getVariable [QEGVAR(core,subAll),        EGVAR(core,subAll)]];
    missionNamespace setVariable [QEGVAR(core,subSynchro)    + _letter, _logic getVariable [QEGVAR(core,subSynchro),    EGVAR(core,subSynchro)]];
    missionNamespace setVariable [QEGVAR(core,knowTL)        + _letter, _logic getVariable [QEGVAR(core,knowTL),        EGVAR(core,knowTL)]];
    missionNamespace setVariable [QEGVAR(core,getHQInside)   + _letter, _logic getVariable [QEGVAR(core,getHQInside),   EGVAR(core,getHQInside)]];
    missionNamespace setVariable [QEGVAR(hac,camV)       + _letter, _logic getVariable [QEGVAR(hac,camV),       EGVAR(hac,camV)]];
    missionNamespace setVariable [QEGVAR(core,infoMarkers)   + _letter, _logic getVariable [QEGVAR(core,infoMarkers),   EGVAR(core,infoMarkers)]];
    missionNamespace setVariable [QEGVAR(core,artyMarks)     + _letter, _logic getVariable [QEGVAR(core,artyMarks),     EGVAR(core,artyMarks)]];
    missionNamespace setVariable [QEGVAR(core,secTasks)      + _letter, _logic getVariable [QEGVAR(core,secTasks),      EGVAR(core,secTasks)]];
    missionNamespace setVariable [QEGVAR(common,debug)       + _letter, _logic getVariable [QEGVAR(common,debug),       EGVAR(common,debug)]];

} forEach _commanders;
