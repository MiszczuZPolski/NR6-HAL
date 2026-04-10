#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:696 (RYD_ExecuteObj)
/**
 * @description Executes a single objective assignment for a Boss HQ group, managing flanking and garrison logic
 * @param {Array} _sortedA Sorted array of strategic areas
 * @param {Group} _HQ The HQ commander group
 * @param {String} _side Side identifier ("A" or "B")
 * @param {Number} _BBAOObj Objective index (1-4)
 * @param {Boolean} _AAO All-around-objective flag
 * @param {Array} _allied Allied HQ groups
 * @param {Location} _front Front location object
 * @param {Array} _frPos Front location position
 * @param {Number} _frDir Front location direction
 * @param {Array} _frDim Front location size
 * @param {Array} _reserve Reserve HQ groups
 * @param {Array} _HandledArray Already-handled area checksum array
 * @param {String} _varName Mission namespace variable name for handled areas
 * @param {Object} _o1 Objective marker 1
 * @param {Object} _o2 Objective marker 2
 * @param {Object} _o3 Objective marker 3
 * @param {Object} _o4 Objective marker 4
 * @return {Nothing}
 */
_SCRname = "ExecuteObj";

private ["_HQ","_areas","_o1","_o2","_o3","_o4","_allied","_HQpos","_sortedA","_i","_nObj","_actO","_nObj","_KnEn","_KnEnAct","_VLpos","_enX","_enY","_ct","_VHQpos","_front","_afront",
        "_frPos","_frDir","_frDim","_chosenPos","_maxTempt","_actTempt","_sectors","_ownKnEn","_ownForce","_ctOwn","_alliedForce","_alliedGarrisons","_alliedExhausted","_inFlank","_Garrisons","_exhausted",
        "_prop","_enPos","_dst","_val","_profile","_j","_pCnt","_m","_checkPos","_actPos","_indx","_check","_reserve","_garrPool","_fG","_garrison","_chosen","_dstMin","_actG","_actDst","_side",
        "_AllV","_Civs","_AllV2","_Civs2","_AllV0","_AllV20","_NearAllies","_NearEnemies","_actOPos","_mChange","_marksT","_firstP","_actP","_angleM","_centerPoint","_mr1","_mr2","_lM","_wp",
        "_varName","_HandledArray","_cSum","_reck","_cons","_limit","_lColor","_alive","_AAO","_AAOPts","_BBAOObj","_Unable","_UnableArr","_noGarrAround","_SideAllies","_SideEnemies"];

_sortedA = _this select 0;
_HQ = _this select 1;
_side = _this select 2;
_BBAOObj = _this select 3;
_AAO = _this select 4;
_allied = _this select 5;
_front = _this select 6;
_frPos = _this select 7;
_frDir = _this select 8;
_frDim = _this select 9;
_reserve = _this select 10;
_HandledArray = _this select 11;
_varName = _this select 12;
_o1 = _this select 13;
_o2 = _this select 14;
_o3 = _this select 15;
_o4 = _this select 16;


_actO = _sortedA select (_BBAOObj - 1);

//[_actO,_HQ,_side,_BBAOObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName]

if (_BBAOObj == 1) then {_HQ setVariable ["BBObj1Done",false]};
if (_BBAOObj == 2) then {_HQ setVariable ["BBObj2Done",false]};
if (_BBAOObj == 3) then {_HQ setVariable ["BBObj3Done",false]};
if (_BBAOObj == 4) then {_HQ setVariable ["BBObj4Done",false]};


_cSum = 0;

{
    _cSum = _cSum + _x
} forEach (_actO select 0);

_actOPos = [(_actO select 0) select 0,(_actO select 0) select 1,0];
_lColor = "ColorBlue";
if (_Side == "B") then {_lColor = "ColorRed"};

if ((RydBB_Debug) or ((RydBBa_SimpleDebug) and (_Side == "A")) or ((RydBBb_SimpleDebug) and (_Side == "B"))) then
    {
    if (_i == 0) then {_m = [(_actO select 0),_HQ,"markBBCurrent",_lColor,"ICON","mil_triangle","Current target for " + (str (leader _HQ)),"",[0.5,0.5]] call EFUNC(common,mark)} else {_m setMarkerPos (_actO select 0)};
    };

