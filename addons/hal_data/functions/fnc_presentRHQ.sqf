#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:2207-2869 (RYD_PresentRHQ)

/**
 * @description Categorizes all mission vehicles and units into RHQ_* arrays
 *              by analyzing weapon types, vehicle classes, and capabilities.
 *              Reads RYD_WS_*_class globals (populated by hal_data_fnc_initWeaponClasses).
 *              Writes results to RHQ_* globals used throughout the AI system.
 * @return {Boolean} true on completion
 */
params [];

private _allVehs = [];
private _allUnits = [];
private _vehClass = configFile >> "CfgVehicles";
private _wpClass = configFile >> "CfgWeapons";
private _magClass = configFile >> "CfgMagazines";
private _ammoClass = configFile >> "CfgAmmo";
private _addedU = [];
private _addedV = [];
private _veh = "";
private _vehClass2 = objNull;
private _weapons = [];
private _hasLaserD = false;
private _type = "";
private _mags = [];
private _isDriver = false;
private _turrets = objNull;
private _mainT = objNull;
private _isArmed = false;
private _isAA = false;
private _isAT = false;
private _isCargo = false;

GVAR(wS_AllClasses) = GVAR(wS_Inf_class) + GVAR(wS_Art_class) + GVAR(wS_HArmor_class) + GVAR(wS_MArmor_class) + GVAR(wS_LArmor_class) + GVAR(wS_Cars_class) + GVAR(wS_Air_class) + GVAR(wS_Naval_class) + GVAR(wS_Static_class) + GVAR(wS_Support_class) + GVAR(wS_Other_class);

    {
    if ((side _x) in [west,east,resistance]) then
        {
        _vh = toLower (typeOf _x);
        if not (_vh in GVAR(wS_AllClasses)) then
            {
            GVAR(wS_AllClasses) pushBackUnique _vh;
            _allVehs pushBack _x
            }
        }
    }
forEach vehicles;

    {
    if ((side _x) in [west,east,resistance]) then
        {
        _vh = toLower (typeOf _x);
        if not (_vh in GVAR(wS_AllClasses)) then
            {
            GVAR(wS_AllClasses) pushBackUnique _vh;
            _allUnits pushBack _x
            }
        }
    }
forEach allUnits;

    {
    _veh = toLower (typeOf _x);
    if not (_veh in _addedU) then
        {
        _addedU pushBack _veh;
        GVAR(inf) pushBackUnique _veh;

        _vehClass2 = _vehClass >> _veh;

        if ((getNumber (_vehClass2 >> "camouflage")) < 1) then
            {
            if ((toLower (getText (_vehClass2 >> "textSingular"))) isEqualTo "sniper") then
                {
                GVAR(snipers) pushBackUnique _veh
                }
            else
                {
                private _weapons = getArray (_vehClass2 >> "weapons");

                GVAR(recon) pushBackUnique _veh;

                _hasLaserD = false;

                    {
                    private _wpClass2 = configFile >> "CfgWeapons" >> _x;
                    _type = getNumber (_wpClass2 >> "type");

                    if (_type == 4096) then
                        {
                        private _cursor = toLower (getText (_wpClass2 >> "cursor"));
                        if (_cursor in ["","emptycursor"]) then
                            {
                            _cursor = toLower (getText (_wpClass2 >> "cursorAim"))
                            };

                        if (_cursor isEqualTo "laserdesignator") exitWith {_hasLaserD = true}
                        };

                    if (_hasLaserD) exitWith {}
                    }
                forEach _weapons;

                if (_hasLaserD) then
                    {
                    GVAR(fO) pushBackUnique _veh
                    }
                };
            };

        private _wps = getArray (_vehClass2 >> "Weapons");

        if ((count _wps) > 1) then
            {
            _isAT = false;
            _isAA = false;

                {
                private _sWeapon = _x;
                private _mgs = configFile >> "CfgWeapons" >> _sWeapon >> "magazines";
                if (isArray _mgs) then
                    {
                    _mgs = getArray _mgs;

                    if ((count _mgs) > 0) then
                        {
                        private _mag = _mgs select 0;
                        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                        private _ammoC = configFile >> "CfgAmmo" >> _ammo;

                        _isAA = ((getNumber (_ammoC >> "airLock")) > 1) or {((getNumber (_ammoC >> "airLock")) > 0) and {((getNumber (_ammoC >> "irLock")) > 0)}};

                        if not (_isAA) then
                            {
                            _isAT = ((((getNumber (_ammoC >> "irLock")) + (getNumber (_ammoC >> "laserLock"))) > 0) and {((getNumber (_ammoC >> "airLock")) < 2)})
                            };

                        if (not (_isAT) and {not (_isAA)}) then
                            {
                                {
                                private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                                private _ammoC = configFile >> "CfgAmmo" >> _ammo;
                                private _actHit = getNumber (_ammoC >> "hit");

                                if (_actHit > 150) exitWith {_isAT = true}
                                }
                            forEach _mgs
                            };

                        if (_isAT) then
                            {
                            GVAR(aTInf) pushBackUnique _veh
                            };

                        if (_isAA) then
                            {
                            GVAR(aAInf) pushBackUnique _veh
                            };
                        }
                    };

                if ((_isAT) or {(_isAA)}) exitWith {}
                }
            forEach _wps
            }
        }
    }
