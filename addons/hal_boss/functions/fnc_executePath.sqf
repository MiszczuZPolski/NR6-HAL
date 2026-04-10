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
_SCRname = "ExecutePath";

private ["_HQ","_areas","_o1","_o2","_o3","_o4","_allied","_HQpos","_sortedA","_i","_nObj","_actO","_nObj","_KnEn","_KnEnAct","_VLpos","_enX","_enY","_ct","_VHQpos","_front","_afront",
"_frPos","_frDir","_frDim","_chosenPos","_maxTempt","_actTempt","_sectors","_ownKnEn","_ownForce","_ctOwn","_alliedForce","_alliedGarrisons","_alliedExhausted","_inFlank","_Garrisons","_exhausted",
"_prop","_enPos","_dst","_val","_profile","_j","_pCnt","_m","_checkPos","_actPos","_indx","_check","_reserve","_garrPool","_fG","_garrison","_chosen","_dstMin","_actG","_actDst","_side",
"_AllV","_Civs","_AllV2","_Civs2","_AllV0","_AllV20","_NearAllies","_NearEnemies","_actOPos","_mChange","_marksT","_firstP","_actP","_angleM","_centerPoint","_mr1","_mr2","_lM","_wp",
"_varName","_HandledArray","_cSum","_reck","_cons","_limit","_lColor","_alive","_AAO","_AAOPts","_BBAOObj","_AssObj"];

_HQ = _this select 0;//leader group
_areas = _this select 1;
_o1 = _this select 2;
_o2 = _this select 3;
_o3 = _this select 4;
_o4 = _this select 5;
_allied = (_this select 6) - [_HQ];//leader groups

_AAO = _HQ getVariable ["RydHQ_ChosenAAO",false];
_BBAOObj = _HQ getVariable ["RydHQ_BBAOObj",1];


_HQpos = _this select 7;
_front = _this select 8;
_sectors = _this select 9;
_reserve = _this select 10;
_side = _this select 11;
_AAOPts = _this select 12;

_varName = "HandledAreas" + _side;

_HandledArray = missionNamespace getVariable _varName;

_frPos = position _front;
_frDir = direction _front;
_frDim = size _front;

_profile = _HQ getVariable "ForceProfile";

_sortedA = [_areas,_HQpos,250000] call FUNC(distOrdB);

_HQ setVariable ["SortedDebug",_sortedA];

_pCnt = 0;

_m = "";
_marksT = [];

if (RydBB_Debug) then
    {
    {
        _pCnt = _pCnt + 1;
        _j = [(_x select 0),(random 1000),"markBBPath","ColorBlack","ICON","mil_box",(str _pCnt),"",[0.35,0.35]] call EFUNC(common,mark);
        _marksT pushBack _j
    } forEach _sortedA;

    for "_i" from 0 to ((count _sortedA) - 1) do
        {
        _firstP = _HQpos;
        if (_i > 0) then {_firstP = (_sortedA select (_i - 1)) select 0};

        _firstP = [_firstP select 0,_firstP select 1,0];

        _actP = (_sortedA select _i) select 0;
        _actP = [_actP select 0,_actP select 1,0];

        _angleM = [_firstP,_actP,0] call EFUNC(common,angleTowards);

        _centerPoint = [((_firstP select 0) + (_actP select 0))/2,((_firstP select 1) + (_actP select 1))/2,0];

        _mr1 = 1.5;
        _mr2 = _actP distance _centerPoint;

        _lM = [_centerPoint,(random 1000),"markBBline","ColorPink","RECTANGLE","Solid","","",[_mr1,_mr2],_angleM] call EFUNC(common,mark);

        _marksT pushBack _lM
        }
    };

_HQ setVariable ["PathDone",false];

if ( !(_BBAOObj <= (count _sortedA))) then {_BBAOObj = (count _sortedA)};

_HQ setVariable ["BBObj1Done",true];
_HQ setVariable ["BBObj2Done",true];
_HQ setVariable ["BBObj3Done",true];
_HQ setVariable ["BBObj4Done",true];

if (_BBAOObj >= 1) then {_AssObj = 1; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj >= 2) then {_AssObj = 2; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj >= 3) then {_AssObj = 3; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };
if (_BBAOObj == 4) then {_AssObj = 4; [[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],FUNC(executeObj)] call EFUNC(common,spawn); };

sleep 1;

_HQ setVariable ["ObjInit",true];
_HQ setVariable ["RydHQ_Taken",[]];

waitUntil {

    sleep 15;

    ((_HQ getVariable ["BBObj1Done",false]) and (_HQ getVariable ["BBObj2Done",false]) and (_HQ getVariable ["BBObj3Done",false]) and (_HQ getVariable ["BBObj4Done",false]))
};

if !(RydBB_Active) exitWith {};

if (RydBB_Debug) then
    {
    {
        deleteMarker _x
    } forEach (_marksT + [_m])
    };

if !(isNull _HQ) then {_HQ setVariable ["PathDone",true]; _HQ setVariable ["RydHQ_NObj",5]};
