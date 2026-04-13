#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];
private _boxes = [];

{
    if ((typeOf _x) == QGVAR(Leader_Module)) then {_commanders pushBack _x} else {_boxes pushBack _x};
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

    if (_boxes isNotEqualTo []) then {

        missionNamespace setVariable [QGVAR(ammoBoxes) + _letter, _boxes];

        if (_logic getVariable ["VirtualBoxes",false]) then {
            {_x enableSimulationGlobal false; _x hideObjectGlobal true;} forEach _boxes;
        };

        } else {

        private _area = _logic getVariable ["objectArea",[0,0,0,true,0]];
        private _trig = createTrigger ["EmptyDetector",getPos _logic];
        _trig setTriggerArea [_area select 0,_area select 1, _area select 2, _area select 3];
        missionNamespace setVariable [QGVAR(ammoDepot) + _letter, _trig];

        };




} forEach _commanders;
