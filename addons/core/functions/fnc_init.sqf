#include "..\script_component.hpp"
// Originally from RydHQInit.sqf

params ["_logic", "_units", "_activated"];

if !(isServer) exitWith {};

// Restore VarInit.sqf Section A variable defaults (artillery, smoke/flare muzzles,
// debug flags, faction-lib toggles). Replaces the legacy `preprocessFile VarInit.sqf`
// loader that was removed in Phase 3. Phase 5 plan 01 COMPAT-04.
call FUNC(varInit);

GVAR(wait) = _logic getVariable [QGVAR(wait), 15];


GVAR(reconCargo) = missionNamespace getVariable [QGVAR(reconCargo),true];
publicVariable QGVAR(reconCargo);
GVAR(synchroAttack) = missionNamespace getVariable [QGVAR(synchroAttack),false];
publicVariable QGVAR(synchroAttack);
GVAR(infoMarkersID) = missionNamespace getVariable [QGVAR(infoMarkersID),true];
publicVariable QGVAR(infoMarkersID);

GVAR(actions) = missionNamespace getVariable [QGVAR(actions),true];
publicVariable QGVAR(actions);
GVAR(actionsMenu) = missionNamespace getVariable [QGVAR(actionsMenu),true];
publicVariable QGVAR(actionsMenu);

GVAR(taskActions) = missionNamespace getVariable [QGVAR(taskActions),false];
publicVariable QGVAR(taskActions);
GVAR(supportActions) = missionNamespace getVariable [QGVAR(supportActions),false];
publicVariable QGVAR(supportActions);
GVAR(actionsAceOnly) = missionNamespace getVariable [QGVAR(actionsAceOnly),false];
publicVariable QGVAR(actionsAceOnly);

GVAR(noRestPlayers) = missionNamespace getVariable [QGVAR(noRestPlayers),true];
publicVariable QGVAR(noRestPlayers);
GVAR(noCargoPlayers) = missionNamespace getVariable [QGVAR(noCargoPlayers),true];
publicVariable QGVAR(noCargoPlayers);

GVAR(lZ) = missionNamespace getVariable [QGVAR(lZ),true];
publicVariable QGVAR(lZ);

RydART_Safe = missionNamespace getVariable ["RydART_Safe",250];
publicVariable "RydART_Safe";

GVAR(lZ) = GVAR(lZ);
GVAR(lZB) = GVAR(lZ);
GVAR(lZC) = GVAR(lZ);
GVAR(lZD) = GVAR(lZ);
GVAR(lZE) = GVAR(lZ);
GVAR(lZF) = GVAR(lZ);
GVAR(lZG) = GVAR(lZ);
GVAR(lZH) = GVAR(lZ);

//LZ setting was coded in entire system as Leader specific despite making far more sense as a general setting. Will clean it up eventually.

GVAR(hQChat) = missionNamespace getVariable [QGVAR(hQChat),true];
publicVariable QGVAR(hQChat);
GVAR(aIChatDensity) = missionNamespace getVariable [QGVAR(aIChatDensity),100];
publicVariable QGVAR(aIChatDensity);
GVAR(aIChat_Type) = missionNamespace getVariable [QGVAR(aIChat_Type),100];
publicVariable QGVAR(aIChat_Type);
GVAR(garrisonV2) = missionNamespace getVariable [QGVAR(garrisonV2),true];
publicVariable QGVAR(garrisonV2);
GVAR(nEAware) = missionNamespace getVariable [QGVAR(nEAware),500];
publicVariable QGVAR(nEAware);
GVAR(slingDrop) = missionNamespace getVariable [QGVAR(slingDrop),false];
publicVariable QGVAR(slingDrop);
GVAR(rHQAutoFill) = missionNamespace getVariable [QGVAR(rHQAutoFill),true];
publicVariable QGVAR(rHQAutoFill);

GVAR(pathFinding) = missionNamespace getVariable [QGVAR(pathFinding),0];
publicVariable QGVAR(pathFinding);

GVAR(magicHeal) = missionNamespace getVariable [QGVAR(magicHeal),false];
publicVariable QGVAR(magicHeal);
GVAR(magicRepair) = missionNamespace getVariable [QGVAR(magicRepair),false];
publicVariable QGVAR(magicRepair);
GVAR(magicRearm) = missionNamespace getVariable [QGVAR(magicRearm),false];
publicVariable QGVAR(magicRearm);
GVAR(magicRefuel) = missionNamespace getVariable [QGVAR(magicRefuel),false];
publicVariable QGVAR(magicRefuel);

GVAR(playerCargoCheckLoopTime) = missionNamespace getVariable [QGVAR(playerCargoCheckLoopTime),2];
publicVariable QGVAR(playerCargoCheckLoopTime);

GVAR(disembarkRange) = missionNamespace getVariable [QGVAR(disembarkRange),200];
publicVariable QGVAR(disembarkRange);

GVAR(cargoObjRange) = missionNamespace getVariable [QGVAR(cargoObjRange),1500];
publicVariable QGVAR(cargoObjRange);

GVAR(reconCargo) = missionNamespace getVariable [QGVAR(reconCargo),false];
publicVariable QGVAR(reconCargo);

GVAR(wS_ArtyMarks) = missionNamespace getVariable [QGVAR(wS_ArtyMarks),false];
publicVariable QGVAR(wS_ArtyMarks);

GVAR(path) = "\NR6_HAL\";

// TaskInitNR6.sqf 72 Action* callbacks are now loaded via hal_tasking addon's CBA preInit path (Phase 3, Plan 05).
// Legacy preprocessFile loaders (HAC_fnc, HAC_fnc2, VarInit, TaskMenu, TaskInitNR6) removed during Phase 3.

