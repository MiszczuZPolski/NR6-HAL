#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:678-848 (RYD_StatusQuo, block S3b - enemy classification)

/**
 * @description Classifies known-enemy forces into typed arrays (EnInf, EnArmor, EnAir, etc.)
 *              by inspecting each unit's typeOf against the RYD_WS_* class arrays.
 *              Writes results directly to HQ setVariable slots.
 * @param {Group} _HQ The HQ group
 * @param {Array} _knownEG Array of known enemy groups to classify
 * @param {Number} _EValue Starting enemy force-value score
 * @return {Array} [_EValue, _EnInf, _EnInfG, _EnHArmor, _EnMArmor, _EnLArmor, _EnArt, _EnArtG,
 *                  _EnStaticG, _EnRAirG, _EnNCrewInf, _EnNCrewInfG]
 */
params ["_HQ", "_knownEG", "_EValue"];

private _specFor_class = EGVAR(data,wS_specFor_class);
private _recon_class = EGVAR(data,wS_recon_class);
private _FO_class = EGVAR(data,wS_FO_class);
private _snipers_class = EGVAR(data,wS_snipers_class);
private _ATinf_class = EGVAR(data,wS_ATinf_class);
private _AAinf_class = EGVAR(data,wS_AAinf_class);
private _Inf_class = EGVAR(data,wS_Inf_class);
private _Art_class = EGVAR(data,wS_Art_class);
private _HArmor_class = EGVAR(data,wS_HArmor_class);
private _MArmor_class = EGVAR(data,wS_MArmor_class);
private _LArmor_class = EGVAR(data,wS_LArmor_class);
private _LArmorAT_class = EGVAR(data,wS_LArmorAT_class);
private _Cars_class = EGVAR(data,wS_Cars_class);
private _Air_class = EGVAR(data,wS_Air_class);
private _BAir_class = EGVAR(data,wS_BAir_class);
private _RAir_class = EGVAR(data,wS_RAir_class);
private _NCAir_class = EGVAR(data,wS_NCAir_class);
private _Naval_class = EGVAR(data,wS_Naval_class);
private _Static_class = EGVAR(data,wS_Static_class);
private _StaticAA_class = EGVAR(data,wS_StaticAA_class);
private _StaticAT_class = EGVAR(data,wS_StaticAT_class);
private _Cargo_class = EGVAR(data,wS_Cargo_class);
private _NCCargo_class = EGVAR(data,wS_NCCargo_class);
private _Crew_class = EGVAR(data,wS_Crew_class);
private _NCrewInf_class = _Inf_class - _Crew_class;
private _Support_class = EGVAR(data,wS_Support_class);

private _EnSpecFor = [];
private _Enrecon = [];
private _EnFO = [];
private _Ensnipers = [];
private _EnATinf = [];
private _EnAAinf = [];
private _EnInf = [];
private _EnArt = [];
private _EnHArmor = [];
private _EnMArmor = [];
private _EnLArmor = [];
private _EnLArmorAT = [];
private _EnCars = [];
private _EnAir = [];
private _EnBAir = [];
private _EnRAir = [];
private _EnNCAir = [];
private _EnNaval = [];
private _EnStatic = [];
private _EnStaticAA = [];
private _EnStaticAT = [];
private _EnSupport = [];
private _EnCargo = [];
private _EnNCCargo = [];
private _EnOther = [];
private _EnCrew = [];
private _EnNCrewInf = [];

