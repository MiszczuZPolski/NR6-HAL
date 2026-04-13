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

    // NOTE: Pre-existing quirk preserved verbatim — legacy code wrote the
    // literal string "DEFEND" via str(). New form writes the string directly.
    if (_logic getVariable [QEGVAR(core,order), false]) then {
        missionNamespace setVariable [QEGVAR(core,order) + _letter, "DEFEND"];
    };

    // Editor module overrides CBA setting; CBA setting is the fallback default.
    missionNamespace setVariable [QEGVAR(core,berserk)           + _letter, _logic getVariable [QEGVAR(core,berserk),           EGVAR(core,berserk)]];
    missionNamespace setVariable [QEGVAR(core,simpleMode)        + _letter, _logic getVariable [QEGVAR(core,simpleMode),        EGVAR(core,simpleMode)]];
    missionNamespace setVariable [QEGVAR(core,unlimitedCapt)     + _letter, _logic getVariable [QEGVAR(core,unlimitedCapt),     EGVAR(core,unlimitedCapt)]];
    missionNamespace setVariable [QEGVAR(core,captLimit)         + _letter, _logic getVariable [QEGVAR(core,captLimit),         EGVAR(core,captLimit)]];
    missionNamespace setVariable [QEGVAR(core,garrR)             + _letter, _logic getVariable [QEGVAR(core,garrR),             EGVAR(core,garrR)]];
    missionNamespace setVariable [QEGVAR(core,objHoldTime)       + _letter, _logic getVariable [QEGVAR(core,objHoldTime),       EGVAR(core,objHoldTime)]];
    missionNamespace setVariable [QEGVAR(core,objRadius1)        + _letter, _logic getVariable [QEGVAR(core,objRadius1),        EGVAR(core,objRadius1)]];
    missionNamespace setVariable [QEGVAR(core,objRadius2)        + _letter, _logic getVariable [QEGVAR(core,objRadius2),        EGVAR(core,objRadius2)]];
    missionNamespace setVariable [QEGVAR(core,lRelocating)       + _letter, _logic getVariable [QEGVAR(core,lRelocating),       EGVAR(core,lRelocating)]];
    missionNamespace setVariable [QEGVAR(core,noRec)             + _letter, _logic getVariable [QEGVAR(core,noRec),             EGVAR(core,noRec)]];
    missionNamespace setVariable [QEGVAR(core,rapidCapt)         + _letter, _logic getVariable [QEGVAR(core,rapidCapt),         EGVAR(core,rapidCapt)]];
    missionNamespace setVariable [QEGVAR(core,defendObjectives)  + _letter, _logic getVariable [QEGVAR(core,defendObjectives),  EGVAR(core,defendObjectives)]];
    missionNamespace setVariable [QEGVAR(core,reconReserve)      + _letter, _logic getVariable [QEGVAR(core,reconReserve),      EGVAR(core,reconReserve)]];
    missionNamespace setVariable [QEGVAR(core,attackReserve)     + _letter, _logic getVariable [QEGVAR(core,attackReserve),     EGVAR(core,attackReserve)]];
    missionNamespace setVariable [QEGVAR(core,aAO)               + _letter, _logic getVariable [QEGVAR(core,aAO),               EGVAR(core,aAO)]];
    missionNamespace setVariable [QEGVAR(core,forceAAO)          + _letter, _logic getVariable [QEGVAR(core,forceAAO),          EGVAR(core,forceAAO)]];
    missionNamespace setVariable [QEGVAR(core,bBAOObj)           + _letter, _logic getVariable [QEGVAR(core,bBAOObj),           EGVAR(core,bBAOObj)]];
    missionNamespace setVariable [QEGVAR(core,maxSimpleObjs)     + _letter, _logic getVariable [QEGVAR(core,maxSimpleObjs),     EGVAR(core,maxSimpleObjs)]];
    missionNamespace setVariable [QEGVAR(core,cRDefRes)          + _letter, _logic getVariable [QEGVAR(core,cRDefRes),          EGVAR(core,cRDefRes)]];
    missionNamespace setVariable [QEGVAR(hac,objectiveRespawn) + _letter, _logic getVariable [QEGVAR(hac,objectiveRespawn), EGVAR(hac,objectiveRespawn)]];

} forEach _commanders;
