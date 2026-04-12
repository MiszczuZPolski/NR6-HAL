#include "..\script_component.hpp"

private ["_txtArr","_dbgMon","_txt"];

if (EGVAR(missionmodules,active)) then {
    waitUntil {
        sleep 1;
        !(isNil QEGVAR(missionmodules,mapReady))
    };
};

_txtArr = [];

while {((GVAR(debug)) or (GVAR(debugB)) or (GVAR(debugC)) or (GVAR(debugD)) or (GVAR(debugE)) or (GVAR(debugF)) or (GVAR(debugG)) or (GVAR(debugH)))} do {
    if (({(_x getVariable [QGVAR(kIA),false])} count EGVAR(core,allHQ)) == (count EGVAR(core,allHQ))) exitWith {};
    _txtArr = [];

    {
        if not (isNil "_x") then {
            if not (isNull _x) then {
                if not (_x getVariable [QGVAR(kIA),false]) then {
                    _dbgMon = _x getVariable "DbgMon";
                    if not (isNil "_dbgMon") then {
                        _txtArr pushBack _dbgMon;
                        _txtArr pushBack lineBreak;
                    };
                };
            };
        };
    } forEach EGVAR(core,allHQ);

    if (_txtArr isNotEqualTo []) then {
        _txt = composeText _txtArr;

        hintSilent _txt
    };

    sleep 15;
};