if (_BBAOObj == 1) then {_HQ setVariable ["RydHQ_EyeOfBattle",_actOPos]};

if (_BBAOObj == 1) then
    {
    {
        _x setPosATL _actOPos;
        if !(_AAO) then
            {
            _x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]];
            }
    } forEach [_o1];
    };

if (_BBAOObj == 2) then
    {
    {
        _x setPosATL _actOPos;
        if !(_AAO) then
            {
            _x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]];
            }
    } forEach [_o2];
    };

if (_BBAOObj == 3) then
    {
    {
        _x setPosATL _actOPos;
        if !(_AAO) then
            {
            _x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]];
            }
    } forEach [_o3];
    };

if (_BBAOObj == 4) then
    {
    {
        _x setPosATL _actOPos;
        if !(_AAO) then
            {
            _x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]];
            }
    } forEach [_o4];
    };

//if (_AAOPts) then {_HQ setVariable ["RydHQ_Objectives",_AAOPts]};

_alive = true;

waitUntil
    {
    sleep 15;//120

    _alive = true;

    switch (true) do
        {
        case (isNil "_HQ") : {_alive = false};
        case (isNull _HQ) : {_alive = false};
        case (({alive _x} count (units _HQ) < 1)) : {_alive = false};
        case !(RydBB_Active) : {_alive = false};
        };

    if (_alive) then
        {
        _KnEn = [];

        _inFlank = _HQ getVariable "inFlank";
        if (isNil "_inFlank") then {_inFlank = false};

        if !(_inFlank) then
            {
            _ownKnEn = _HQ getVariable ["RydHQ_KnEnemiesG",[]];

            _ownForce = _HQ getVariable ["RydHQ_Friends",[]];
            _Garrisons = _HQ getVariable ["RydHQ_Garrison",[]];
            _exhausted = _HQ getVariable ["RydHQ_Exhausted",[]];

            _ownForce = _ownForce - (_Garrisons + _exhausted);
            _alliedForce = 0;

            _ctOwn = 0;

            {
                if ((position (vehicle (leader _x))) in _front) then {_ctOwn = _ctOwn + 1}
            } forEach _ownKnEn;

            _prop = 100;

            if (_ctOwn > 0) then {_prop = (count _ownForce)/_ctOwn};

            if (_prop > (8 * (0.5 + (random 1)))) then
                {
                {

                    _KnEnAct = _x getVariable ["RydHQ_KnEnemiesG",[]];
                    _afront = _x getVariable ["RydHQ_Front",locationNull];

                    _alliedForce = _x getVariable ["RydHQ_Friends",[]];
                    _alliedGarrisons = _x getVariable ["RydHQ_Garrison",[]];
                    _alliedExhausted = _x getVariable ["RydHQ_Exhausted",[]];

                    _alliedForce =  _alliedForce - (_alliedGarrisons + _alliedExhausted);

                    if ((count _KnEnAct) > 0) then
                        {
                        _ct = 0;

                        {
                            _enX = 0;
                            _enY = 0;

                            _VLpos = getPosATL (vehicle (leader _x));
                            if (_VLpos in _afront) then
                                {
                                _ct = _ct + 1;
                                _enX = _enX + (_VLpos select 0);
                                _enY = _enY + (_VLpos select 1);
                                }
                        } forEach _KnEnAct;

                        if (_ct > 0) then
                            {
                            _enX = _enX/_ct;
                            _enY = _enY/_ct;
                            };

                        _KnEn pushBack [[_enX,_enY,0],_ct];
                        };

                } forEach _allied;

                if ((count _KnEn) > 0) then
                    {
                    _chosenPos = [];
                    _maxTempt = 0;

                    {
                        _VHQpos = getPosATL (vehicle (leader _HQ));
                        _enPos = _x select 0;
                        _dst = _VHQpos distance _enPos;
                        _val = _x select 1;
                        _actTempt = 0;

                        if ((_dst > 0) and ((count _ownForce) > (_val * (0.1 + (random 1)))) and (_val > ((count _alliedForce) * (0.5 + (random 0.5))))) then {_actTempt = (1000 * (sqrt _val))/_dst};

                        if (_actTempt > _maxTempt) then
                            {
                            _maxTempt = _actTempt;
                            _chosenPos = _enPos;
                            }
                    } forEach _KnEn;

                    if ((count _chosenPos) > 1) then {_chosenPos = [(_chosenPos select 0),(_chosenPos select 1),0]};

                    if (_maxTempt > (0.1 + (random 2))) then
                        {
                        _HQ setVariable ["inFlank",true];
                        //[_front,_VHQpos,_chosenPos,2000] call FUNC(locLineTransform);

                        if (_BBAOObj == 1) then
                            {
                            {
                                _x setPosATL _chosenPos;
                            } forEach [_o1];
                            };

                        if (_BBAOObj == 2) then
                            {
                            {
                                _x setPosATL _chosenPos;
                            } forEach [_o2];
                            };

                        if (_BBAOObj == 3) then
                            {
                            {
                                _x setPosATL _chosenPos;
                            } forEach [_o3];
                            };

                        if (_BBAOObj == 4) then
                            {
                            {
                                _x setPosATL _chosenPos;
                            } forEach [_o4];
                            };


                        _alive = true;

                        waitUntil
                            {
                            sleep 15;//120

                            _alive = true;

                            switch (true) do
                                {
                                case (isNil "_HQ") : {_alive = false};
                                case (isNull _HQ) : {_alive = false};
                                case (({alive _x} count (units _HQ)) < 1) : {_alive = false};
                                case !(RydBB_Active) : {_alive = false};
                                };

                            if (_alive) then
                                {
                                _nObj = _HQ getVariable ["RydHQ_NObj",1];
                                _reck = _HQ getVariable ["RydHQ_Recklessness",0.5];
                                _cons = _HQ getVariable ["RydHQ_Consistency",0.5];

                                _limit = _HQ getVariable ["RydHQ_CaptLimit",10];

                                _SideAllies = [];
                                _SideEnemies = [];

                                {
                                    if (((side _HQ) getFriend _x) >= 0.6) then {_SideAllies pushBack _x} else {_SideEnemies pushBack _x};
                                } forEach [west,east,resistance];

                                if (isNull _HQ) then {_nObj = 100};
                                if (({alive _x} count (units _HQ)) < 1) then {_nObj = 100};

                                _AllV = _chosenPos nearEntities [["AllVehicles"],300];
                                _Civs = _chosenPos nearEntities [["Civilian"],300];
                                _AllV2 = _chosenPos nearEntities [["AllVehicles"],400];
                                _Civs2 = _chosenPos nearEntities [["Civilian"],400];

                                _AllV = _AllV - _Civs;
                                _AllV2 = _AllV2 - _Civs2;

                                _AllV0 = _AllV;
                                _AllV20 = _AllV2;

                                {
                                    if !(_x isKindOf "Man") then
                                        {
                                        if ((count (crew _x)) == 0) then {_AllV = _AllV - [_x]};
                                        if ((count (crew _x)) > 0) then {_AllV = _AllV - [_x] + (crew _x)};
                                        }
                                } forEach _AllV0;

                                {
                                    if !(_x isKindOf "Man") then
                                        {
                                        if ((count (crew _x)) == 0) then {_AllV2 = _AllV2 - [_x]};
                                        if ((count (crew _x)) > 0) then {_AllV2 = _AllV2 - [_x] + (crew _x)};
                                        }
                                } forEach _AllV20;

                                //_NearAllies = (leader _HQ) countfriendly _AllV;
                                _NearAllies = ({(side _x) in _SideAllies} count _AllV);
                                //_NearEnemies = (leader _HQ) countenemy _AllV2;
                                _NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);
                                };

                            (!(_alive) or (_nObj >= 5) or ((_NearAllies >= _limit) and (_NearEnemies <= ((_reck/(0.5 + _cons))*10))))
                            };

                        if !(_alive) exitWith {};

                        if !(isNull _HQ) then
                            {
                            _front setPosition _frPos;
                            _front setDirection _frDir;
                            _front setSize _frDim;

                            if (_BBAOObj == 1) then
                                {
                                {
                                    _x setPosATL _chosenPos;
                                } forEach [_o1];
                                };

                            if (_BBAOObj == 2) then
                                {
                                {
                                    _x setPosATL _chosenPos;
                                } forEach [_o2];
                                };

                                if (_BBAOObj == 3) then
                                {
                                {
                                    _x setPosATL _chosenPos;
                                } forEach [_o3];
                                };

                                if (_BBAOObj == 4) then
                                {
                                {
                                    _x setPosATL _chosenPos;
                                } forEach [_o4];
                                };


                            _HQ setVariable ["inFlank",false]
                            };
                        }
                    }
                }
            }
        };

    ((_actO select 2) or !(_alive))
    };

