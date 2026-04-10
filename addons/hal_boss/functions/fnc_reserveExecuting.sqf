#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1320 (RYD_ReserveExecuting)
/**
 * @description Manages reserve forces — garrison assignment and hostile suppression positioning
 * @param {Group} _HQ The HQ commander group
 * @param {Array} _ahead Groups positioned ahead of HQ
 * @param {Object} _o1 Objective marker 1
 * @param {Object} _o2 Objective marker 2
 * @param {Object} _o3 Objective marker 3
 * @param {Object} _o4 Objective marker 4
 * @param {Array} _allied Allied HQ leader units
 * @param {Location} _front Front location object
 * @param {Array} _taken Array of taken area objectives (each: [pos, value, isGarrisoned])
 * @param {Array} _hostileG Known hostile groups
 * @param {String} _side Side identifier ("A" or "B")
 * @return {Nothing}
 */
_SCRname = "ReserveExecuting";

private ["_HQ","_ahead","_frontPos","_o1","_o2","_o3","_o4","_allied","_HQpos","_front","_angle","_dst","_dstF","_dDst","_stancePos","_taken","_fG","_val","_forGarr","_ct","_ct2",
"_garrison","_task","_hMany","_busy","_Wpos","_mark","_wp","_aheadL","_aliveHQ","_hostileG","_assg","_possPos","_enV","_posArr","_enV2","_nr","_sX","_sY","_dstA","_amnt","_actT",
"_maxT","_poss","_m","_side","_rColor"];

_HQ = _this select 0;
_ahead = _this select 1;
_o1 = _this select 2;
_o2 = _this select 3;
_o3 = _this select 4;
_o4 = _this select 5;
_allied = _this select 6;//leader units

_HQpos = getPosATL (vehicle (leader _HQ));
_front = _this select 7;
_taken = _this select 8;
_hostileG = _this select 9;
_side = _this select 10;

_frontPos = _HQpos;
if ((count _ahead) > 0) then
    {
    _aheadL = _ahead select (floor (random (count _ahead)));
    _aliveHQ = true;
    switch (true) do
        {
        case (isNull _HQ) : {_aliveHQ = false};
        case (({alive _x} count (units _HQ)) < 1) : {_aliveHQ = false};
        case !(RydBB_Active) : {_alive = false};
        };

    if (_aliveHQ) then
        {
        _frontPos = getPosATL (vehicle (leader _aheadL))
        }
    };

_dst = _HQpos distance _frontPos;

_dDst = 1000 + (random 1000);

_dstF = _dst - _dDst;
if (_dstF < 0) then {_dstF = _dst/2};

_angle = [_HQpos,_frontPos,10] call EFUNC(common,angleTowards);

if (_angle < 0) then {_angle = _angle + 360};

_angle = _angle + 180;

_stancePos = [_frontPos,_angle,_dstF] call EFUNC(common,positionTowards2D);

_stancePos = [(_stancePos select 0),(_stancePos select 1),0];
if (surfaceIsWater [(_stancePos select 0),(_stancePos select 1)]) then {_stancePos = _HQpos};

_AAO = _HQ getVariable ["RydHQ_ChosenAAO",false];

_garrison = _HQ getVariable ["RydHQ_Garrison",[]];
_fG = (_HQ getVariable ["RydHQ_NCrewInfG",[]]) - ((_HQ getVariable ["RydHQ_Exhausted",[]]) + (_garrison));

_fG = _fG - [_HQ];

