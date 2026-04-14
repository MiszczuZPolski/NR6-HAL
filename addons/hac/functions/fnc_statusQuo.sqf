#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1-1779 (RYD_StatusQuo — orchestrator trunk)

/**
 * @description HQ commander decision loop — orchestrates all strategic sub-phases per cycle.
 *              Called as a spawned loop from addons/core/functions/fnc_init.sqf via HQSitRep variable.
 *              Decomposes into 10 sub-functions per D-03 (FUNC-08).
 * @param {Group} _HQ The HQ group
 * @param {Number} _cycleC Cycle counter (increments each loop iteration)
 * @param {Number} _lastReset Time of last HQ reset
 * @param {Array} _excl Excluded groups array
 * @param {Array} _civF Civilian faction names array
 * @return {nil}
 */
params ["_HQ", "_cycleC", "_lastReset", "_excl", "_civF"];

// Init loop timer variables
private _HQlPos = getPosATL (vehicle (leader _HQ));

while {true} do {

    // S1: Cycle gate, on-demand reset, state variable reset
    _lastReset = [_HQ, _cycleC, _lastReset] call FUNC(statusQuo_init);

    // S2: allGroups scan + friends/enemies/known-enemy classification + radio channel
    private _scanResult = [_HQ, _civF, _excl] call FUNC(statusQuo_scanFriends);
    _scanResult params ["_enemies", "_friends", "_excl", "_knownE", "_knownEG", "_KnEnPos",
                        "_cInitial", "_CCurrent", "_CLast", "_checkFriends"];

    // S3a: Friendly force classification into typed arrays
    private _fValue = 0;
    private _friendClassResult = [_HQ, _friends, _fValue] call FUNC(statusQuo_classifyFriends);
    _friendClassResult params ["_FValue",
        "_SpecFor", "_recon", "_FO", "_snipers", "_ATinf", "_AAinf", "_Inf", "_Art",
        "_HArmor", "_MArmor", "_LArmor", "_LArmorAT", "_Cars", "_Air", "_BAir", "_RAir", "_NCAir",
        "_Naval", "_Static", "_StaticAA", "_StaticAT", "_Support", "_Cargo", "_NCCargo", "_Other",
        "_Crew", "_NCrewInf",
        "_SpecForG", "_reconG", "_FOG", "_snipersG", "_ATinfG", "_AAinfG", "_InfG", "_ArtG",
        "_HArmorG", "_MArmorG", "_LArmorG", "_LArmorATG", "_CarsG", "_AirG", "_BAirG", "_RAirG",
        "_NCAirG", "_NavalG", "_StaticG", "_StaticAAG", "_StaticATG", "_SupportG", "_CargoG",
        "_NCCargoG", "_OtherG", "_CrewG", "_NCrewInfG"];

    // S4: Publish ArtyFriends/ArtyArt globals for each named HQ (A-H)
    [_HQ, _friends, _Art, _ArtG] call FUNC(statusQuo_artyPublish);

    // S3b: Known-enemy force classification
    private _eValue = 0;
    private _enemyClassResult = [_HQ, _knownEG, _eValue] call FUNC(statusQuo_classifyEnemies);
    _enemyClassResult params ["_EValue", "_EnInf", "_EnInfG", "_EnHArmor", "_EnMArmor", "_EnLArmor",
        "_EnArt", "_EnArtG", "_EnStaticG", "_EnRAirG", "_EnNCrewInf", "_EnNCrewInfG"];

    // S5: Loss tracking and morale delta
    private _morale = [_HQ, _cInitial, _CCurrent, _CLast, _knownE] call FUNC(statusQuo_morale);

    // KIA exit
    if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {EGVAR(core,allHQ) = EGVAR(core,allHQ) - [_HQ]};

    // Arty fire for effect
    private _Artdebug = _HQ getVariable [QEGVAR(common,debug),false];
    if (_HQ getVariable [QEGVAR(core,artyMarks),false]) then {_Artdebug = true};
    if (((count _knownE) > 0) and {((count _ArtG) > 0) and {((_HQ getVariable [QEGVAR(core,artyShells),1]) > 0)}}) then {[_ArtG,_knownE,(_EnHArmor + _EnMArmor + _EnLArmor),_friends,_Artdebug,(_HQ getVariable ["leaderHQ",(leader _HQ)])] call EFUNC(common,cff)};

    // S6: Panic/flee, doctrine roll, arty prep
    private _doctrineResult = [_HQ, _friends, _knownE, _knownEG, _SpecForG, _ArtG, _morale, _cycleC, _CCurrent] call FUNC(statusQuo_doctrine);
    _doctrineResult params ["_AAO", "_EBT"];

    // Compute delay
    private _delay = ((count _friends) * 5) + (round (((10 + (count _friends))/(0.5 + (_HQ getVariable [QEGVAR(core,reflex),0.5]))) * (_HQ getVariable [QEGVAR(core,commDelay),1])));
    _HQ setVariable [QGVAR(myDelay),_delay];

    // S7: SimpleMode objective tracking + respawn points
    private _objResult = [_HQ] call FUNC(statusQuo_objective);
    private _objs = _objResult select 0;

    // S8: Attack/defend dispatch + SF attack
    [_HQ, _objs, _SpecForG, _knownEG, _EnHArmor, _EnMArmor, _EnLArmor, _EnArtG, _EnStaticG,
     _FValue, _EValue, _morale, _AAO, _cycleC, _delay] call FUNC(statusQuo_attackDispatch);

    // S9: HQ self-relocation
    [_HQ, _knownEG, _AAO, _cycleC] call FUNC(statusQuo_hqReloc);

    // Per-cycle wait loop with timer-based sub-dispatches
    private _alive = true;
    private _ct = time;
    private _ctRev = time;
    private _ctMedS = time;
    private _ctFuel = time;
    private _ctAmmo = time;
    private _ctRep = time;
    private _ctISF = time;
    private _ctReloc = time;
    private _ctLPos = time;
    private _ctDesp = time;
    private _ctEScan = time;
    private _ctGarr = time;

    _HQ setVariable [QEGVAR(core,pending),false];

    waitUntil
        {
        sleep 1;

        switch (true) do
            {
            case (isNull _HQ) : {_alive = false};
            case (({alive _x} count (units _HQ)) == 0) : {_alive = false};
            case (_HQ getVariable [QEGVAR(core,surrender),false]) : {_alive = false};
            case (_HQ getVariable [QEGVAR(common,kIA),false]) : {_alive = false};
            };

        if (_alive) then
            {
            if (((time - _ctRev) >= 20) or (((time - _ct) > _delay) and (_delay <= 20))) then
                {
                _ctRev = time;
                [_HQ] call EFUNC(hac,rev);
                };

            if (((count (_HQ getVariable [QGVAR(support),[]])) > 0) and (_cycleC > 2)) then
                {
                if (((time - _ctMedS) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
                    {
                    if (_HQ getVariable [QEGVAR(core,sMed),true]) then
                        {
                        _ctMedS = time;
                        [_HQ] call FUNC(suppMed);
                        }
                    };

                if (((time - _ctFuel) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
                    {
                    if (_HQ getVariable [QEGVAR(core,sFuel),true]) then
                        {
                        _ctFuel = time;
                        [_HQ] call FUNC(suppFuel);
                        }
                    };

                if (((time - _ctRep) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
                    {
                    if (_HQ getVariable [QEGVAR(core,sRep),true]) then
                        {
                        _ctRep = time;
                        [_HQ] call FUNC(suppRep);
                        }
                    };
                };

            if (((count ((_HQ getVariable [QGVAR(support),[]]) + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]))) > 0) and (_cycleC > 2)) then
                {
                if (((time - _ctAmmo) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
                    {
                    if (_HQ getVariable [QEGVAR(core,sAmmo),true]) then
                        {
                        _ctAmmo = time;
                        [_HQ] call FUNC(suppAmmo);
                        }
                    };
                };

            if (((time - _ctISF) >= 30) or (((time - _ct) > _delay) and (_delay <= 30))) then
                {
                _ctISF = time;
                private _nPos = getPosATL (vehicle (leader _HQ));

                if ((_nPos distance _HQlPos) > 10) then
                    {
                    _HQlPos = _nPos;

                    [_HQ] call EFUNC(hac,sfIdleOrd)
                    }
                };

            if (((time - _ctReloc) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
                {
                _ctReloc = time;
                [_HQ] call EFUNC(hac,reloc)
                };

            if (((time - _ctLPos) >= 30) or (((time - _ct) > _delay) and (_delay <= 60))) then
                {
                _ctLPos = time;
                [_HQ] call EFUNC(hac,lPos)
                };

            if (((time - _ctDesp) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
                {
                _ctDesp = time;
                [_HQ] call EFUNC(hac,desperation)
                };

            if (((time - _ctEScan) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
                {
                _ctEScan = time;
                [_HQ] call EFUNC(core,enemyScan)
                };

            if (((time - _ctGarr) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
                {
                _ctGarr = time;
                [_HQ,(_snipers + _ATinf + _AAinf)] spawn FUNC(garrison)
                };
            };

        (((time - _ct) > _delay) or not (_alive))
        };

    if not (_alive) exitWith {EGVAR(core,allHQ) = EGVAR(core,allHQ) - [_HQ]};

    // Post-cycle reveal
        {
        _HQ reveal (vehicle (leader _x))
        }
    forEach _friends;

    for [{_z = 0},{_z < (count _knownE)},{_z = _z + 1}] do
        {
        private _KnEnemy = _knownE select _z;

            {
            if ((_x knowsAbout _KnEnemy) > 0.01) then {_HQ reveal [_KnEnemy,2]}
            }
        forEach _friends
        };

    _cycleC = _cycleC + 1;
};
