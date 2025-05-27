#include "..\script_component.hpp"

params ["_unit","_descr","_dstn","_type"];

if (isNil "_type") then {_type = "move"};

private _tasks = (group _unit) getVariable ["HACAddedTasks",[]];
private _task = taskNull;


(group _unit) setVariable ["HACAddedTasks",[]];

{
    [_x] call BIS_fnc_deleteTask;
} forEach _tasks;

sleep 1;

_task = [(group _unit), (str (group _unit)) + "HALTask", _descr, _dstn, "ASSIGNED", 0, true, _type, true] call BIS_fnc_taskCreate;
_tasks = [];

_tasks pushBack _task;

(group _unit) setVariable ["HACAddedTasks", _tasks];

_task
