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

params ["_sortedA", "_HQ", "_side", "_BBAOObj", "_AAO", "_allied", "_front", "_frPos", "_frDir", "_frDim", "_reserve", "_HandledArray", "_varName", "_o1", "_o2", "_o3", "_o4"];

private _actO = _sortedA select (_BBAOObj - 1);

//[_actO,_HQ,_side,_BBAOObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName]

if (_BBAOObj == 1) then {_HQ setVariable ["BBObj1Done",false]};
if (_BBAOObj == 2) then {_HQ setVariable ["BBObj2Done",false]};
if (_BBAOObj == 3) then {_HQ setVariable ["BBObj3Done",false]};
if (_BBAOObj == 4) then {_HQ setVariable ["BBObj4Done",false]};


private _cSum = 0;

{
    _cSum = _cSum + _x
} forEach (_actO select 0);

private _actOPos = [(_actO select 0) select 0,(_actO select 0) select 1,0];
private _lColor = "ColorBlue";
if (_Side == "B") then {_lColor = "ColorRed"};

private "_m";
private "_i";
if ((EGVAR(missionmodules,debug)) or ((RydBBa_SimpleDebug) and (_Side == "A")) or ((RydBBb_SimpleDebug) and (_Side == "B"))) then
    {
    if (_i == 0) then {_m = [(_actO select 0),_HQ,"markBBCurrent",_lColor,"ICON","mil_triangle","Current target for " + (str (leader _HQ)),"",[0.5,0.5]] call EFUNC(common,mark)} else {_m setMarkerPos (_actO select 0)};
    };

if (_BBAOObj == 1) then {_HQ setVariable [QEGVAR(core,eyeOfBattle),_actOPos]};

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

private _alive = true;

private _KnEn = [];
private "_inFlank";
private _ownKnEn = [];
private _ownForce = [];
private _Garrisons = [];
private _exhausted = [];
private _alliedForce = 0;
private _ctOwn = 0;
private _prop = 100;
private _KnEnAct = [];
private _afront = locationNull;
private _alliedGarrisons = [];
private _alliedExhausted = [];
private _ct = 0;
private _enX = 0;
private _enY = 0;
private _VLpos = [0,0,0];
private _chosenPos = [];
private _maxTempt = 0;
private _VHQpos = [0,0,0];
private _enPos = [0,0,0];
private _dst = 0;
private _val = 0;
private _actTempt = 0;
private _nObj = 1;
private _reck = 0.5;
private _cons = 0.5;
private _limit = 10;
private _SideAllies = [];
private _SideEnemies = [];
private _AllV = [];
private _Civs = [];
private _AllV2 = [];
private _Civs2 = [];
private _AllV0 = [];
private _AllV20 = [];
private _NearAllies = 0;
private _NearEnemies = 0;

