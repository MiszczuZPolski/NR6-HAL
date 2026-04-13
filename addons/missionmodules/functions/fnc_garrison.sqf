#include "..\script_component.hpp"

params ["_logic", "_units", "_activated"];

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

    [{
        params ["_leaderName"];
        !isNil _leaderName;
    },
    {
        params ["_leaderName", "_letter", "_logic"];

        private _leaderObj = call compile _leaderName;

        private _varName = QGVAR(garrison) + _letter;

        if (isNil {missionNamespace getVariable _varName}) then {
            missionNamespace setVariable [_varName, []];
        };

        {
            if !(_x isKindOf "Logic") then {
                private _existing = missionNamespace getVariable [_varName, []];
                _existing pushBack (group _x);
                missionNamespace setVariable [_varName, _existing];
            } else {
                _x setVariable ["_ExtraArgs", (_logic getVariable ["_ExtraArgs", ""]) + "; " + _varName + " pushback " + "(group _this)"];
            };

        } forEach (synchronizedObjects _logic);
    },
    [_leaderName, _letter, _logic]] call CBA_fnc_waitUntilAndExecute;

} forEach _commanders;
