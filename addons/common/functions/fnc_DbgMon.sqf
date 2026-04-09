#include "..\script_component.hpp"

if (RydBB_Active) then {
    waitUntil {
        sleep 1;
        !(isNil "RydBB_mapReady")
    };
};

private _txtArr = [];
private _txt = "";
private _dbgMon = "";

while {((RydHQ_Debug) or (RydHQB_Debug) or (RydHQC_Debug) or (RydHQD_Debug) or (RydHQE_Debug) or (RydHQF_Debug) or (RydHQG_Debug) or (RydHQH_Debug))} do {
    if (({(_x getVariable ["RydHQ_KIA",false])} count EGVAR(core,allHQ)) == (count EGVAR(core,allHQ))) exitWith {};
    _txtArr = [];

    {
        if not (isNil "_x") then {
            if not (isNull _x) then {
                if not (_x getVariable ["RydHQ_KIA",false]) then {
                    _dbgMon = _x getVariable "DbgMon";
                    if not (isNil "_dbgMon") then {
                        _txtArr pushBack _dbgMon;
                        _txtArr pushBack lineBreak;
                    };
                };
            };
        };
    } forEach GVAR(allHQ);

    if (_txtArr isNotEqualTo []) then {
        _txt = composeText _txtArr;

        hintSilent _txt
    };

    sleep 15;
};
