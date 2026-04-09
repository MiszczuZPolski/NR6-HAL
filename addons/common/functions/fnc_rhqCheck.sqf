#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_RHQCheck)

/**
 * @description Validates that all unit/vehicle classes present in the mission are registered
 *              in the RHQ (Reinforcement HQ) configuration. Logs missing classes to the RPT
 *              and shows a summary hint to the player.
 */

private _civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];

private _specFor  = RHQ_SpecFor  + RYD_WS_specFor_class  - RHQs_SpecFor;
private _recon    = RHQ_Recon    + RYD_WS_recon_class    - RHQs_Recon;
private _FO       = RHQ_FO       + RYD_WS_FO_class       - RHQs_FO;
private _snipers  = RHQ_Snipers  + RYD_WS_snipers_class  - RHQs_Snipers;
private _ATinf    = RHQ_ATInf    + RYD_WS_ATinf_class    - RHQs_ATInf;
private _AAinf    = RHQ_AAInf    + RYD_WS_AAinf_class    - RHQs_AAInf;
private _Inf      = RHQ_Inf      + RYD_WS_Inf_class      - RHQs_Inf;
private _Art      = RHQ_Art      + RYD_WS_Art_class      - RHQs_Art;
private _HArmor   = RHQ_HArmor   + RYD_WS_HArmor_class   - RHQs_HArmor;
private _MArmor   = RHQ_MArmor   + RYD_WS_MArmor_class   - RHQs_MArmor;
private _LArmor   = RHQ_LArmor   + RYD_WS_LArmor_class   - RHQs_LArmor;
private _LArmorAT = RHQ_LArmorAT + RYD_WS_LArmorAT_class - RHQs_LArmorAT;
private _Cars     = RHQ_Cars     + RYD_WS_Cars_class      - RHQs_Cars;
private _Air      = RHQ_Air      + RYD_WS_Air_class       - RHQs_Air;
private _BAir     = RHQ_BAir     + RYD_WS_BAir_class      - RHQs_BAir;
private _RAir     = RHQ_RAir     + RYD_WS_RAir_class      - RHQs_RAir;
private _NCAir    = RHQ_NCAir    + RYD_WS_NCAir_class     - RHQs_NCAir;
private _Naval    = RHQ_Naval    + RYD_WS_Naval_class      - RHQs_Naval;
private _Static   = RHQ_Static   + RYD_WS_Static_class    - RHQs_Static;
private _StaticAA = RHQ_StaticAA + RYD_WS_StaticAA_class  - RHQs_StaticAA;
private _StaticAT = RHQ_StaticAT + RYD_WS_StaticAT_class  - RHQs_StaticAT;
private _Support  = RHQ_Support  + RYD_WS_Support_class   - RHQs_Support;
private _Cargo    = RHQ_Cargo    + RYD_WS_Cargo_class      - RHQs_Cargo;
private _NCCargo  = RHQ_NCCargo  + RYD_WS_NCCargo_class   - RHQs_NCCargo;
private _Crew     = RHQ_Crew     + RYD_WS_Crew_class       - RHQs_Crew;
private _Other    = RHQ_Other    + RYD_WS_Other_class;
private _ammo     = RHQ_Ammo     + RYD_WS_ammo            - RHQs_Ammo;
private _fuel     = RHQ_Fuel     + RYD_WS_fuel             - RHQs_Fuel;
private _med      = RHQ_Med      + RYD_WS_med              - RHQs_Med;
private _rep      = RHQ_Rep      + RYD_WS_rep              - RHQs_Rep;

private _basicrhq      = _Inf + _Art + _HArmor + _LArmor + _Cars + _Air + _Naval + _Static;
private _Additionalrhq = _Other + _specFor + _recon + _FO + _snipers + _ATinf + _AAinf + _LArmorAT
                       + _NCAir + _StaticAA + _StaticAT + _Cargo + _NCCargo + _Crew + _MArmor
                       + _BAir + _RAir + _ammo + _fuel + _med + _rep;
private _total = _basicrhq + _Additionalrhq;

private _noInBasic      = [];
private _noInAdditional = [];
private _noInTotal      = [];

{
    if !((faction _x) in _civF) then {
        private _type = toLower (typeOf _x);
        if !((_type in _basicrhq)      || (_type in _noInBasic))      then { _noInBasic      pushBack _type };
        if !((_type in _Additionalrhq) || (_type in _noInAdditional)) then { _noInAdditional pushBack _type };
        if !((_type in _total)         || (_type in _noInTotal))       then { _noInTotal      pushBack _type };
    };
} forEach (allUnits + vehicles);

diag_log "-------------------------------------------------------------------------";
diag_log "-----------------------------RHQCHECK REPORT-----------------------------";
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added to basic RHQ:";
{ diag_log format ["%1", _x] } forEach _noInBasic;
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added to exact RHQ (not all must be):";
{ diag_log format ["%1", _x] } forEach _noInAdditional;
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added anywhere:";
{ diag_log format ["%1", _x] } forEach _noInTotal;
diag_log "-------------------------------------------------------------------------";
diag_log "-------------------------END OF RHQCHECK REPORT--------------------------";
diag_log "-------------------------------------------------------------------------";

"RHQ CHECK" hintC format [
    "Forgotten classes: %1\nClasses not present in basic categories: %2\n(see RPT file for detailed forgotten classes list)",
    count _noInTotal,
    count _noInBasic
];