{
    if ((count _x) < 5) then {_x set [4,false]};
    if !(_x select 4) then
        {
        _Wpos = _x select 0;
        _val = _x select 1;
        if (_val > 5) then {_val = 5};
        _hMany = floor ((_val/10) * (count _fG));

        //if (_hMany > (ceil (_val/2))) then {_hMany = ceil (_val/2)};
        if (_hMany > 2) then {_hMany = 2};
        //if ((_hMany == 0) and ((random 100) > (90 - (count _fG)))) then {_hMany = 1};

        _ct = 0;

        while {((_ct < _hMany) and ((count _fG) > 0))} do
            {
            _ct = _ct + 1;
            _forGarr = _fG select (floor (random (count _fG)));
            _busy = _forGarr getVariable ("Busy" + (str _forGarr));
            _Unable = _forGarr getVariable ["Unable",false];
            if (isNil "_busy") then {_busy = false};

            _ct2 = 0;

            while {(_busy) and (_ct2 <= (count _fG))} do
                {
                _ct2 = _ct2 + 1;
                _forGarr = _fG select (floor (random (count _fG)));
                _busy = _forGarr getVariable ("Busy" + (str _forGarr));
                if (isNil "_busy") then {_busy = false};
                };

            if (!(_busy) and !(_Unable)) then
                {
                _x set [4,true];
                _fG = _fG - [_forGarr];

                _code =
                    {
                    _SCRname = "ReserveExecutingC1";

                    private ["_unitG","_cause","_timer","_alive","_task","_form","_Wpos","_garrison","_wp"];

                    _unitG = _this select 0;
                    _garrison = _this select 1;
                    _Wpos = _this select 2;

                    _form = "DIAMOND";
                    if (isPlayer (leader _unitG)) then {_form = formation _unitG};
                    _unitG setVariable ["Busy" + (str _unitG),true];

                    if !(isPlayer (leader _unitG)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[(leader _unitG),RydxHQ_AIC_OrdConf,"OrdConf"] call EFUNC(common,AIChatter)}};

                    _task = [(leader _unitG),["Reach the designated position.", "Move", ""],_Wpos] call EFUNC(common,addTask);

                    [_unitG] call CBA_fnc_clearWaypoints;

                    _wp = [_unitG,_Wpos,"MOVE","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0]"],true,250,[0,0,0],_form] call EFUNC(common,WPadd);

                    _cause = [_unitG,6,true,0,30,[],false] call EFUNC(common,wait);
                    _timer = _cause select 0;
                    _alive = _cause select 1;

                    if !(_alive) exitWith {};
                    if (_timer > 30) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 1]};

                    if ((isPlayer (leader _unitG)) and !(isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

                    if !(_timer > 30) then {_garrison pushBack _unitG};
                    };

                [[_forGarr,_garrison,_Wpos],_code] call EFUNC(common,spawn)
                }
            }
        }
} forEach _taken;

_middlePos = [((_HQpos select 0) + (_StancePos select 0))/2,((_HQpos select 1) + (_StancePos select 1))/2,0];
_closeMid = false;

if ((count _hostileG) > 0) then
    {
    _assg = [];
    _possPos = [];

    {
        if !(_x in _assg) then
            {
            _enV = vehicle (leader _x);
            _posArr = [];

            {
                _enV2 = vehicle (leader _x);

                if ((_enV distance _enV2) < 600) then
                    {
                    _posArr pushBack (getPosATL _enV2);
                    _assg pushBack _x;
                    }
            } forEach _hostileG;

            _nr = count _posArr;

            if (_nr > 0) then
                {
                _sX = 0;
                _sY = 0;

                {
                    _sX = _sX + (_x select 0);
                    _sY = _sY + (_x select 1);
                } forEach _posArr;

                _poss = [[_sX/_nr,_sY/_nr,0],_nr];
                if !(surfaceIsWater [_sX/_nr,_sY/_nr]) then {_possPos pushBack _poss}
                };

            if ((_enV distance _middlePos) < 600) then
                {
                _closeMid = true
                };
            };
    } forEach _hostileG;

    _stancePos = (_possPos select 0) select 0;
    _maxT = 0;

    {
        _dstA = (_x select 0) distance _HQpos;
        _amnt = _x select 1;
        _actT = (_amnt/((_dstA/1000) * (_dstA/1000))) * (0.5 + (random 0.5) + (random 0.5));

        if (_actT > _maxT) then
            {
            _maxT = _actT;
            _stancePos = _x select 0;
            }

    } forEach _possPos
    };

{
    _x setPosATL _stancePos;
    if !(_AAO) then
        {
        _x setVariable [("Capturing" + (str _x) + (str _HQ)),[0,0]];
        }
} forEach [_o1,_o2,_o3,_o4];

_HQ setVariable ["RydHQ_NObj",1];
_HQ setVariable ["RydHQ_Taken",[]];
_HQ setVariable ["ObjInit",true];

[_HQ] call CBA_fnc_clearWaypoints;

_HQnewPos = _StancePos;

if ((count _hostileG) > 0) then
    {
    _HQnewPos = _middlePos;

    if (_closeMid) then
        {
        _HQnewPos = _HQpos
        };
    };

_wp = [_HQ,_HQnewPos,"HOLD","AWARE","GREEN","LIMITED",["true",""],true,50,[0,0,0],"FILE"] call EFUNC(common,WPadd);

if (RydBB_Debug) then
    {
    _m = _HQ getVariable "ResMark";
    if (isNil "_m") then
        {
        _rColor = "ColorBlue";
        if (_side == "B") then {_rColor = "ColorRed"};
        _m = [_StancePos,_HQ,"markBBCurrent",_rColor,"ICON","mil_triangle","Reserve area for " + (str (leader _HQ)),"",[0.5,0.5]] call EFUNC(common,mark);
        _HQ setVariable ["ResMark",_m]
        }
    else
        {
        _m setMarkerPos _StancePos
        };
    };
