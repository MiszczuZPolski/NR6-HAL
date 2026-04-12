#include "..\script_component.hpp"
params ["_logic"];

// Editor module overrides the CBA setting when the attribute is present on
// the logic. When absent, the CBA setting (registered in
// addons/core/initSettings.inc.sqf) is used as the fallback default.

EGVAR(core,reconCargo)     = _logic getVariable [QEGVAR(core,reconCargo),     EGVAR(core,reconCargo)];
EGVAR(core,synchroAttack)  = _logic getVariable [QEGVAR(core,synchroAttack),  EGVAR(core,synchroAttack)];
EGVAR(core,hQChat)         = _logic getVariable [QEGVAR(core,hQChat),         EGVAR(core,hQChat)];
EGVAR(core,aIChatDensity)  = _logic getVariable [QEGVAR(core,aIChatDensity),  EGVAR(core,aIChatDensity)];
EGVAR(core,aIChat_Type)    = _logic getVariable [QEGVAR(core,aIChat_Type),    EGVAR(core,aIChat_Type)];
EGVAR(core,infoMarkersID)  = _logic getVariable [QEGVAR(core,infoMarkersID),  EGVAR(core,infoMarkersID)];

EGVAR(core,actions)        = _logic getVariable [QEGVAR(core,actions),        EGVAR(core,actions)];
EGVAR(core,actionsMenu)    = _logic getVariable [QEGVAR(core,actionsMenu),    EGVAR(core,actionsMenu)];
EGVAR(core,taskActions)    = _logic getVariable [QEGVAR(core,taskActions),    EGVAR(core,taskActions)];
EGVAR(core,supportActions) = _logic getVariable [QEGVAR(core,supportActions), EGVAR(core,supportActions)];
EGVAR(core,actionsAceOnly) = _logic getVariable [QEGVAR(core,actionsAceOnly), EGVAR(core,actionsAceOnly)];

EGVAR(core,noRestPlayers)  = _logic getVariable [QEGVAR(core,noRestPlayers),  EGVAR(core,noRestPlayers)];
EGVAR(core,noCargoPlayers) = _logic getVariable [QEGVAR(core,noCargoPlayers), EGVAR(core,noCargoPlayers)];
EGVAR(core,disembarkRange) = _logic getVariable [QEGVAR(core,disembarkRange), EGVAR(core,disembarkRange)];
EGVAR(core,cargoObjRange)  = _logic getVariable [QEGVAR(core,cargoObjRange),  EGVAR(core,cargoObjRange)];
EGVAR(core,lZ)             = _logic getVariable [QEGVAR(core,lZ),             EGVAR(core,lZ)];
EGVAR(core,garrisonV2)     = _logic getVariable [QEGVAR(core,garrisonV2),     EGVAR(core,garrisonV2)];
EGVAR(core,nEAware)        = _logic getVariable [QEGVAR(core,nEAware),        EGVAR(core,nEAware)];
EGVAR(core,slingDrop)      = _logic getVariable [QEGVAR(core,slingDrop),      EGVAR(core,slingDrop)];
EGVAR(core,rHQAutoFill)    = _logic getVariable [QEGVAR(core,rHQAutoFill),    EGVAR(core,rHQAutoFill)];
EGVAR(core,pathFinding)    = _logic getVariable [QEGVAR(core,pathFinding),    EGVAR(core,pathFinding)];

EGVAR(core,magicHeal)      = _logic getVariable [QEGVAR(core,magicHeal),      EGVAR(core,magicHeal)];
EGVAR(core,magicRepair)    = _logic getVariable [QEGVAR(core,magicRepair),    EGVAR(core,magicRepair)];
EGVAR(core,magicRearm)     = _logic getVariable [QEGVAR(core,magicRearm),     EGVAR(core,magicRearm)];
EGVAR(core,magicRefuel)    = _logic getVariable [QEGVAR(core,magicRefuel),    EGVAR(core,magicRefuel)];
