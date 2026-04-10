#include "..\script_component.hpp"
// Originally from RydHQInit.sqf

params ["_logic", "_units", "_activated"];

if !(isServer) exitWith {};

RydHQ_Wait = _logic getVariable ["RydHQ_Wait", 15];


RydxHQ_ReconCargo = missionNamespace getVariable ["RydxHQ_ReconCargo",true];
publicVariable "RydxHQ_ReconCargo";
RydxHQ_SynchroAttack = missionNamespace getVariable ["RydxHQ_SynchroAttack",false];
publicVariable "RydxHQ_SynchroAttack";
RydxHQ_InfoMarkersID = missionNamespace getVariable ["RydxHQ_InfoMarkersID",true];
publicVariable "RydxHQ_InfoMarkersID";

RydxHQ_Actions = missionNamespace getVariable ["RydxHQ_Actions",true];
publicVariable "RydxHQ_Actions";
RydxHQ_ActionsMenu = missionNamespace getVariable ["RydxHQ_ActionsMenu",true];
publicVariable "RydxHQ_ActionsMenu";

RydxHQ_TaskActions = missionNamespace getVariable ["RydxHQ_TaskActions",false];
publicVariable "RydxHQ_TaskActions";
RydxHQ_SupportActions = missionNamespace getVariable ["RydxHQ_SupportActions",false];
publicVariable "RydxHQ_SupportActions";
RydxHQ_ActionsAceOnly = missionNamespace getVariable ["RydxHQ_ActionsAceOnly",false];
publicVariable "RydxHQ_ActionsAceOnly";

RydxHQ_NoRestPlayers = missionNamespace getVariable ["RydxHQ_NoRestPlayers",true];
publicVariable "RydxHQ_NoRestPlayers";
RydxHQ_NoCargoPlayers = missionNamespace getVariable ["RydxHQ_NoCargoPlayers",true];
publicVariable "RydxHQ_NoCargoPlayers";

RydxHQ_LZ = missionNamespace getVariable ["RydxHQ_LZ",true];
publicVariable "RydxHQ_LZ";

RydART_Safe = missionNamespace getVariable ["RydART_Safe",250];
publicVariable "RydART_Safe";

RydHQ_LZ = RydxHQ_LZ;
RydHQB_LZ = RydxHQ_LZ;
RydHQC_LZ = RydxHQ_LZ;
RydHQD_LZ = RydxHQ_LZ;
RydHQE_LZ = RydxHQ_LZ;
RydHQF_LZ = RydxHQ_LZ;
RydHQG_LZ = RydxHQ_LZ;
RydHQH_LZ = RydxHQ_LZ;

//LZ setting was coded in entire system as Leader specific despite making far more sense as a general setting. Will clean it up eventually.

RydxHQ_HQChat = missionNamespace getVariable ["RydxHQ_HQChat",true];
publicVariable "RydxHQ_HQChat";
RydxHQ_AIChatDensity = missionNamespace getVariable ["RydxHQ_AIChatDensity",100];
publicVariable "RydxHQ_AIChatDensity";
RydxHQ_AIChat_Type = missionNamespace getVariable ["RydxHQ_AIChat_Type",100];
publicVariable "RydxHQ_AIChat_Type";
RydxHQ_GarrisonV2 = missionNamespace getVariable ["RydxHQ_GarrisonV2",true];
publicVariable "RydxHQ_GarrisonV2";
RydxHQ_NEAware = missionNamespace getVariable ["RydxHQ_NEAware",500];
publicVariable "RydxHQ_NEAware";
RydxHQ_SlingDrop = missionNamespace getVariable ["RydxHQ_SlingDrop",false];
publicVariable "RydxHQ_SlingDrop";
RydxHQ_RHQAutoFill = missionNamespace getVariable ["RydxHQ_RHQAutoFill",true];
publicVariable "RydxHQ_RHQAutoFill";

RydxHQ_PathFinding = missionNamespace getVariable ["RydxHQ_PathFinding",0];
publicVariable "RydxHQ_PathFinding";

RydxHQ_MagicHeal = missionNamespace getVariable ["RydxHQ_MagicHeal",false];
publicVariable "RydxHQ_MagicHeal";
RydxHQ_MagicRepair = missionNamespace getVariable ["RydxHQ_MagicRepair",false];
publicVariable "RydxHQ_MagicRepair";
RydxHQ_MagicRearm = missionNamespace getVariable ["RydxHQ_MagicRearm",false];
publicVariable "RydxHQ_MagicRearm";
RydxHQ_MagicRefuel = missionNamespace getVariable ["RydxHQ_MagicRefuel",false];
publicVariable "RydxHQ_MagicRefuel";

