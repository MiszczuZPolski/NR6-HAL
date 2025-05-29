#include "..\script_component.hpp"

params ["_logic", "_units", "_activated"];

private _commanders = [];

{
    if ((typeOf _x) == "NR6_HAL_Leader_Module") then {_commanders pushBack _x};
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

    _logic call compile (_prefix + "Front" + " = " + str (_logic getVariable "RydHQ_Front"));

    switch (_leader) do {
        case "LeaderHQ": {_prefix = "A";};
        case "LeaderHQB": {_prefix = "B";};
        case "LeaderHQC": {_prefix = "C";};
        case "LeaderHQD": {_prefix = "D";};
        case "LeaderHQE": {_prefix = "E";};
        case "LeaderHQF": {_prefix = "F";};
        case "LeaderHQG": {_prefix = "G";};
        case "LeaderHQH": {_prefix = "H";};
    };

    private _area = _logic getVariable ["objectArea", [0, 0, 0, true, 0]];

    private _trigger = createTrigger ["EmptyDetector", getPos _logic];
    _trigger setTriggerArea [_area select 0, _area select 1, _area select 2, _area select 3];

    _trigger call compile ("HET_F" + _prefix + " = _this");


} forEach _commanders;
