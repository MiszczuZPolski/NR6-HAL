#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];

{
    if ((typeOf _x) == "NR6_HAL_Leader_Module") then {_commanders pushBack _x};
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
    if (_logic getVariable [QGVAR(order), false]) then {
        missionNamespace setVariable [QGVAR(order) + _letter, "DEFEND"];
    };

    missionNamespace setVariable [QGVAR(berserk) + _letter,          _logic getVariable [QGVAR(berserk), false]];
    missionNamespace setVariable [QGVAR(simpleMode) + _letter,       _logic getVariable [QGVAR(simpleMode), false]];
    missionNamespace setVariable [QGVAR(unlimitedCapt) + _letter,    _logic getVariable [QGVAR(unlimitedCapt), false]];
    missionNamespace setVariable [QGVAR(captLimit) + _letter,        _logic getVariable [QGVAR(captLimit), 0]];
    missionNamespace setVariable [QGVAR(garrR) + _letter,            _logic getVariable [QGVAR(garrR), false]];
    missionNamespace setVariable [QGVAR(objHoldTime) + _letter,      _logic getVariable [QGVAR(objHoldTime), 0]];
    missionNamespace setVariable [QGVAR(objRadius1) + _letter,       _logic getVariable [QGVAR(objRadius1), 0]];
    missionNamespace setVariable [QGVAR(objRadius2) + _letter,       _logic getVariable [QGVAR(objRadius2), 0]];
    missionNamespace setVariable [QGVAR(lRelocating) + _letter,      _logic getVariable [QGVAR(lRelocating), false]];
    missionNamespace setVariable [QGVAR(noRec) + _letter,            _logic getVariable [QGVAR(noRec), false]];
    missionNamespace setVariable [QGVAR(rapidCapt) + _letter,        _logic getVariable [QGVAR(rapidCapt), false]];
    missionNamespace setVariable [QGVAR(defendObjectives) + _letter, _logic getVariable [QGVAR(defendObjectives), false]];
    missionNamespace setVariable [QGVAR(reconReserve) + _letter,     _logic getVariable [QGVAR(reconReserve), 0]];
    missionNamespace setVariable [QGVAR(attackReserve) + _letter,    _logic getVariable [QGVAR(attackReserve), 0]];
    missionNamespace setVariable [QGVAR(aAO) + _letter,              _logic getVariable [QGVAR(aAO), false]];
    missionNamespace setVariable [QGVAR(forceAAO) + _letter,         _logic getVariable [QGVAR(forceAAO), false]];
    missionNamespace setVariable [QGVAR(bBAOObj) + _letter,          _logic getVariable [QGVAR(bBAOObj), false]];
    missionNamespace setVariable [QGVAR(maxSimpleObjs) + _letter,    _logic getVariable [QGVAR(maxSimpleObjs), 0]];
    missionNamespace setVariable [QGVAR(cRDefRes) + _letter,         _logic getVariable [QGVAR(cRDefRes), 0]];

} forEach _commanders;
