#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1201 (RYD_ExecutePath)
/**
 * @description Executes the full strategic advance path for a Boss HQ, spawning objective executors in sequence
 * @param {Group} _HQ The HQ commander group
 * @param {Array} _areas Strategic target areas
 * @param {Object} _o1 Objective marker 1
 * @param {Object} _o2 Objective marker 2
 * @param {Object} _o3 Objective marker 3
 * @param {Object} _o4 Objective marker 4
 * @param {Array} _allied Allied HQ groups (including this HQ, filtered internally)
 * @param {Array} _HQpos HQ initial position
 * @param {Location} _front Front location object
 * @param {Array} _sectors All sector location objects
 * @param {Array} _reserve Reserve HQ groups
 * @param {String} _side Side identifier ("A" or "B")
 * @param {Array} _AAOPts All-around-objective points
 * @return {Nothing}
 */
params ["_HQ", "_areas", "_o1", "_o2", "_o3", "_o4", "_allied", "_HQpos", "_front", "_sectors", "_reserve", "_side", "_AAOPts"];

_allied = _allied - [_HQ];//leader groups

private _AAO = _HQ getVariable [QGVAR(chosenAAO),false];
private _BBAOObj = _HQ getVariable [QEGVAR(core,bBAOObj),1];

private _varName = "HandledAreas" + _side;

private _HandledArray = missionNamespace getVariable _varName;

private _frPos = position _front;
private _frDir = direction _front;
private _frDim = size _front;

private _profile = _HQ getVariable "ForceProfile";

private _sortedA = [_areas,_HQpos,250000] call FUNC(distOrdB);

_HQ setVariable ["SortedDebug",_sortedA];

private _pCnt = 0;

private _m = "";
private _marksT = [];

if (EGVAR(missionmodules,debug)) then
    {
    {
        _pCnt = _pCnt + 1;
        private _j = [(_x select 0),(random 1000),"markBBPath","ColorBlack","ICON","mil_box",(str _pCnt),"",[0.35,0.35]] call EFUNC(common,mark);
        _marksT pushBack _j
    } forEach _sortedA;

    for "_i" from 0 to ((count _sortedA) - 1) do
        {
        private _firstP = _HQpos;
        if (_i > 0) then {_firstP = (_sortedA select (_i - 1)) select 0};

        _firstP = [_firstP select 0,_firstP select 1,0];

        private _actP = (_sortedA select _i) select 0;
        _actP = [_actP select 0,_actP select 1,0];

        private _angleM = [_firstP,_actP,0] call EFUNC(common,angleTowards);

        private _centerPoint = [((_firstP select 0) + (_actP select 0))/2,((_firstP select 1) + (_actP select 1))/2,0];

        private _mr1 = 1.5;
        private _mr2 = _actP distance _centerPoint;

        private _lM = [_centerPoint,(random 1000),"markBBline","ColorPink","RECTANGLE","Solid","","",[_mr1,_mr2],_angleM] call EFUNC(common,mark);

        _marksT pushBack _lM
        }
    };

_HQ setVariable ["PathDone",false];

if ( !(_BBAOObj <= (count _sortedA))) then {_BBAOObj = (count _sortedA)};

_HQ setVariable ["BBObj1Done",true];
_HQ setVariable ["BBObj2Done",true];
_HQ setVariable ["BBObj3Done",true];
_HQ setVariable ["BBObj4Done",true];

private _AssObj = 0;
if (_BBAOObj >= 1) then {_AssObj = 1; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj >= 2) then {_AssObj = 2; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj >= 3) then {_AssObj = 3; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj == 4) then {_AssObj = 4; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };

sleep 1;

_HQ setVariable ["ObjInit",true];
_HQ setVariable [QEGVAR(common,taken),[]];

waitUntil {

    sleep 15;

    ((_HQ getVariable ["BBObj1Done",false]) and (_HQ getVariable ["BBObj2Done",false]) and (_HQ getVariable ["BBObj3Done",false]) and (_HQ getVariable ["BBObj4Done",false]))
};

if !(EGVAR(missionmodules,active)) exitWith {};

if (EGVAR(missionmodules,debug)) then
    {
    {
        deleteMarker _x
    } forEach (_marksT + [_m])
    };

if !(isNull _HQ) then {_HQ setVariable ["PathDone",true]; _HQ setVariable [QEGVAR(core,nObj),5]};
