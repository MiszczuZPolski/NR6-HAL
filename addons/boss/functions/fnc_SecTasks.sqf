#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:3121-3231 (HAL_SecTasks)

/**
 * @description Player secondary tasks loop — manages BIS task objects for all
 *              player groups that are friends of the HQ. Creates/updates/completes
 *              tasks based on HQ objective taken/untaken status.
 * @param {Group} _HQ The HQ group
 * @return {nil}
 */
params ["_HQ"];

private _leader = leader _HQ;
private _side = side _HQ;
private _taskedGroups = [];

while {not (isNull _HQ)} do {

    if ((_HQ getVariable [QEGVAR(core,secTasks),true]) and (_HQ getVariable [QEGVAR(core,simpleMode),true])) then {

        _taskedGroups = [];

        private _friends = _HQ getVariable [QEGVAR(core,friends),[]];

        {
            if ((group _x) in _friends) then {
                _taskedGroups pushBackUnique (group _x);
            }
        } forEach allPlayers;

        {
            private _Group = _x;
            private _TaskedObjectives = (_Group getVariable ["TaskedObjectives",[]]);
            private _DefendObjectives = (_Group getVariable ["DefendObjectives",[]]);

            private _ParentID = _Group getVariable "SecTskParentID";

            if (isNil "_ParentID") then {
                _ParentID = str (_HQ) + str (_Group) + "masterTask";
                [_Group, [_ParentID], ["List of objective control related tasks.", "Objectives", nil] , _x,"CREATED", -10, false, "map"] call BIS_fnc_taskCreate;
                _Group setVariable ["SecTskParentID",_ParentID];
                };

            {
                private _setTaken = false;
                if (_x in (_HQ getVariable [QEGVAR(common,taken),[]])) then {_setTaken = true} else {_setTaken = false};

                private _taskID = (str _Group) + (str _x) + "HALStsk";

                private _ObjName = _x getVariable "ObjName";
                if (isNil "_ObjName") then {

                    private _where = mapGridPosition (getPos _x);
                    _ObjName = "Objective At " + _where;

                    private _nL = nearestLocations [(getPos _x), ["Hill","NameCityCapital","NameCity","NameVillage","NameLocal","Strategic","StrongpointArea"], 500];

                    if (_nL isNotEqualTo []) then {
                        _nL = _nL select 0;
                        _where = (text _nL);
                        _ObjName = _where;
                        };
                    };

                if not (_setTaken) then {

                    [_Group, [_taskID,_ParentID], ["Secure objective.", "Secure " + _ObjName, nil] , _x,"CREATED", -1, false, "move"] call BIS_fnc_taskCreate;
                    _TaskedObjectives pushBack _x;

                    } else {

                    [_Group, [_taskID,_ParentID], ["Defend objective.", "Defend " + _ObjName, nil] , _x,"CREATED", -1, false, "defend"] call BIS_fnc_taskCreate;
                    _TaskedObjectives pushBack _x;
                    _DefendObjectives pushBack _x;

                    };

            } forEach ((_HQ getVariable [QEGVAR(core,objectives),[]]) - _TaskedObjectives);

            {
                private _taskID = (str _Group) + (str _x) + "HALStsk";

                [_taskID] call BIS_fnc_deleteTask;
                _TaskedObjectives = _TaskedObjectives - [_x];
                _DefendObjectives = _DefendObjectives - [_x];

            } forEach (_TaskedObjectives - (_HQ getVariable [QEGVAR(core,objectives),[]]));

            {

                private _taskID = (str _Group) + (str _x) + "HALStsk";

                if (_x in (_HQ getVariable [QEGVAR(common,taken),[]])) then {
                    [_taskID,"SUCCEEDED"] call BIS_fnc_taskSetState;
                    _TaskedObjectives = _TaskedObjectives - [_x];
                    };

            } forEach (_TaskedObjectives - _DefendObjectives);

            {

                private _taskID = (str _Group) + (str _x) + "HALStsk";

                if not (_x in (_HQ getVariable [QEGVAR(common,taken),[]])) then {
                    [_taskID,"FAILED"] call BIS_fnc_taskSetState;
                    _DefendObjectives = _DefendObjectives - [_x];
                    _TaskedObjectives = _TaskedObjectives - [_x];
                    };

            } forEach _DefendObjectives;

            _Group setVariable ["TaskedObjectives",_TaskedObjectives];
            _Group setVariable ["DefendObjectives",_DefendObjectives];

        } forEach _taskedGroups;

        sleep 15;
    };
};