RydxHQ_PlayerCargoCheckLoopTime = missionNamespace getVariable ["RydxHQ_PlayerCargoCheckLoopTime",2];
publicVariable "RydxHQ_PlayerCargoCheckLoopTime";

RydxHQ_DisembarkRange = missionNamespace getVariable ["RydxHQ_DisembarkRange",200];
publicVariable "RydxHQ_DisembarkRange";

RydxHQ_CargoObjRange = missionNamespace getVariable ["RydxHQ_CargoObjRange",1500];
publicVariable "RydxHQ_CargoObjRange";

RydxHQ_ReconCargo = missionNamespace getVariable ["RydxHQ_ReconCargo",false];
publicVariable "RydxHQ_ReconCargo";

RYD_WS_ArtyMarks = missionNamespace getVariable ["RYD_WS_ArtyMarks",false];
publicVariable "RYD_WS_ArtyMarks";

RYD_Path = "\NR6_HAL\";

//move this to functions folder

// call compile preprocessFile (RYD_Path + "HAC_fnc.sqf");
// call compile preprocessFile (RYD_Path + "HAC_fnc2.sqf");
// call compile preprocessFile (RYD_Path + "VarInit.sqf");
// call compile preprocessFile (RYD_Path + "TaskMenu.sqf");
// call compile preprocessFile (RYD_Path + "TaskInitNR6.sqf");

//can be replaced with getMarkerType and getMarkerSize
HAL_fnc_getType = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getType.sqf";
HAL_fnc_getSize = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getSize.sqf";

//used to "compile" list of units types usable by AI
if (RydHQ_RHQCheck) then {[] call EFUNC(common,rhqCheck)};

RydxHQ_AllLeaders = [];
RydxHQ_AllHQ = [];

private _clB = [Map_BLUFOR_R,Map_BLUFOR_G,Map_BLUFOR_B,Map_BLUFOR_A];
private _clO = [Map_OPFOR_R,Map_OPFOR_G,Map_OPFOR_B,Map_OPFOR_A];
private _clI = [Map_Independent_R,Map_Independent_G,Map_Independent_B,Map_Independent_A];
private _clU = [Map_Unknown_R,Map_Unknown_G,Map_Unknown_B,Map_Unknown_A];


{
	params ["_leaderName", "_codeSign", "_frontVar"];
	private _leader = missionNamespace getVariable [_leaderName, objNull];
	if !(isNull _leader) then {
		private _gp = group _leader;
		RydxHQ_AllLeaders pushBack _leader;
		RydxHQ_AllHQ pushBack _gp;
		_gp setVariable ["RydHQ_CodeSign", _codeSign];
		if !(isNil _frontVar) then {
			_gp setVariable ["RydHQ_Front", missionNamespace getVariable _frontVar]
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

[] call compile preprocessFile (RYD_Path + "Front.sqf");

if (RydHQ_TimeM) then
	{
	[([player] + (switchableUnits - [player]))] call RYD_TimeMachine
	};

if (RydBB_Active) then
	{
	call compile preprocessFile (RYD_Path + "Boss_fnc.sqf");
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
			[[_x,_BBHQGrps],Boss] call RYD_Spawn
			};

		sleep 1;
		}
	forEach [[RydBBa_HQs,"A"],[RydBBb_HQs,"B"]];
	};

if (((RydHQ_Debug) or (RydHQB_Debug) or (RydHQC_Debug) or (RydHQD_Debug) or (RydHQE_Debug) or (RydHQF_Debug) or (RydHQG_Debug) or (RydHQH_Debug)) and (RydHQ_DbgMon)) then {[[],RYD_DbgMon] call RYD_Spawn};

{
	params ["_leaderName", "_codeSign"];
	private _leader = missionNamespace getVariable [_leaderName, objNull];
	if !(isNull _leader) then {
		publicVariable _leaderName;
		private _gp = group _leader;
		[[_gp], missionNamespace getVariable (_codeSign + "_HQSitRep")] call RYD_Spawn;
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

if ((count RydHQ_GroupMarks) > 0) then
	{
	[RydHQ_GroupMarks,RYD_GroupMarkerLoop] call RYD_Spawn
	};

if (RydxHQ_Actions) then {
nul = [] execVM  (RYD_Path + "SquadTaskingNR6.sqf");
};