waitUntil
    {
    sleep 15;//120

    _alive = true;

    switch (true) do
        {
        case (isNil "_HQ") : {_alive = false};
        case (isNull _HQ) : {_alive = false};
        case (({alive _x} count (units _HQ) < 1)) : {_alive = false};
        case !(EGVAR(missionmodules,active)) : {_alive = false};
        };

    if (_alive) then
        {
        _KnEn = [];

        _inFlank = _HQ getVariable "inFlank";
        if (isNil "_inFlank") then {_inFlank = false};

        if !(_inFlank) then
            {
            _ownKnEn = _HQ getVariable [QEGVAR(common,knEnemiesG),[]];

            _ownForce = _HQ getVariable [QEGVAR(core,friends),[]];
            _Garrisons = _HQ getVariable [QEGVAR(core,garrison),[]];
            _exhausted = _HQ getVariable [QEGVAR(core,exhausted),[]];

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

                    _KnEnAct = _x getVariable [QEGVAR(common,knEnemiesG),[]];
                    _afront = _x getVariable [QEGVAR(common,front),locationNull];

                    _alliedForce = _x getVariable [QEGVAR(core,friends),[]];
                    _alliedGarrisons = _x getVariable [QEGVAR(core,garrison),[]];
                    _alliedExhausted = _x getVariable [QEGVAR(core,exhausted),[]];

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

                if (_KnEn isNotEqualTo []) then
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
                                case !(EGVAR(missionmodules,active)) : {_alive = false};
                                };

                            if (_alive) then
                                {
                                _nObj = _HQ getVariable [QEGVAR(core,nObj),1];
                                _reck = _HQ getVariable [QEGVAR(core,recklessness),0.5];
                                _cons = _HQ getVariable [QEGVAR(core,consistency),0.5];

                                _limit = _HQ getVariable [QEGVAR(core,captLimit),10];

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
                                        if ((crew _x) isEqualTo []) then {_AllV = _AllV - [_x]};
                                        if ((crew _x) isNotEqualTo []) then {_AllV = _AllV - [_x] + (crew _x)};
                                        }
                                } forEach _AllV0;

                                {
                                    if !(_x isKindOf "Man") then
                                        {
                                        if ((crew _x) isEqualTo []) then {_AllV2 = _AllV2 - [_x]};
                                        if ((crew _x) isNotEqualTo []) then {_AllV2 = _AllV2 - [_x] + (crew _x)};
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

private _garrPool = 0;
private _UnableArr = [];
private _noGarrAround = true;
private _fG = [];
private _garrison = [];
private _chosen = objNull;
private _dstMin = 0;
private _actG = grpNull;
private _actDst = 0;

{
    {
        if (((_actO select 0) distance (leader _x)) < 200) exitWith {_noGarrAround = false};
    } forEach (_x getVariable [QEGVAR(core,garrison),[]]);

    _fG = (_x getVariable [QEGVAR(core,nCrewInfG),[]]) - ((_x getVariable [QEGVAR(core,exhausted),[]]) + (_x getVariable [QEGVAR(core,garrison),[]]));

    {
        if (((_x getVariable ["Unable",false]) or (isPlayer (leader _x))) or (_x getVariable ["Busy" + (str _x),false])) then {_UnableArr pushBack _x};
    } forEach _fG;

    _fG = _fG - (_UnableArr);

    if ((count _fG) > 2) then {_garrPool = _garrPool + 1}
} forEach _reserve;

{
    if (((_actO select 0) distance (leader _x)) < 200) exitWith {_noGarrAround = false};
} forEach (_HQ getVariable [QEGVAR(core,garrison),[]]);

if (_garrPool == 0) then
    {
    _UnableArr = [];

    _garrison = _HQ getVariable [QEGVAR(core,garrison),[]];
    _fG = (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - ((_HQ getVariable [QEGVAR(core,exhausted),[]]) + (_garrison));

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

        private _code =
            {
            params ["_unitG", "_HQ"];

            private _busy = _unitG getVariable [("Busy" + (str _unitG)),false];

            private _alive = true;
            private _ct = 0;
            private "_MIApass";
            private "_MIAPass";

            if (_busy) then
                {
                _unitG setVariable [QEGVAR(common,mIA),true];
                _ct = time;

                waitUntil
                    {
                    sleep 0.1;

                    switch (true) do
                        {
                        case (isNull (_unitG)) : {_alive = false};
                        case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
                        case ((time - _ct) > 60) : {_alive = false};
                        case !(EGVAR(missionmodules,active)) : {_alive = false};
                        };

                    _MIApass = false;
                    if (_alive) then
                        {
                        _MIAPass = !(_unitG getVariable [QEGVAR(common,mIA),false]);
                        };

                    (!(_alive) or (_MIApass))
                    }
                };

            _unitG setVariable ["Busy" + (str _unitG),true];
            private _garrison = _HQ getVariable [QEGVAR(core,garrison),[]];
            _garrison pushBack _unitG;
            _HQ setVariable [QEGVAR(core,garrison),_garrison];
            };

        [[_chosen,_HQ],_code] call EFUNC(common,spawn)
        }
    };

private _BBProg = _HQ getVariable ["BBProgress",0];
_HQ setVariable ["BBProgress",_BBProg + 1];

_HandledArray = _HandledArray - [_cSum];
missionNamespace setVariable [_varName,_HandledArray];

if !(EGVAR(missionmodules,active)) exitWith {};

if (EGVAR(missionmodules,lRelocating)) then
    {
    [_HQ] call CBA_fnc_clearWaypoints;
    private _wp = [_HQ,_actOPos,"HOLD","AWARE","GREEN","LIMITED",["true",""],true,50,[0,0,0],"FILE"] call EFUNC(common,WPadd)
    };
if (_BBAOObj == 1) then {_HQ setVariable ["BBObj1Done",true]};
if (_BBAOObj == 2) then {_HQ setVariable ["BBObj2Done",true]};
if (_BBAOObj == 3) then {_HQ setVariable ["BBObj3Done",true]};
if (_BBAOObj == 4) then {_HQ setVariable ["BBObj4Done",true]};