//can be replaced with getMarkerType and getMarkerSize
HAL_fnc_getType = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getType.sqf";
HAL_fnc_getSize = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getSize.sqf";

//used to "compile" list of units types usable by AI
if (GVAR(rHQCheck)) then {[] call EFUNC(common,rhqCheck)};

GVAR(allLeaders) = [];
GVAR(allHQ) = [];

private _clB = [Map_BLUFOR_R,Map_BLUFOR_G,Map_BLUFOR_B,Map_BLUFOR_A];
private _clO = [Map_OPFOR_R,Map_OPFOR_G,Map_OPFOR_B,Map_OPFOR_A];
private _clI = [Map_Independent_R,Map_Independent_G,Map_Independent_B,Map_Independent_A];
private _clU = [Map_Unknown_R,Map_Unknown_G,Map_Unknown_B,Map_Unknown_A];


{
	params ["_leaderName", "_codeSign", "_frontVar"];
	private _leader = missionNamespace getVariable [_leaderName, objNull];
	if !(isNull _leader) then {
		private _gp = group _leader;
		GVAR(allLeaders) pushBack _leader;
		GVAR(allHQ) pushBack _gp;
		_gp setVariable [QGVAR(codeSign), _codeSign];
		if !(isNil _frontVar) then {
			_gp setVariable [QEGVAR(common,front), missionNamespace getVariable _frontVar]
		};
	};
} forEach [
	["leaderHQ",  "A", "HET_FA"],
	["leaderHQB", "B", "HET_FB"],
	["leaderHQC", "C", "HET_FC"],
	["leaderHQD", "D", "HET_FD"],
	["leaderHQE", "E", "HET_FE"],
	["leaderHQF", "F", "HET_FF"],
	["leaderHQG", "G", "HET_FG"],
	["leaderHQH", "H", "HET_FH"]
];

[] call FUNC(front);

if (GVAR(timeM)) then
	{
	[([player] + (switchableUnits - [player]))] call EFUNC(common,TimeMachine)
	};

if (EGVAR(missionmodules,active)) then
	{
	// Phase 3 extracted nr6_hal/Boss_fnc.sqf handles into hal_boss PREP'd functions;
	// the legacy preprocessFile loader is removed (file no longer exists).
	RydBBa_InitDone = false;
	RydBBb_InitDone = false;

		{
		if ((count (_x select 0)) > 0) then
			{
			if ((_x select 1) == "A") then {RydBBa_Init = false};
			_BBHQs = _x select 0;
			_BBHQGrps = [];

				{
				_BBHQGrps set [(count _BBHQGrps),(group _x)]
				}
			forEach _BBHQs;

				{
				_x setVariable ["BBProgress",0]
				}
			forEach _BBHQGrps;
			[[_x,_BBHQGrps],EFUNC(hal_boss,boss)] call EFUNC(common,spawn)
			};

		sleep 1;
		}
	forEach [[RydBBa_HQs,"A"],[RydBBb_HQs,"B"]];
	};

if (((EGVAR(common,debug)) or (EGVAR(common,debugB)) or (EGVAR(common,debugC)) or (EGVAR(common,debugD)) or (EGVAR(common,debugE)) or (EGVAR(common,debugF)) or (EGVAR(common,debugG)) or (EGVAR(common,debugH))) and (GVAR(dbgMon))) then {[[],EFUNC(common,DbgMon)] call EFUNC(common,spawn)};

// HQSitRep dynamic dispatch variables (replaces VarInit.sqf Section C conditional
// `compile preprocessFile HAL\HQSitRep*.sqf` assignments). Populated with PREP'd
// function references so the per-HQ foreach loop below can resolve `{letter}_HQSitRep`
// via missionNamespace getVariable exactly as the legacy code did.
A_HQSitRep = EFUNC(core,HQSitRep);
B_HQSitRep = EFUNC(core,HQSitRepB);
C_HQSitRep = EFUNC(core,HQSitRepC);
D_HQSitRep = EFUNC(core,HQSitRepD);
E_HQSitRep = EFUNC(core,HQSitRepE);
F_HQSitRep = EFUNC(core,HQSitRepF);
G_HQSitRep = EFUNC(core,HQSitRepG);
H_HQSitRep = EFUNC(core,HQSitRepH);

{
	params ["_leaderName", "_codeSign"];
	private _leader = missionNamespace getVariable [_leaderName, objNull];
	if !(isNull _leader) then {
		publicVariable _leaderName;
		private _gp = group _leader;
		[[_gp], missionNamespace getVariable (_codeSign + "_HQSitRep")] call EFUNC(common,spawn);
		[[_gp], EFUNC(hal_boss,FBFTLOOP)] call EFUNC(common,spawn);
		[[_gp], EFUNC(hal_boss,SecTasks)] call EFUNC(common,spawn);
		sleep 5;
	};
} forEach [
	["leaderHQ",  "A"],
	["leaderHQB", "B"],
	["leaderHQC", "C"],
	["leaderHQD", "D"],
	["leaderHQE", "E"],
	["leaderHQF", "F"],
	["leaderHQG", "G"],
	["leaderHQH", "H"]
];

if ((count GVAR(groupMarks)) > 0) then
	{
	[GVAR(groupMarks),EFUNC(common,groupMarkerLoop)] call EFUNC(common,spawn)
	};

if (GVAR(actions)) then {
nul = [] execVM  (GVAR(path) + "SquadTaskingNR6.sqf");
};
