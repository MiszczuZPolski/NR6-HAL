#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:44-215 (RYD_StatusQuo, block S2)

/**
 * @description allGroups scan to populate enemies/friends/subOrd arrays;
 *              subordination-sync logic; radio channel management; known-enemy
 *              tracking for AI chatter. Returns updated state arrays.
 * @param {Group} _HQ The HQ group
 * @param {Array} _civF Array of civilian faction names
 * @param {Array} _excl Previously excluded groups
 * @return {Array} [_enemies, _friends, _excl, _knownE, _knownEG, _KnEnPos,
 *                  _cInitial, _CCurrent, _CLast, _checkFriends]
 */
params ["_HQ", "_civF", "_excl"];

private _SidePLY = [];
private _IgnoredPLY = [];
private _RydMarks = [];
private _MarkGrps = [];
private _checkFriends = [];

private _enemies = _HQ getVariable ["RydHQ_Enemies",[]];
private _friends = _HQ getVariable ["RydHQ_Friends",[]];

if (RydxHQ_AIChatDensity > 0) then
    {
    private _varName1 = "HAC_AIChatRep";
    private _varName2 = "_West";

    switch ((side _HQ)) do
        {
        case (east) : {_varName2 = "_East"};
        case (resistance) : {_varName2 = "_Guer"};
        };

    missionNamespace setVariable [_varName1 + _varName2,0];

    _varName1 = "HAC_AIChatLT";

    missionNamespace setVariable [_varName1 + _varName2,[0,""]]
    };

_HQ setVariable ["RydHQ_LastSub",_HQ getVariable ["RydHQ_Subordinated",[]]];
_HQ setVariable ["RydHQ_Subordinated",[]];

_enemies = _HQ getVariable ["RydHQ_Enemies",[]];
_friends = _HQ getVariable ["RydHQ_Friends",[]];

    {
    private _isCaptive = _x getVariable ("isCaptive" + (str _x));
    if (isNil "_isCaptive") then {_isCaptive = false};

    if not (_isCaptive) then
        {
        _isCaptive = captive (leader _x)
        };

    private _isCiv = false;
    if ((faction (leader _x)) in _civF) then
        {
        _isCiv = true
        }
    else
        {
        if ((side _x) in [civilian]) then
            {
            _isCiv = true
            }
        };

    if not ((isNull ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {not (isNull _x) and {(alive ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {(alive (leader _x)) and {not (_isCaptive)}}}}) then
        {
        if (not ((_HQ getVariable ["RydHQ_FrontA",false])) and {((side _x) getFriend (side _HQ) < 0.6) and {not (_isCiv)}}) then
            {
            if not (_x in _enemies) then
                {
                _enemies pushBack _x
                }
            };

        private _front = true;
        private _fr = _HQ getVariable ["RydHQ_Front",locationNull];
        if not (isNull _fr) then
            {
            _front = ((getPosATL (vehicle (leader _x))) in _fr)
            };

        if ((_HQ getVariable ["RydHQ_FrontA",false]) and {((side _x) getFriend (side _HQ) < 0.6) and {(_front) and {not (_isCiv)}}}) then
            {
            if not (_x in _enemies) then
                {
                _enemies pushBack _x;
                }
            };

        if ((_HQ getVariable ["RydHQ_SubAll",true])) then
            {
            if not ((side _x) getFriend (side _HQ) < 0.6) then
                {
                if (not (_x in _friends) and {not (((leader _x) in (_HQ getVariable ["RydHQ_Excluded",[]])) or {(_isCiv)})}) then
                    {
                    _friends pushBack _x
                    }
                };
            };
        }
    }
forEach allGroups;

_HQ setVariable ["RydHQ_Enemies",_enemies];

_excl = [];
    {
    _excl pushBack _x
    }
    forEach (_HQ getVariable ["RydHQ_Excluded",[]]);

_HQ setVariable ["RydHQ_Excl",_excl];

private _subOrd = [];

if (_HQ getVariable ["RydHQ_SubSynchro",false]) then
    {
        {
        if ((_x in (_HQ getVariable ["RydHQ_LastSub",[]])) and {not ((leader _x) in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {(_HQ getVariable ["RydHQ_SubSynchro",false])}}) then
            {
            _subOrd pushBack _x
            };

        if (not (_x in _subOrd) and {(({(_x in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)])))} count (units _x)) > 0)}) then
            {
            _subOrd pushBack _x
            };
        }
    forEach allGroups;
    };

if (_HQ getVariable ["RydHQ_SubNamed",false]) then
    {
    private _signum = _HQ getVariable ["RydHQ_CodeSign","X"];
    if (_signum in ["A","X"]) then {_signum = ""};

        {
        for [{_i = 1},{_i <= (_HQ getVariable ["RydHQ_NameLimit",100])},{_i = _i + 1}] do
            {
            if (not (_x in _subOrd) and {((str (leader _x)) == ("Ryd" + _signum + str (_i)))}) then
                {
                _subOrd pushBack _x
                };
            };
        }
    forEach allGroups;
    };

_HQ setVariable ["RydHQ_Subordinated",_subOrd];