private _EnSpecForG = [];
private _EnreconG = [];
private _EnFOG = [];
private _EnsnipersG = [];
private _EnATinfG = [];
private _EnAAinfG = [];
private _EnInfG = [];
private _EnArtG = [];
private _EnHArmorG = [];
private _EnMArmorG = [];
private _EnLArmorG = [];
private _EnLArmorATG = [];
private _EnCarsG = [];
private _EnAirG = [];
private _EnBAirG = [];
private _EnRAirG = [];
private _EnNCAirG = [];
private _EnNavalG = [];
private _EnStaticG = [];
private _EnStaticAAG = [];
private _EnStaticATG = [];
private _EnSupportG = [];
private _EnCargoG = [];
private _EnNCCargoG = [];
private _EnOtherG = [];
private _EnCrewG = [];
private _EnNCrewInfG = [];

    {
        {
        private _SpecForcheck = false;
        private _reconcheck = false;
        private _FOcheck = false;
        private _sniperscheck = false;
        private _ATinfcheck = false;
        private _AAinfcheck = false;
        private _Infcheck = false;
        private _Artcheck = false;
        private _HArmorcheck = false;
        private _MArmorcheck = false;
        private _LArmorcheck = false;
        private _LArmorATcheck = false;
        private _Carscheck = false;
        private _Aircheck = false;
        private _BAircheck = false;
        private _RAircheck = false;
        private _NCAircheck = false;
        private _Navalcheck = false;
        private _Staticcheck = false;
        private _StaticAAcheck = false;
        private _StaticATcheck = false;
        private _Supportcheck = false;
        private _Cargocheck = false;
        private _NCCargocheck = false;
        private _Othercheck = true;

        private _Crewcheck = false;
        private _NCrewInfcheck = false;

        private _tp = toLower (typeOf _x);
        private _grp = group _x;
        private _vh = vehicle _x;
        if (_x == _vh) then {_vh = objNull};
        private _asV = assignedVehicle _x;
        private _grpD = group (driver _vh);
        private _grpG = group (gunner _vh);
        if (isNull _grpD) then {_grpD = _grpG};
        private _Tvh = toLower (typeOf _vh);
        private _TasV = toLower (typeOf _asV);

            if (((_grp == _grpD) and {(_Tvh in _specFor_class)}) or {(_tp in _specFor_class)}) then {_SpecForcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _recon_class)}) or {(_tp in _recon_class)}) then {_reconcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _FO_class)}) or {(_tp in _FO_class)}) then {_FOcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _snipers_class)}) or {(_tp in _snipers_class)}) then {_sniperscheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _ATinf_class)}) or {(_tp in _ATinf_class)}) then {_ATinfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _AAinf_class)}) or {(_tp in _AAinf_class)}) then {_AAinfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Inf_class)}) or {(_tp in _Inf_class)}) then {_Infcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Art_class)}) or {(_tp in _Art_class)}) then {_Artcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _HArmor_class)}) or {(_tp in _HArmor_class)}) then {_HArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _MArmor_class)}) or {(_tp in _MArmor_class)}) then {_MArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _LArmor_class)}) or {(_tp in _LArmor_class)}) then {_LArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _LArmorAT_class)}) or {(_tp in _LArmorAT_class)}) then {_LArmorATcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Cars_class)}) or {(_tp in _Cars_class)}) then {_Carscheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Air_class)}) or {(_tp in _Air_class)}) then {_Aircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _BAir_class)}) or {(_tp in _BAir_class)}) then {_BAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _RAir_class)}) or {(_tp in _RAir_class)}) then {_RAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCAir_class)}) or {(_tp in _NCAir_class)}) then {_NCAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Naval_class)}) or {(_tp in _Naval_class)}) then {_Navalcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _Static_class)}) or {(_tp in _Static_class)}) then {_Staticcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _StaticAA_class)}) or {(_tp in _StaticAA_class)}) then {_StaticAAcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _StaticAT_class)}) or {(_tp in _StaticAT_class)}) then {_StaticATcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Cargo_class)}) or {(_tp in _Cargo_class)}) then {_Cargocheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCCargo_class)}) or {(_tp in _NCCargo_class)}) then {_NCCargocheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Crew_class)}) or {(_tp in _Crew_class)}) then {_Crewcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCrewInf_class)}) or {(_tp in _NCrewInf_class)}) then {_NCrewInfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Support_class)}) or {(_tp in _Support_class)}) then {_Supportcheck = true;_NCrewInfcheck = false;_Othercheck = false};

            if ((_Tvh in _NCCargo_class) and {(_x == (assignedDriver _asV)) and {((count (units (group _x))) == 1) and {not ((_ATinfcheck) or {(_AAinfcheck) or {(_reconcheck) or {(_FOcheck) or {(_sniperscheck)}}}})}}}) then {_NCrewInfcheck = false;_Othercheck = false};

            _vh = vehicle _x;

            if (_SpecForcheck) then {if not (_vh in _EnSpecFor) then {_EnSpecFor pushBack _vh};if not (_grp in _EnSpecForG) then {_EnSpecForG pushBack _grp}};
            if (_reconcheck) then {if not (_vh in _Enrecon) then {_Enrecon pushBack _vh};if not (_grp in _EnreconG) then {_EnreconG pushBack _grp}};
            if (_FOcheck) then {if not (_vh in _EnFO) then {_EnFO pushBack _vh};if not (_grp in _EnFOG) then {_EnFOG pushBack _grp}};
            if (_sniperscheck) then {if not (_vh in _Ensnipers) then {_Ensnipers pushBack _vh};if not (_grp in _EnsnipersG) then {_EnsnipersG pushBack _grp}};
            if (_ATinfcheck) then {if not (_vh in _EnATinf) then {_EnATinf pushBack _vh};if not (_grp in _EnATinfG) then {_EnATinfG pushBack _grp}};
            if (_AAinfcheck) then {if not (_vh in _EnAAinf) then {_EnAAinf pushBack _vh};if not (_grp in _EnAAinfG) then {_EnAAinfG pushBack _grp}};
            if (_Infcheck) then {if not (_vh in _EnInf) then {_EValue = _EValue + 1;_EnInf pushBack _vh};if not (_grp in _EnInfG) then {_EnInfG pushBack _grp}};
            if (_Artcheck) then {if not (_vh in _EnArt) then {_EValue = _EValue + 3;_EnArt pushBack _vh};if not (_grp in _EnArtG) then {_EnArtG pushBack _grp}};
            if (_HArmorcheck) then {if not (_vh in _EnHArmor) then {_EValue = _EValue + 10;_EnHArmor pushBack _vh};if not (_grp in _EnHArmorG) then {_EnHArmorG pushBack _grp}};
            if (_MArmorcheck) then {if not (_vh in _EnMArmor) then {_EnMArmor pushBack _vh};if not (_grp in _EnMArmorG) then {_EnMArmorG pushBack _grp}};
            if (_LArmorcheck) then {if not (_vh in _EnLArmor) then {_EValue = _EValue + 5;_EnLArmor pushBack _vh};if not (_grp in _EnLArmorG) then {_EnLArmorG pushBack _grp}};
            if (_LArmorATcheck) then {if not (_vh in _EnLArmorAT) then {_EnLArmorAT pushBack _vh};if not (_grp in _EnLArmorATG) then {_EnLArmorATG pushBack _grp}};
            if (_Carscheck) then {if not (_vh in _EnCars) then {_EValue = _EValue + 3;_EnCars pushBack _vh};if not (_grp in _EnCarsG) then {_EnCarsG pushBack _grp}};
            if (_Aircheck) then {if not (_vh in _EnAir) then {_EValue = _EValue + 15;_EnAir pushBack _vh};if not (_grp in _EnAirG) then {_EnAirG pushBack _grp}};
            if (_BAircheck) then {if not (_vh in _EnBAir) then {_EnBAir pushBack _vh};if not (_grp in _EnBAirG) then {_EnBAirG pushBack _grp}};
            if (_RAircheck) then {if not (_vh in _EnRAir) then {_EnRAir pushBack _vh};if not (_grp in _EnRAirG) then {_EnRAirG pushBack _grp}};
            if (_NCAircheck) then {if not (_vh in _EnNCAir) then {_EnNCAir pushBack _vh};if not (_grp in _EnNCAirG) then {_EnNCAirG pushBack _grp}};
            if (_Navalcheck) then {if not (_vh in _EnNaval) then {_EnNaval pushBack _vh};if not (_grp in _EnNavalG) then {_EnNavalG pushBack _grp}};
            if (_Staticcheck) then {if not (_vh in _EnStatic) then {_EValue = _EValue + 1;_EnStatic pushBack _vh};if not (_grp in _EnStaticG) then {_EnStaticG pushBack _grp}};
            if (_StaticAAcheck) then {if not (_vh in _EnStaticAA) then {_EnStaticAA pushBack _vh};if not (_grp in _EnStaticAAG) then {_EnStaticAAG pushBack _grp}};
            if (_StaticATcheck) then {if not (_vh in _EnStaticAT) then {_EnStaticAT pushBack _vh};if not (_grp in _EnStaticATG) then {_EnStaticATG pushBack _grp}};
            if (_Supportcheck) then {if not (_vh in _EnSupport) then {_EnSupport pushBack _vh};if not (_grp in _EnSupportG) then {_EnSupportG pushBack _grp}};
            if (_Cargocheck) then {if not (_vh in _EnCargo) then {_EnCargo pushBack _vh};if not (_grp in _EnCargoG) then {_EnCargoG pushBack _grp}};
            if (_NCCargocheck) then {if not (_vh in _EnNCCargo) then {_EnNCCargo pushBack _vh};if not (_grp in _EnNCCargoG) then {_EnNCCargoG pushBack _grp}};
            if (_Crewcheck) then {if not (_vh in _EnCrew) then {_EnCrew pushBack _vh};if not (_grp in _EnCrewG) then {_EnCrewG pushBack _grp}};
            if (_NCrewInfcheck) then {if not (_vh in _EnNCrewInf) then {_EnNCrewInf pushBack _vh};if not (_grp in _EnNCrewInfG) then {_EnNCrewInfG pushBack _grp}};

        }
    forEach (units _x)
    }
