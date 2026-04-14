#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineCommonColors.inc"
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

// GVAR(path) = "\NR6_HAL\"; removed in Plan 05-04 — nr6_hal/ deleted, path no longer referenced anywhere.

// TaskInitNR6.sqf 72 Action* callbacks are now loaded via hal_tasking addon's CBA preInit path (Phase 3, Plan 05).
// Legacy preprocessFile loaders (HAC_fnc, HAC_fnc2, VarInit, TaskMenu, TaskInitNR6) removed during Phase 3.
// SquadTaskingNR6.sqf loader replaced below with EFUNC(tasking,squadTasking) spawn.

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

if (GVAR(timeM)) then
	{
	[([player] + (switchableUnits - [player]))] call EFUNC(common,TimeMachine)
	};

// Leader-dependent init: wait for at least one leaderHQ* global to be published
// by Leader_Module before building allHQ and spawning commander loops.
// Module activation order is not guaranteed — Core_Module can run before
// Leader_Module sets leaderHQ. Timeout of 30 s guards against missions with
// no Leader_Module at all (allHQ stays empty, no loops spawn, no hang).
[] spawn {
	private _deadline = diag_tickTime + 30;
	waitUntil {
		sleep 0.5;
		diag_tickTime > _deadline ||
		{!isNil "leaderHQ"  && {!isNull (missionNamespace getVariable ["leaderHQ",  objNull])}} ||
		{!isNil "leaderHQB" && {!isNull (missionNamespace getVariable ["leaderHQB", objNull])}} ||
		{!isNil "leaderHQC" && {!isNull (missionNamespace getVariable ["leaderHQC", objNull])}} ||
		{!isNil "leaderHQD" && {!isNull (missionNamespace getVariable ["leaderHQD", objNull])}} ||
		{!isNil "leaderHQE" && {!isNull (missionNamespace getVariable ["leaderHQE", objNull])}} ||
		{!isNil "leaderHQF" && {!isNull (missionNamespace getVariable ["leaderHQF", objNull])}} ||
		{!isNil "leaderHQG" && {!isNull (missionNamespace getVariable ["leaderHQG", objNull])}} ||
		{!isNil "leaderHQH" && {!isNull (missionNamespace getVariable ["leaderHQH", objNull])}}
	};

	{
		_x params ["_leaderName", "_codeSign", "_frontVar"];
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

	// MED-3 race fix: fnc_bbLeader (Big Boss Leader module) sets EGVAR(missionmodules,active)=true.
	// Module activation order is not guaranteed — Core_Module can resolve its leaderHQ waitUntil
	// and reach this check before Big Boss Leader modules have fired. Poll for up to 5 s so that
	// missions with Big Boss placed alongside Core don't silently skip the boss spawn.
	// Missions without Big Boss will have active=false after the timeout and skip correctly.
	if !(EGVAR(missionmodules,active)) then {
		private _bbDeadline = diag_tickTime + 5;
		waitUntil { sleep 0.25; EGVAR(missionmodules,active) || diag_tickTime > _bbDeadline };
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
				[[_x,_BBHQGrps],EFUNC(boss,boss)] call EFUNC(common,spawn)
				};

			sleep 1;
			}
		forEach [[RydBBa_HQs,"A"],[RydBBb_HQs,"B"]];
		};

	if (((EGVAR(common,debug)) or (EGVAR(common,debugB)) or (EGVAR(common,debugC)) or (EGVAR(common,debugD)) or (EGVAR(common,debugE)) or (EGVAR(common,debugF)) or (EGVAR(common,debugG)) or (EGVAR(common,debugH))) and (GVAR(dbgMon))) then {[[],EFUNC(common,DbgMon)] call EFUNC(common,spawn)};

	// A_HQSitRep..H_HQSitRep are assigned in compat_nr6hal/XEH_postInit.sqf (COMPAT-02).
	// That postInit runs before this function is invoked (module activation fires after all
	// CBA postInits complete), so the variables are already set here. Re-assigning them
	// here would trigger "Attempt to override final function" because CBA-compiled functions
	// are final. Single source of truth is compat_nr6hal/XEH_postInit.sqf lines 69-76.

	{
		_x params ["_leaderName", "_codeSign"];
		private _leader = missionNamespace getVariable [_leaderName, objNull];
		if !(isNull _leader) then {
			publicVariable _leaderName;
			private _gp = group _leader;
			[[_gp], missionNamespace getVariable (_codeSign + "_HQSitRep")] call EFUNC(common,spawn);
			[[_gp], EFUNC(boss,FBFTLOOP)] call EFUNC(common,spawn);
			[[_gp], EFUNC(boss,SecTasks)] call EFUNC(common,spawn);
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
	    [[], EFUNC(tasking,squadTasking)] call EFUNC(common,spawn);
	};
};
