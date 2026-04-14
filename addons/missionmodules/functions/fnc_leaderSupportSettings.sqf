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

    // Editor module overrides CBA setting; CBA setting is the fallback default.
    missionNamespace setVariable [QEGVAR(core,cargoFind)   + _letter, _logic getVariable [QEGVAR(core,cargoFind),   EGVAR(core,cargoFind)]];
    missionNamespace setVariable [QEGVAR(core,noAirCargo)  + _letter, _logic getVariable [QEGVAR(core,noAirCargo),  EGVAR(core,noAirCargo)]];
    missionNamespace setVariable [QEGVAR(core,noLandCargo) + _letter, _logic getVariable [QEGVAR(core,noLandCargo), EGVAR(core,noLandCargo)]];
    missionNamespace setVariable [QEGVAR(core,sMed)        + _letter, _logic getVariable [QEGVAR(core,sMed),        EGVAR(core,sMed)]];
    missionNamespace setVariable [QEGVAR(core,sFuel)       + _letter, _logic getVariable [QEGVAR(core,sFuel),       EGVAR(core,sFuel)]];
    missionNamespace setVariable [QEGVAR(core,sAmmo)       + _letter, _logic getVariable [QEGVAR(core,sAmmo),       EGVAR(core,sAmmo)]];
    missionNamespace setVariable [QEGVAR(core,sRep)        + _letter, _logic getVariable [QEGVAR(core,sRep),        EGVAR(core,sRep)]];
    missionNamespace setVariable [QEGVAR(core,supportWP)   + _letter, _logic getVariable [QEGVAR(core,supportWP),   EGVAR(core,supportWP)]];
    missionNamespace setVariable [QEGVAR(core,artyShells)  + _letter, _logic getVariable [QEGVAR(core,artyShells),  EGVAR(core,artyShells)]];
    missionNamespace setVariable [QEGVAR(core,airEvac)     + _letter, _logic getVariable [QEGVAR(core,airEvac),     EGVAR(core,airEvac)]];
    missionNamespace setVariable [QEGVAR(core,supportRTB)  + _letter, _logic getVariable [QEGVAR(core,supportRTB),  EGVAR(core,supportRTB)]];

} forEach _commanders;