forEach _knownEG;

_HQ setVariable [QEGVAR(boss,eValue),_EValue];

_HQ setVariable [QGVAR(enSpecFor),_EnSpecFor];
_HQ setVariable [QGVAR(enrecon),_Enrecon];
_HQ setVariable [QGVAR(enFO),_EnFO];
_HQ setVariable [QGVAR(ensnipers),_Ensnipers];
_HQ setVariable [QGVAR(enATinf),_EnATinf];
_HQ setVariable [QGVAR(enAAinf),_EnAAinf];
_HQ setVariable [QGVAR(enArt),_EnArt];
_HQ setVariable [QGVAR(enHArmor),_EnHArmor];
_HQ setVariable [QGVAR(enMArmor),_EnMArmor];
_HQ setVariable [QGVAR(enLArmor),_EnLArmor];
_HQ setVariable [QGVAR(enLArmorAT),_EnLArmorAT];
_HQ setVariable [QGVAR(enCars),_EnCars];
_HQ setVariable [QGVAR(enAir),_EnAir];
_HQ setVariable [QGVAR(enBAir),_EnBAir];
_HQ setVariable [QGVAR(enRAir),_EnRAir];
_HQ setVariable [QGVAR(enNCAir),_EnNCAir];
_HQ setVariable [QGVAR(enNaval),_EnNaval];
_HQ setVariable [QGVAR(enStatic),_EnStatic];
_HQ setVariable [QGVAR(enStaticAA),_EnStaticAA];
_HQ setVariable [QGVAR(enStaticAT),_EnStaticAT];
_HQ setVariable [QGVAR(enSupport),_EnSupport];
_HQ setVariable [QGVAR(enCargo),_EnCargo];
_HQ setVariable [QGVAR(enNCCargo),_EnNCCargo];
_HQ setVariable [QGVAR(enOther),_EnOther];
_HQ setVariable [QGVAR(enCrew),_EnCrew];

