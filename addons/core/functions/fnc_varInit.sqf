#include "..\script_component.hpp"
// Originally from nr6_hal/VarInit.sqf (Section A: variable defaults, lines 1-160)
// NOTE: Weapon class arrays (VarInit lines 162-1084) already live in hal_data/fnc_initWeaponClasses.sqf
// NOTE: Function handle compilation (VarInit lines 1085-1211) replaced by CBA PREP
// NOTE: RHQLibrary.sqf call at VarInit.sqf:161 is NOT invoked here — the library has been migrated
//       and its initializers run through hal_data/XEH_preInit.sqf (Phase 3 work). This function
//       only restores the unique runtime variable defaults.

if (isNil (QGVAR(sPMortars))) then {GVAR(sPMortars) = []};
if (isNil (QGVAR(mortars))) then {GVAR(mortars) = []};
if (isNil (QGVAR(rocketArty))) then {GVAR(rocketArty) = []};

if (isNil ("RHQs_SPMortars")) then {RHQs_SPMortars = []};
if (isNil ("RHQs_Mortars")) then {RHQs_Mortars = []};
if (isNil ("RHQs_RocketArty")) then {RHQs_RocketArty = []};

GVAR(howitzer) = ["m119","m119_us_ep1","d30_cdf","d30_ins","d30_ru","d30_tk_ep1","d30_tk_gue_ep1","d30_tk_ins_ep1"];
GVAR(mortar) = ["m252","m252_us_ep1","2b14_82mm_cdf","2b14_82mm_gue","2b14_82mm_ins","2b14_82mm_tk_ep1","2b14_82mm_tk_gue_ep1","2b14_82mm_tk_ins_ep1"];
GVAR(rocket) = ["mlrs","mlrs_des_ep1","grad_cdf","grad_ins","grad_ru","grad_tk_ep1"];

if (isNil QGVAR(add_OtherArty)) then {GVAR(add_OtherArty) = []};

GVAR(otherArty) = [] + GVAR(add_OtherArty);

GVAR(mortar_A3) = GVAR(mortars) + ["i_mortar_01_f","o_mortar_01_f","b_g_mortar_01_f","b_mortar_01_f"] - RHQs_Mortars;
GVAR(sPMortar_A3) = GVAR(sPMortars) + ["o_mbt_02_arty_f","b_mbt_01_arty_f"] - RHQs_SPMortars;
GVAR(rocket_A3) = GVAR(rocketArty) + ["b_mbt_01_mlrs_f"] - RHQs_RocketArty;

GVAR(allArty) = GVAR(howitzer) + GVAR(mortar) + GVAR(rocket) + GVAR(mortar_A3) + GVAR(sPMortar_A3) + GVAR(rocket_A3);

    {
        {
        GVAR(allArty) pushBack (toLower _x)
        }
    forEach (_x select 0)
    }
forEach GVAR(otherArty);

// Populate hal_common_allArty with the same combined list.
// fnc_cff_tgt.sqf reads GVAR(allArty) from the common component namespace.
// fnc_presentRHQ.sqf also pushBackUnique custom entries into it at runtime.
EGVAR(common,allArty) = +GVAR(allArty);

GVAR(smokeMuzzles) =
    [
    ["SmokeShellMuzzle",["SmokeShell"]],
    ["SmokeShellYellowMuzzle",["SmokeShellYellow"]],
    ["SmokeShellGreenMuzzle",["SmokeShellGreen"]],
    ["SmokeShellRedMuzzle",["SmokeShellRed"]],
    ["SmokeShellPurpleMuzzle",["SmokeShellPurple"]],
    ["SmokeShellOrangeMuzzle",["SmokeShellOrange"]],
    ["SmokeShellBlueMuzzle",["SmokeShellBlue"]],
    ["EGLM",["1Rnd_Smoke_Grenade_shell","1Rnd_SmokeRed_Grenade_shell","1Rnd_SmokeGreen_Grenade_shell","1Rnd_SmokeYellow_Grenade_shell","1Rnd_SmokePurple_Grenade_shell","1Rnd_SmokeBlue_Grenade_shell","1Rnd_SmokeOrange_Grenade_shell"]],
    ["GL_3GL_F",["1Rnd_Smoke_Grenade_shell","1Rnd_SmokeRed_Grenade_shell","1Rnd_SmokeGreen_Grenade_shell","1Rnd_SmokeYellow_Grenade_shell","1Rnd_SmokePurple_Grenade_shell","1Rnd_SmokeBlue_Grenade_shell","1Rnd_SmokeOrange_Grenade_shell","3Rnd_Smoke_Grenade_shell","3Rnd_SmokeRed_Grenade_shell","3Rnd_SmokeGreen_Grenade_shell","3Rnd_SmokeYellow_Grenade_shell","3Rnd_SmokePurple_Grenade_shell","3Rnd_SmokeBlue_Grenade_shell","3Rnd_SmokeOrange_Grenade_shell"]]
    ];

