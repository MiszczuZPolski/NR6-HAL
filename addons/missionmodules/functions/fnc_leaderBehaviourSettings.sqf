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

    missionNamespace setVariable [QGVAR(smoke) + _letter,           _logic getVariable [QGVAR(smoke), false]];
    missionNamespace setVariable [QGVAR(flare) + _letter,           _logic getVariable [QGVAR(flare), false]];
    missionNamespace setVariable [QGVAR(garrVehAb) + _letter,       _logic getVariable [QGVAR(garrVehAb), false]];
    missionNamespace setVariable [QGVAR(idleOrd) + _letter,         _logic getVariable [QGVAR(idleOrd), false]];
    missionNamespace setVariable [QGVAR(flee) + _letter,            _logic getVariable [QGVAR(flee), false]];
    missionNamespace setVariable [QGVAR(surr) + _letter,            _logic getVariable [QGVAR(surr), false]];
    missionNamespace setVariable [QGVAR(muu) + _letter,             _logic getVariable [QGVAR(muu), false]];
    missionNamespace setVariable [QGVAR(rush) + _letter,            _logic getVariable [QGVAR(rush), false]];
    missionNamespace setVariable [QGVAR(withdraw) + _letter,        _logic getVariable [QGVAR(withdraw), false]];
    missionNamespace setVariable [QGVAR(airDist) + _letter,         _logic getVariable [QGVAR(airDist), 0]];
    missionNamespace setVariable [QGVAR(dynForm) + _letter,         _logic getVariable [QGVAR(dynForm), false]];
    missionNamespace setVariable [QGVAR(defRange) + _letter,        _logic getVariable [QGVAR(defRange), 0]];
    missionNamespace setVariable [QGVAR(garrRange) + _letter,       _logic getVariable [QGVAR(garrRange), 0]];
    missionNamespace setVariable [QGVAR(attInfDistance) + _letter,  _logic getVariable [QGVAR(attInfDistance), 0]];
    missionNamespace setVariable [QGVAR(attArmDistance) + _letter,  _logic getVariable [QGVAR(attArmDistance), 0]];
    missionNamespace setVariable [QGVAR(attSnpDistance) + _letter,  _logic getVariable [QGVAR(attSnpDistance), 0]];
    missionNamespace setVariable [QGVAR(captureDistance) + _letter, _logic getVariable [QGVAR(captureDistance), 0]];
    missionNamespace setVariable [QGVAR(flankDistance) + _letter,   _logic getVariable [QGVAR(flankDistance), 0]];
    missionNamespace setVariable [QGVAR(attSFDistance) + _letter,   _logic getVariable [QGVAR(attSFDistance), 0]];
    missionNamespace setVariable [QGVAR(reconDistance) + _letter,   _logic getVariable [QGVAR(reconDistance), 0]];
    missionNamespace setVariable [QGVAR(uAVAlt) + _letter,          _logic getVariable [QGVAR(uAVAlt), 0]];
    missionNamespace setVariable [QGVAR(combining) + _letter,       _logic getVariable [QGVAR(combining), false]];

} forEach _commanders;