_HQ setVariable [QGVAR(enSpecForG),_EnSpecForG];
_HQ setVariable [QGVAR(enreconG),_EnreconG];
_HQ setVariable [QGVAR(enFOG),_EnFOG];
_HQ setVariable [QGVAR(ensnipersG),_EnsnipersG];
_HQ setVariable [QGVAR(enATinfG),_EnATinfG];
_HQ setVariable [QGVAR(enAAinfG),_EnAAinfG];
_HQ setVariable [QGVAR(enArtG),_EnArtG];
_HQ setVariable [QEGVAR(boss,enHArmorG),_EnHArmorG];
_HQ setVariable [QGVAR(enMArmorG),_EnMArmorG];
_HQ setVariable [QEGVAR(boss,enLArmorG),_EnLArmorG];
_HQ setVariable [QGVAR(enLArmorATG),_EnLArmorATG];
_HQ setVariable [QEGVAR(boss,enCarsG),_EnCarsG];
_HQ setVariable [QEGVAR(boss,enAirG),_EnAirG];
_HQ setVariable [QGVAR(enBAirG),_EnBAirG];
_HQ setVariable [QGVAR(enRAirG),_EnRAirG];
_HQ setVariable [QEGVAR(boss,enNCAirG),_EnNCAirG];
_HQ setVariable [QGVAR(enNavalG),_EnNavalG];
_HQ setVariable [QGVAR(enStaticG),_EnStaticG];
_HQ setVariable [QGVAR(enStaticAAG),_EnStaticAAG];
_HQ setVariable [QGVAR(enStaticATG),_EnStaticATG];
_HQ setVariable [QEGVAR(boss,enSupportG),_EnSupportG];
_HQ setVariable [QGVAR(enCargoG),_EnCargoG];
_HQ setVariable [QEGVAR(boss,enNCCargoG),_EnNCCargoG];
_HQ setVariable [QGVAR(enOtherG),_EnOtherG];
_HQ setVariable [QGVAR(enCrewG),_EnCrewG];

_EnNCrewInfG = _EnNCrewInfG - (_EnRAirG + _EnStaticG);
_EnNCrewInf = _EnNCrewInf - (_EnRAir + _EnStatic);
_EnInfG = _EnInfG - (_EnRAirG + _EnStaticG);
_EnInf = _EnInf - (_EnRAir + _EnStatic);

_HQ setVariable [QGVAR(enNCrewInf),_EnNCrewInf];
_HQ setVariable [QGVAR(enNCrewInfG),_EnNCrewInfG];
_HQ setVariable [QGVAR(enInf),_EnInf];
_HQ setVariable [QEGVAR(boss,enInfG),_EnInfG];

[_EValue, _EnInf, _EnInfG, _EnHArmor, _EnMArmor, _EnLArmor, _EnArt, _EnArtG,
 _EnStaticG, _EnRAirG, _EnNCrewInf, _EnNCrewInfG]