GVAR(flareMuzzles) =
    [
    ["EGLM",["UGL_FlareWhite_F","UGL_FlareGreen_F","UGL_FlareRed_F","UGL_FlareYellow_F","UGL_FlareCIR_F"]],
    ["GL_3GL_F",["UGL_FlareWhite_F","UGL_FlareGreen_F","UGL_FlareRed_F","UGL_FlareYellow_F","UGL_FlareCIR_F","3Rnd_UGL_FlareWhite_F","3Rnd_UGL_FlareGreen_F","3Rnd_UGL_FlareRed_F","3Rnd_UGL_FlareYellow_F","3Rnd_UGL_FlareCIR_F"]]
    ];

if (isNil ("RydART_Amount")) then {RydART_Amount = 6};
if (isNil (QGVAR(active))) then {GVAR(active) = false};
if (isNil ("RydBBa_HQs")) then {RydBBa_HQs = []};
if (isNil ("RydBBb_HQs")) then {RydBBb_HQs = []};
if (isNil (QGVAR(debug))) then {GVAR(debug) = false};
if (isNil ("RydBBa_SimpleDebug")) then {RydBBa_SimpleDebug = false};
if (isNil ("RydBBb_SimpleDebug")) then {RydBBb_SimpleDebug = false};
if (isNil (QGVAR(bBOnMap))) then {GVAR(bBOnMap) = false};
if (isNil (QGVAR(customObjOnly))) then {GVAR(customObjOnly) = false};
if (isNil (QGVAR(lRelocating))) then {GVAR(lRelocating) = true};
if (isNil (QGVAR(lRelocating_Instant))) then {GVAR(lRelocating_Instant) = false};

if (isNil (QGVAR(groupMarks))) then {GVAR(groupMarks) = []};
if (isNil (QGVAR(chatDebug))) then {GVAR(chatDebug) = false};
if (isNil (QGVAR(timeM))) then {GVAR(timeM) = false};
if (isNil (QGVAR(camV))) then {GVAR(camV) = false};
if (isNil (QGVAR(camVIncluded))) then {GVAR(camVIncluded) = []};
if (isNil (QGVAR(camVExcluded))) then {GVAR(camVExcluded) = []};
if (isNil (QGVAR(gPauseActive))) then {GVAR(gPauseActive) = false};
if (isNil (QGVAR(dbgMon))) then {GVAR(dbgMon) = true};

if (isNil (QGVAR(specFor))) then {GVAR(specFor) = []};
if (isNil (QGVAR(recon))) then {GVAR(recon) = []};
if (isNil (QGVAR(fO))) then {GVAR(fO) = []};
if (isNil (QGVAR(snipers))) then {GVAR(snipers) = []};
if (isNil (QGVAR(aTInf))) then {GVAR(aTInf) = []};
if (isNil (QGVAR(aAInf))) then {GVAR(aAInf) = []};
if (isNil (QGVAR(inf))) then {GVAR(inf) = []};
if (isNil (QGVAR(art))) then {GVAR(art) = []};
if (isNil (QGVAR(hArmor))) then {GVAR(hArmor) = []};
if (isNil (QGVAR(lArmor))) then {GVAR(lArmor) = []};
if (isNil (QGVAR(lArmorAT))) then {GVAR(lArmorAT) = []};
if (isNil (QGVAR(cars))) then {GVAR(cars) = []};
if (isNil (QGVAR(air))) then {GVAR(air) = []};
if (isNil (QGVAR(nCAir))) then {GVAR(nCAir) = []};
if (isNil (QGVAR(naval))) then {GVAR(naval) = []};
if (isNil (QGVAR(static))) then {GVAR(static) = []};
if (isNil (QGVAR(staticAA))) then {GVAR(staticAA) = []};
if (isNil (QGVAR(staticAT))) then {GVAR(staticAT) = []};
if (isNil (QGVAR(support))) then {GVAR(support) = []};
if (isNil (QGVAR(cargo))) then {GVAR(cargo) = []};
if (isNil (QGVAR(nCCargo))) then {GVAR(nCCargo) = []};
if (isNil (QGVAR(other))) then {GVAR(other) = []};
if (isNil (QGVAR(crew))) then {GVAR(crew) = []};
if (isNil (QGVAR(mArmor))) then {GVAR(mArmor) = []};
if (isNil (QGVAR(bAir))) then {GVAR(bAir) = []};
if (isNil (QGVAR(rAir))) then {GVAR(rAir) = []};
if (isNil (QGVAR(ammo))) then {GVAR(ammo) = []};
if (isNil (QGVAR(fuel))) then {GVAR(fuel) = []};
if (isNil (QGVAR(med))) then {GVAR(med) = []};
if (isNil (QGVAR(rep))) then {GVAR(rep) = []};

