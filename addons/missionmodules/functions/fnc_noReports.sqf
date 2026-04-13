#include "..\script_component.hpp"
private ["_logic","_Commanders","_Leader","_prefix"];

_logic = (_this select 0);


{
    if ((typeOf _x) != QGVAR(Leader_Module)) then {
        (group _x) setVariable ["Ryd_NoReports",true];
    };
} forEach (synchronizedObjects _logic);