forEach _allUnits;

private _flareMags = ["Laserbatteries","60Rnd_CMFlareMagazine","120Rnd_CMFlareMagazine","240Rnd_CMFlareMagazine","60Rnd_CMFlare_Chaff_Magazine","120Rnd_CMFlare_Chaff_Magazine","240Rnd_CMFlare_Chaff_Magazine","192Rnd_CMFlare_Chaff_Magazine","168Rnd_CMFlare_Chaff_Magazine","300Rnd_CMFlare_Chaff_Magazine"];

    {
    _veh = toLower (typeOf _x);
    private _vehO = _x;
    if not (_veh in _addedV) then
        {
        _addedV pushBack _veh;

        _vehClass2 = _vehClass >> _veh;

        _isDriver = (getNumber (_vehClass2 >> "hasDriver")) > 0;

        _turrets = _vehClass2 >> "Turrets";
        private _cT = count _turrets;
        private _tMags = [];

        if (_cT > 0) then
            {
            for "_i" from 0 to (_cT - 1) do
                {
                private _trt = _turrets select _i;
                if (isClass _trt) then
                    {
                    _trt = configName _trt;
                    private _mgT = _vehClass2 >> "Turrets" >> _trt >> "magazines";
                    if (isArray _mgT) then
                        {
                        _tMags = _tMags + (getArray _mgT)
                        }
                    }
                }
            };

        _mainT = _turrets >> "MainTurret";
        private _isMainT = isClass _mainT;

        private _isAmmoS = (getNumber (_vehClass2 >> "transportAmmo")) > 0;
        private _isFuelS = (getNumber (_vehClass2 >> "transportFuel")) > 0;
        private _isRepS = (getNumber (_vehClass2 >> "transportRepair")) > 0;
        private _isMedS = (getNumber (_vehClass2 >> "attendant")) > 0;
        _mags = getArray (_vehClass2 >> "magazines") + _tMags;
        _isArmed = (count (_mags - _flareMags)) > 0;
        _isCargo = ((getNumber (_vehClass2 >> "transportSoldier")) > 0) and {((getNumber (_vehClass2 >> "transportAmmo")) + (getNumber (_vehClass2 >> "transportFuel")) + (getNumber (_vehClass2 >> "transportRepair")) + (getNumber (_vehClass2 >> "attendant"))) < 1};
        private _isArty = (getNumber (_vehClass2 >> "artilleryScanner")) > 0;

        _type = "inf";

        private _base = _veh;

        switch (true) do {
            case (_veh isKindOf "air"): {_base = "air"};
            case (_veh isKindOf "ship"): {_base = "ship"};
            case (_veh isKindOf "tank"): {_base = "tank"};
            case (_veh isKindOf "car"): {_base = "car"};
            case (_veh isKindOf "wheeled_apc_f"): {_base = "wheeled_apc_f"};
            case (_veh isKindOf "ugv_01_base_f"): {_base = "ugv_01_base_f"};
            default {_base = _veh};
        };

        if not (_base isEqualTo "ugv_01_base_f") then
            {
            if (_base in ["air","ship","tank","car","wheeled_apc_f"]) then
                {
                _type = _base
                };
            };

        if (_isArty) then
            {
            GVAR(art) pushBackUnique _veh;

            if not (missionNamespace getVariable [QGVAR(classRangeDefined) + str (_veh),false]) then {

                private _lPiece = _vehO;
                private _pos = position _lPiece;
                private _minRange = 0;
                private _maxRange = 0;

                private _mainAmmoType = (((magazinesAmmo _lPiece) select 0) select 0);

                private _checkLoop = false;
                private _posCheck = position _lPiece;
                private _checkRange = 0;
                private _timeOut = false;
                private _canFire = false;

                waitUntil {
                    _canFire = false;
                    _timeOut = false;

                    _minRange = (_minRange + 100);
                    _posCheck = [(_pos select 0) + _minRange, (_pos select 1),0];
                    _canFire = _posCheck inRangeOfArtillery [[_lPiece],_mainAmmoType];

                    if (_canFire) then {
                        _checkRange = _minRange;
                        _canFire = false;
                        for "_i" from 100 to 0 step -25 do {
                            _checkRange = (_minRange - 25);
                            _posCheck = [(_pos select 0) + _checkRange, (_pos select 1),0];
                            _canFire = _posCheck inRangeOfArtillery [[_lPiece],_mainAmmoType];
                            if not (_canFire) exitWith {_minRange = _checkRange};
                        };
                    };

                    _checkRange = _minRange;
                    if (_checkRange > 200000) then {_timeOut = true};

                    ((_canFire) or (_timeOut))
                };

                missionNamespace setVariable [QGVAR(classRangeMin) + str (_veh),_minRange];

                _checkLoop = false;
                _posCheck = position _lPiece;
                _checkRange = 0;
                _timeOut = false;
                _canFire = false;
                _maxRange = _minRange;

                waitUntil {
                    _canFire = true;
                    _timeOut = false;

                    _maxRange = (_maxRange + 1000);
                    _posCheck = [(_pos select 0) + _maxRange, (_pos select 1),0];
                    _canFire = _posCheck inRangeOfArtillery [[_lPiece],_mainAmmoType];

                    if not (_canFire) then {
                        _checkRange = _maxRange;
                        _canFire = true;
                        for "_i" from 1000 to 0 step -25 do {
                            _checkRange = (_maxRange - 25);
                            _posCheck = [(_pos select 0) + _checkRange, (_pos select 1),0];
                            _canFire = _posCheck inRangeOfArtillery [[_lPiece],_mainAmmoType];
                            if (_canFire) exitWith {_maxRange = _checkRange};
                        };
                    };

                    _checkRange = _maxRange;
                    if (_checkRange > 200000) then {_timeOut = true};

                    (not (_canFire) or (_timeOut))
                };

                missionNamespace setVariable [QGVAR(classRangeMax) + str (_veh),_maxRange];
                missionNamespace setVariable [QGVAR(classRangeDefined) + str (_veh),true];

            };

            private _prim = "";
            private _rare = "";
            private _sec = "";
            private _smoke = "";
            private _illum = "";

            if (_isArmed) then
                {
                _mags = magazines _vehO;

                if (_isMainT) then
                    {
                    _mags = _mags + ((getArray (_mainT >> "magazines")) - _mags)
                    };

                private _maxHit = 10;

                    {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    private _ammoC = configFile >> "CfgAmmo" >> _ammo;

                    private _actHit = getNumber (_ammoC >> "indirectHitRange");
                    private _subM = toLower (getText (_ammoC >> "submunitionAmmo"));

                    if (_actHit <= 10) then
                        {
                        if not (_subM isEqualTo "") then
                            {
                            _ammoC = configFile >> "CfgAmmo" >> _subM;
                            _actHit = getNumber (_ammoC >> "indirectHitRange")
                            }
                        };

                    if ((_actHit > _maxHit) and {_actHit < 100}) then
                        {
                        _maxHit = _actHit;
                        _prim = _x
                        }
                    }
                forEach _mags;

                _mags = _mags - [_prim];
                private _mags0 = +_mags;
                private _illumChosen = false;
                private _smokeChosen = false;
                private _rareChosen = false;
                private _secChosen = false;

                    {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    private _ammoC = configFile >> "CfgAmmo" >> _ammo;

                    private _hit = getNumber (_ammoC >> "indirectHit");
                    private _lc = _ammoC >> "lightColor";
                    private _sim = toLower (getText (_ammoC >> "simulation"));
                    private _subM = toLower (getText (_ammoC >> "submunitionAmmo"));

                    if (_hit <= 10) then
                        {
                        if not (_subM isEqualTo "") then
                            {
                            _ammoC = configFile >> "CfgAmmo" >> _subM;
                            _hit = getNumber (_ammoC >> "indirectHit")
                            }
                        };

                    switch (true) do
                        {
                        case ((isArray _lc) and {not (_illumChosen)}) :
                            {
                            _illum = _x;
                            _mags = _mags - [_x];
                            _illumChosen = true
                            };

                        case ((_hit <= 10) and {(_subM isEqualTo "smokeshellarty") and {not (_smokeChosen)}}) :
                            {
                            _smoke = _x;
                            _mags = _mags - [_x];
                            _smokeChosen = true
                            };

                        case ((_sim isEqualTo "shotsubmunitions") and {not (_rareChosen)}) :
                            {
                            _rare = _x;
                            _mags = _mags - [_x];
                            _rareChosen = true
                            };

                        case ((_hit > 10) and {not ((_secChosen) or {(_rare == _x)})}) :
                            {
                            _sec = _x;
                            _mags = _mags - [_x];
                            _secChosen = true
                            }
                        }
                    }
                forEach _mags0;

                if (_sec isEqualTo "") then
                    {
                    _maxHit = 10;

                        {
                        private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                        private _ammoC = configFile >> "CfgAmmo" >> _ammo;
                        private _subAmmo = _ammoC >> "subMunitionAmmo";

                        if ((isText _subAmmo) and {not ((getText _subAmmo) isEqualTo "")}) then
                            {
                            _ammoC = configFile >> "CfgAmmo" >> (getText _subAmmo);
                            };

                        private _actHit = getNumber (_ammoC >> "indirectHit");

                        if (_actHit > _maxHit) then
                            {
                            _maxHit = _actHit;
                            _sec = _x
                            }
                        }
                    forEach _mags;
                    };
                };

            private _arr = [_prim,_rare,_sec,_smoke,_illum];
            if (({_x isEqualTo ""} count _arr) < 5) then
                {
                GVAR(add_OtherArty) pushBackUnique [[_veh],_arr]
                }
            };

        if (_isDriver) then
            {
            switch (_type) do
                {
                case ("car") : {GVAR(cars) pushBackUnique _veh};
                case ("tank") : {GVAR(hArmor) pushBackUnique _veh};
                case ("wheeled_apc_f") : {GVAR(lArmor) pushBackUnique _veh};
                case ("air") :
                    {
                    GVAR(air) pushBackUnique _veh;

                    if not (_isArmed) then
                        {
                        GVAR(nCAir) pushBackUnique _veh;
                        };

                    private _isUAV = (getNumber (_vehClass2 >> "Uav")) > 0;

                    if not (_isUAV) then
                        {
                        _isUAV = (toLower (getText (_vehClass2 >> "crew"))) in ["b_uav_ai","i_uav_ai","o_uav_ai"];
                        };

                    if (_isUAV) then
                        {
                        GVAR(rAir) pushBackUnique _veh
                        }
                    };

                case ("ship") : {GVAR(naval) pushBackUnique _veh};
                };

            if (_isCargo) then
                {
                GVAR(cargo) pushBackUnique _veh;
                if not (_isArmed) then
                    {
                    GVAR(nCCargo) pushBackUnique _veh;
                    }
                };

            GVAR(hArmor) = GVAR(hArmor) - GVAR(art);

            if (_isArmed) then
                {
                _mags = magazines _vehO;

                if (_isMainT) then
                    {
                    _mags = _mags + ((getArray (_mainT >> "magazines")) - _mags)
                    };

                    {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    private _ammoC = configFile >> "CfgAmmo" >> _ammo;

                    _isAA = (getNumber (_ammoC >> "airLock")) > 1;
                    _isAT = ((((getNumber (_ammoC >> "irLock")) + (getNumber (_ammoC >> "laserLock"))) > 0) and {((getNumber (_ammoC >> "airLock")) < 2)});

                    if ((_isAA) and {not (_type isEqualTo "air")}) then {GVAR(aAInf) pushBackUnique _veh};
                    if (_isAT) then
                        {
                        if (_type isEqualTo "wheeled_apc_f") then
                            {
                            GVAR(lArmorAT) pushBackUnique _veh
                            }
                        else
                            {
                            if (_type isEqualTo "car") then
                                {
                                GVAR(aTInf) pushBackUnique _veh
                                }
                            }
                        };

                    if ((_isAA) or {(_isAT)}) exitWith {}
                    }
                forEach _mags
                }
            }
        else
            {
            if (_isArmed) then
                {
                GVAR(static) pushBackUnique _veh;

                _mags = magazines _vehO;

                if (_isMainT) then
                    {
                    _mags = _mags + ((getArray (_mainT >> "magazines")) - _mags)
                    };

                    {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    private _ammoC = configFile >> "CfgAmmo" >> _ammo;

                    _isAA = (getNumber (_ammoC >> "airLock")) > 1;
                    _isAT = ((((getNumber (_ammoC >> "irLock")) + (getNumber (_ammoC >> "laserLock"))) > 0) and {((getNumber (_ammoC >> "airLock")) < 2)});

                    if (_isAA) then {GVAR(staticAA) pushBackUnique _veh};
                    if (_isAT) then {GVAR(staticAT) pushBackUnique _veh};

                    if ((_isAA) or {(_isAT)}) exitWith {}
                    }
                forEach _mags
                }
            };

        if (_isAmmoS) then
            {
            if not (_veh in GVAR(ammo)) then
                {
                GVAR(ammo) pushBackUnique _veh
                };

            if not (_veh in GVAR(support)) then
                {
                GVAR(support) pushBackUnique _veh
                }
            };

        if (_isFuelS) then
            {
            if not (_veh in GVAR(fuel)) then
                {
                GVAR(fuel) pushBackUnique _veh
                };

            if not (_veh in GVAR(support)) then
                {
                GVAR(support) pushBackUnique _veh
                }
            };

        if (_isRepS) then
            {
            if not (_veh in GVAR(rep)) then
                {
                GVAR(rep) pushBackUnique _veh
                };

            if not (_veh in GVAR(support)) then
                {
                GVAR(support) pushBackUnique _veh
                }
            };

        if (_isMedS) then
            {
            if not (_veh in GVAR(med)) then
                {
                GVAR(med) pushBackUnique _veh
                };

            if not (_veh in GVAR(support)) then
                {
                GVAR(support) pushBackUnique _veh
                }
            };

        if (_type in ["air","tank","wheeled_apc_f"]) then
            {
            private _crew = _vehClass >> _veh >> "crew";

            if (isText _crew) then
                {
                _crew = toLower (getText _crew);

                if not (_crew in (GVAR(wS_Crew_class) + GVAR(crew))) then
                    {
                    GVAR(crew) pushBackUnique _crew;
                    }
                }
            }
        };
    }
forEach _allVehs;

if (isNil QGVAR(add_OtherArty)) then {GVAR(add_OtherArty) = []};

GVAR(otherArty) = [] + GVAR(add_OtherArty);

    {
        {
        EGVAR(common,allArty) pushBackUnique (toLower _x)
        }
    forEach (_x select 0)
    }
forEach GVAR(otherArty);

publicVariable QGVAR(otherArty);

GVAR(inf) = GVAR(inf) - ["b_uav_ai","i_uav_ai","o_uav_ai"];
GVAR(crew) = GVAR(crew) - ["b_uav_ai","i_uav_ai","o_uav_ai"];

true