if (isNil ("RHQs_SpecFor")) then {RHQs_SpecFor = []};
if (isNil ("RHQs_Recon")) then {RHQs_Recon = []};
if (isNil ("RHQs_FO")) then {RHQs_FO = []};
if (isNil ("RHQs_Snipers")) then {RHQs_Snipers = []};
if (isNil ("RHQs_ATInf")) then {RHQs_ATInf = []};
if (isNil ("RHQs_AAInf")) then {RHQs_AAInf = []};
if (isNil ("RHQs_Inf")) then {RHQs_Inf = []};
if (isNil ("RHQs_Art")) then {RHQs_Art = []};
if (isNil ("RHQs_HArmor")) then {RHQs_HArmor = []};
if (isNil ("RHQs_LArmor")) then {RHQs_LArmor = []};
if (isNil ("RHQs_LArmorAT")) then {RHQs_LArmorAT = []};
if (isNil ("RHQs_Cars")) then {RHQs_Cars = []};
if (isNil ("RHQs_Air")) then {RHQs_Air = []};
if (isNil ("RHQs_NCAir")) then {RHQs_NCAir = []};
if (isNil ("RHQs_Naval")) then {RHQs_Naval = []};
if (isNil ("RHQs_Static")) then {RHQs_Static = []};
if (isNil ("RHQs_StaticAA")) then {RHQs_StaticAA = []};
if (isNil ("RHQs_StaticAT")) then {RHQs_StaticAT = []};
if (isNil ("RHQs_Support")) then {RHQs_Support = []};
if (isNil ("RHQs_Cargo")) then {RHQs_Cargo = []};
if (isNil ("RHQs_NCCargo")) then {RHQs_NCCargo = []};
if (isNil ("RHQs_Other")) then {RHQs_Other = []};
if (isNil ("RHQs_Crew")) then {RHQs_Crew = []};
if (isNil ("RHQs_MArmor")) then {RHQs_MArmor = []};
if (isNil ("RHQs_BAir")) then {RHQs_BAir = []};
if (isNil ("RHQs_RAir")) then {RHQs_RAir = []};
if (isNil ("RHQs_Ammo")) then {RHQs_Ammo = []};
if (isNil ("RHQs_Fuel")) then {RHQs_Fuel = []};
if (isNil ("RHQs_Med")) then {RHQs_Med = []};
if (isNil ("RHQs_Rep")) then {RHQs_Rep = []};

if (isNil (QGVAR(debug))) then {GVAR(debug) = false};
if (isNil (QGVAR(debugB))) then {GVAR(debugB) = false};
if (isNil (QGVAR(debugC))) then {GVAR(debugC) = false};
if (isNil (QGVAR(debugD))) then {GVAR(debugD) = false};
if (isNil (QGVAR(debugE))) then {GVAR(debugE) = false};
if (isNil (QGVAR(debugF))) then {GVAR(debugF) = false};
if (isNil (QGVAR(debugG))) then {GVAR(debugG) = false};
if (isNil (QGVAR(debugH))) then {GVAR(debugH) = false};

if (isNil (QGVAR(debugII))) then {GVAR(debugII) = false};
if (isNil (QGVAR(debugIIB))) then {GVAR(debugIIB) = false};
if (isNil (QGVAR(debugIIC))) then {GVAR(debugIIC) = false};
if (isNil (QGVAR(debugIID))) then {GVAR(debugIID) = false};
if (isNil (QGVAR(debugIIE))) then {GVAR(debugIIE) = false};
if (isNil (QGVAR(debugIIF))) then {GVAR(debugIIF) = false};
if (isNil (QGVAR(debugIIG))) then {GVAR(debugIIG) = false};
if (isNil (QGVAR(debugIIH))) then {GVAR(debugIIH) = false};

if (isNil (QGVAR(rHQCheck))) then {GVAR(rHQCheck) = false};

if (isNil (QGVAR(a2Lib))) then {GVAR(a2Lib) = false};
if (isNil (QGVAR(oALib))) then {GVAR(oALib) = false};
if (isNil (QGVAR(aCRLib))) then {GVAR(aCRLib) = false};
if (isNil (QGVAR(bAFLib))) then {GVAR(bAFLib) = false};
if (isNil (QGVAR(pMCLib))) then {GVAR(pMCLib) = false};

// Call-sign noun pool — read with +GVAR(callSignsN) (array copy, no nil guard) by all
// fnc_HQSitRep*.sqf variants. Must be seeded here before those loops start.
// Originally from nr6_hal/VarInit.sqf lines 196-233 (RydHQ_CallSignsN).
if (isNil (QGVAR(callSignsN))) then
    {
    GVAR(callSignsN) =
        [
        [
        ["PERSEUS",[]],
        ["AJAX",[]],
        ["HECTOR",[]],
        ["CASTOR",[]],
        ["JASON",[]],
        ["ACHILLES",[]]
        ],
        [
        ["LADON",[]],
        ["CERBERUS",[]],
        ["MANTICORE",[]],
        ["MINOTAUR",[]],
        ["CENTAUR",[]],
        ["CHIMERA",[]]
        ],
        [
        ["PHOENIX",[]],
        ["HARPY",[]],
        ["GRIFFIN",[]],
        ["SPHINX",[]],
        ["PEGASUS",[]],
        ["ERINYS",[]]
        ],
        [
        ["HERACLES",[]],
        ["CYCLOPS",[]],
        ["ARES",[]],
        ["ATLAS",[]],
        ["TYPHON",[]],
        ["POLYPHEMUS",[]]
        ]
        ]
    };