if !(_alive) exitWith {};

_garrPool = 0;
_UnableArr = [];
_noGarrAround = true;

{
    {
        if (((_actO select 0) distance (leader _x)) < 200) exitWith {_noGarrAround = false};
    } forEach (_x getVariable ["RydHQ_Garrison",[]]);

    _fG = (_x getVariable ["RydHQ_NCrewInfG",[]]) - ((_x getVariable ["RydHQ_Exhausted",[]]) + (_x getVariable ["RydHQ_Garrison",[]]));

    {
        if (((_x getVariable ["Unable",false]) or (isPlayer (leader _x))) or (_x getVariable ["Busy" + (str _x),false])) then {_UnableArr pushBack _x};
    } forEach _fG;

    _fG = _fG - (_UnableArr);

    if ((count _fG) > 2) then {_garrPool = _garrPool + 1}
} forEach _reserve;

{
    if (((_actO select 0) distance (leader _x)) < 200) exitWith {_noGarrAround = false};
} forEach (_HQ getVariable ["RydHQ_Garrison",[]]);

if (_garrPool == 0) then
    {
    _UnableArr = [];

    _garrison = _HQ getVariable ["RydHQ_Garrison",[]];
    _fG = (_HQ getVariable ["RydHQ_NCrewInfG",[]]) - ((_HQ getVariable ["RydHQ_Exhausted",[]]) + (_garrison));

    {
        if (_x getVariable ["Unable",false]) then {_UnableArr pushBack _x};
    } forEach _fG;

    _fG = _fG - (_UnableArr);

    if ((((count _fG)/5) >= 1) and (_noGarrAround)) then
        {
        _chosen = _fG select 0;

        _dstMin = (_actO select 0) distance (vehicle (leader _chosen));

        {
            _actG = _x;
            _actDst = (_actO select 0) distance (vehicle (leader _actG));

            if (_actDst < _dstMin) then
                {
                _dstMin = _actDst;
                _chosen = _actG
                }
        } forEach _fG;

        _code =
            {
            _unitG = _this select 0;
            _HQ = _this select 1;

            _busy = _unitG getVariable [("Busy" + (str _unitG)),false];

            _alive = true;

            if (_busy) then
                {
                _unitG setVariable ["RydHQ_MIA",true];
                _ct = time;

                waitUntil
                    {
                    sleep 0.1;

                    switch (true) do
                        {
                        case (isNull (_unitG)) : {_alive = false};
                        case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
                        case ((time - _ct) > 60) : {_alive = false};
                        case !(RydBB_Active) : {_alive = false};
                        };

                    _MIApass = false;
                    if (_alive) then
                        {
                        _MIAPass = !(_unitG getVariable ["RydHQ_MIA",false]);
                        };

                    (!(_alive) or (_MIApass))
                    }
                };

            _unitG setVariable ["Busy" + (str _unitG),true];
            _garrison = _HQ getVariable ["RydHQ_Garrison",[]];
            _garrison pushBack _unitG;
            _HQ setVariable ["RydHQ_Garrison",_garrison];
            };

        [[_chosen,_HQ],_code] call EFUNC(common,spawn)
        }
    };

_BBProg = _HQ getVariable ["BBProgress",0];
_HQ setVariable ["BBProgress",_BBProg + 1];

_HandledArray = _HandledArray - [_cSum];
missionNamespace setVariable [_varName,_HandledArray];

if !(RydBB_Active) exitWith {};

if (RydBB_LRelocating) then
    {
    [_HQ] call CBA_fnc_clearWaypoints;
    _wp = [_HQ,_actOPos,"HOLD","AWARE","GREEN","LIMITED",["true",""],true,50,[0,0,0],"FILE"] call EFUNC(common,WPadd)
    };
if (_BBAOObj == 1) then {_HQ setVariable ["BBObj1Done",true]};
if (_BBAOObj == 2) then {_HQ setVariable ["BBObj2Done",true]};
if (_BBAOObj == 3) then {_HQ setVariable ["BBObj3Done",true]};
if (_BBAOObj == 4) then {_HQ setVariable ["BBObj4Done",true]};