_friends = _friends + _subOrd + (_HQ getVariable ["RydHQ_Included",[]]) - ((_HQ getVariable ["RydHQ_Excluded",[]]) + _excl + [_HQ]);
_HQ setVariable ["RydHQ_NoWayD",allGroups - (_HQ getVariable ["RydHQ_LastFriends",[]])];

private _channel = _HQ getVariable ["RydHQ_myChannel",-1];

if not (_channel < 0) then
    {
    _channel radioChannelRemove ((allUnits - (units _HQ)) + allDeadMen);
    private _toAdd = [];

        {
            {
            if (isPlayer _x) then
                {
                _toAdd pushBack _x
                }
            }
        forEach (units _x)
        }
    forEach _friends;

    _channel radioChannelAdd _toAdd
    };

_checkFriends = _friends;

{
    if ((({alive _x} count (units _x)) == 0) or (_x == grpNull)) then {_friends = _friends - [_x]};
} forEach _checkFriends;

_friends = [_friends] call EFUNC(common,randomOrd);

_HQ setVariable ["RydHQ_Friends",_friends];

    {
    [_x] call CBA_fnc_clearWaypoints;
    }
forEach (((_HQ getVariable ["RydHQ_Excluded",[]]) + _excl) - (_HQ getVariable ["RydHQ_NoWayD",[]]));

private _cInitial = 0;

if (_HQ getVariable ["RydHQ_Init",true]) then
    {
        {
        _cInitial = _cInitial + (count (units _x));
        if (RydHQ_CamV) then
            {

                {
                if (_x in ([player] + (switchableUnits - [player]))) then {[_x,_HQ] call EFUNC(common,liveFeed)}
                }
            forEach (units _x)
            }
        }
    forEach (_friends + [_HQ])
    };

_HQ setVariable ["RydHQ_CInitial",_cInitial];

_HQ setVariable ["RydHQ_CLast",(_HQ getVariable ["RydHQ_CCurrent",0])];
private _CLast = (_HQ getVariable ["RydHQ_CCurrent",0]);
private _CCurrent = 0;

    {
    _CCurrent = _CCurrent + (count (units _x))
    }
forEach (_friends + [_HQ]);

_HQ setVariable ["RydHQ_CCurrent",_CCurrent];

private _Ex = [];

if (_HQ getVariable ["RydHQ_ExInfo",false]) then
    {
    _Ex = _excl + (_HQ getVariable ["RydHQ_Excluded",[]])
    };

private _knownE = [];
private _knownEG = [];

    {
    for [{_a = 0},{_a < count (units _x)},{_a = _a + 1}] do
        {
        private _enemyU = vehicle ((units _x) select _a);

            {
            if (((_x knowsAbout _enemyU) >= 0.05) and not (_x getVariable ["Ryd_NoReports",false])) exitWith
                {
                if not (_enemyU in _knownE) then
                    {
                    _knownE pushBack _enemyU;
                    (vehicle _enemyU) setVariable ["RydHQ_MyFO",(leader _x)];
                    };

                if not ((group _enemyU) in _knownEG) then
                    {
                    private _already = missionNamespace getVariable ["AlreadySpotted",[]];
                    _knownEG pushBack (group _enemyU);
                    if not ((group _enemyU) in _already) then
                        {
                        private _UL = (leader _x);if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_EnemySpot,"EnemySpot"] call EFUNC(common,AIChatter)}};
                        }
                    }
                }
            }
        forEach (_friends + [_HQ] + _Ex)
        }
    }
forEach _enemies;

private _alwaysKn = ((_HQ getVariable ["RydHQ_AlwaysKnownU",[]]) - (_HQ getVariable ["RydHQ_AlwaysUnKnownU",[]])) - _knownE;

_knownE = (_knownE + _alwaysKn) - (_HQ getVariable ["RydHQ_AlwaysUnKnownU",[]]);

    {
    private _gp = group _x;
    if not (_gp in _knownEG) then {_knownEG pushBack _gp};
    }
forEach _alwaysKn;

_HQ setVariable ["RydHQ_KnEnemies",_knownE];
_HQ setVariable ["RydHQ_KnEnemiesG",_knownEG];
_HQ setVariable ["RydHQ_Ex",_Ex];

[_HQ] spawn EFUNC(hal_boss,EBFT);

private _already = missionNamespace getVariable ["AlreadySpotted",[]];

    {
    if not (_x in _already) then
        {
        _already pushBack _x
        }
    }
forEach _knownEG;

missionNamespace setVariable ["AlreadySpotted",_already];

private _KnEnPos = _HQ getVariable ["RydHQ_KnEnPos",[]];

    {
    _KnEnPos pushBack (getPosATL (vehicle (leader _x)));
    if ((count _KnEnPos) >= 100) then {_KnEnPos = _KnEnPos - [_KnEnPos select 0]};
    }
forEach _knownEG;

_HQ setVariable ["RydHQ_KnEnPos",_KnEnPos];

[_enemies, _friends, _excl, _knownE, _knownEG, _KnEnPos, _cInitial, _CCurrent, _CLast, _checkFriends]
