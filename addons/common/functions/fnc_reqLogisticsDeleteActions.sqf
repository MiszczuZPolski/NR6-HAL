#include "..\script_component.hpp"

params ["_chosenOne"];

_chosenOne = _this select 0;

private _actionID = _chosenOne getVariable ["HAL_ReqTraAct", nil];

if !(isNil "_actionID") then {_chosenOne removeAction _actionID};

_chosenOne setVariable ["HAL_ReqTraAct", nil];
