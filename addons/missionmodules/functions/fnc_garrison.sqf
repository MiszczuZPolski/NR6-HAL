#include "..\script_component.hpp"

params ["_logic", "_units", "_activated"];

private _commanders = [];

{
    if ((typeOf _x) == QGVAR(Leader_Module)) then {_commanders pushBack _x};
} forEach (synchronizedObjects _logic);

{
    private _leader = (_x getVariable "LeaderType");
    private _prefix = "";

    switch (_leader) do {
        case "LeaderHQ": {_prefix = "RydHQ_";};
        case "LeaderHQB": {_prefix = "RydHQB_";};
        case "LeaderHQC": {_prefix = "RydHQC_";};
        case "LeaderHQD": {_prefix = "RydHQD_";};
        case "LeaderHQE": {_prefix = "RydHQE_";};
        case "LeaderHQF": {_prefix = "RydHQF_";};
        case "LeaderHQG": {_prefix = "RydHQG_";};
        case "LeaderHQH": {_prefix = "RydHQH_";};
    };


    [{
        params ["_leader"];
        !isNil _leader;
    },
    {
        params ["_leader", "_prefix"];

        _leader = call compile _leader;

        if (call compile ("isNil " + "'" + _prefix + "Garrison" + "'")) then {

            call compile (_prefix + "Garrison" + " = " + "[]");

        };

        {
            if !(_x isKindOf "Logic") then {
                _x call compile (_prefix + "Garrison" + " pushback " + "(group _this)");
            } else {
                _x setVariable ["_ExtraArgs", (_logic getVariable ["_ExtraArgs", ""]) + "; " + _prefix + "Garrison" + " pushback " + "(group _this)"];
            };

        } forEach (synchronizedObjects _logic);
    },
    [_leader, _prefix]] call CBA_fnc_waitUntilAndExecute;

} forEach _commanders;
