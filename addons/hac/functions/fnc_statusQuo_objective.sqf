#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1101-1175 (RYD_StatusQuo, block S7)

/**
 * @description SimpleMode taken-objective tracking and respawn-point management.
 *              Scans HQ objectives/naval objectives for SetTaken flags, builds the
 *              taken list, and optionally manages BIS respawn positions per objective.
 * @param {Group} _HQ The HQ group
 * @return {Array} [_objs] array of remaining untaken objectives
 */
params ["_HQ"];

if (_HQ getVariable [QEGVAR(core,simpleMode),false]) then {

    private _taken = (_HQ getVariable [QEGVAR(common,taken),[]]);
    private _Navaltaken = (_HQ getVariable [QGVAR(takenNaval),[]]);

    {

            if ((_x getVariable ["SetTakenA",false]) and ((str (leader _HQ)) == "LeaderHQ") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenB",false]) and ((str (leader _HQ)) == "LeaderHQB") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenC",false]) and ((str (leader _HQ)) == "LeaderHQC") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenD",false]) and ((str (leader _HQ)) == "LeaderHQD") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenE",false]) and ((str (leader _HQ)) == "LeaderHQE") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenF",false]) and ((str (leader _HQ)) == "LeaderHQF") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenG",false]) and ((str (leader _HQ)) == "LeaderHQG") and not (_x in _taken)) then {_taken pushBack _x;};
            if ((_x getVariable ["SetTakenH",false]) and ((str (leader _HQ)) == "LeaderHQH") and not (_x in _taken)) then {_taken pushBack _x;};

    } forEach (_HQ getVariable [QEGVAR(core,objectives),[]]);

    {

            if ((_x getVariable ["SetTakenA",false]) and ((str (leader _HQ)) == "LeaderHQ") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenB",false]) and ((str (leader _HQ)) == "LeaderHQB") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenC",false]) and ((str (leader _HQ)) == "LeaderHQC") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenD",false]) and ((str (leader _HQ)) == "LeaderHQD") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenE",false]) and ((str (leader _HQ)) == "LeaderHQE") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenF",false]) and ((str (leader _HQ)) == "LeaderHQF") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenG",false]) and ((str (leader _HQ)) == "LeaderHQG") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};
            if ((_x getVariable ["SetTakenH",false]) and ((str (leader _HQ)) == "LeaderHQH") and not (_x in _Navaltaken)) then {_Navaltaken pushBack _x;};

    } forEach (_HQ getVariable [QEGVAR(core,navalObjectives),[]]);

    _HQ setVariable [QEGVAR(common,taken),_taken];
    _HQ setVariable [QGVAR(takenNaval),_Navaltaken];

    if (_HQ getVariable [QGVAR(objectiveRespawn),false]) then {

        private _prefix = "";

        switch (side _HQ) do
        {
            case west: {_prefix = "respawn_west_"};
            case east: {_prefix = "respawn_east_"};
            case resistance: {_prefix = "respawn_guerrila_"};
            case civilian: {_prefix = "respawn_civilian_"};
        };

        {
            private _objStr = (str _x);
            _objStr = (_prefix + (_objStr splitString " " joinString ""));
            if (_x in _taken) then {

                if ((_x getVariable [_objStr,[]]) isEqualTo []) then {
                    private _respPoint = [];
                    if not ((_x getVariable ["ObjName",""]) isEqualTo "") then {_respPoint = [(side _HQ), getPosATL _x,(_x getVariable ["ObjName",""])] call BIS_fnc_addRespawnPosition} else {_respPoint = [(side _HQ), getPosATL _x] call BIS_fnc_addRespawnPosition};
                    _x setVariable [_objStr,_respPoint];
                };

            } else {
                if not ((_x getVariable [_objStr,[]]) isEqualTo []) then {
                    private _respPoint = (_x getVariable [_objStr,[]]);
                    _respPoint call BIS_fnc_removeRespawnPosition;
                    _x setVariable [_objStr,[]];
                };
            }

        } forEach (_HQ getVariable [QEGVAR(core,objectives),[]]);

    };

};

private _objs = (((_HQ getVariable [QEGVAR(core,objectives),[]]) + (_HQ getVariable [QEGVAR(core,navalObjectives),[]])) - ((_HQ getVariable [QEGVAR(common,taken),[]]) + (_HQ getVariable [QGVAR(takenNaval),[]])));

[_objs]
