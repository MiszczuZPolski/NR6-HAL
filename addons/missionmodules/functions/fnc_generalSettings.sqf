#include "..\script_component.hpp"
params ["_logic"];


//to be replace with GVAR
RydxHQ_ReconCargo = (_logic getVariable "RydxHQ_ReconCargo");
RydxHQ_SynchroAttack = (_logic getVariable "RydxHQ_SynchroAttack");
RydxHQ_InfoMarkersID = (_logic getVariable "RydxHQ_InfoMarkersID");

GVAR(actions) = (_logic getVariable QGVAR(actions));
GVAR(actionsMenu) = (_logic getVariable QGVAR(actions));
GVAR(taskActions) = (_logic getVariable QGVAR(taskActions));
GVAR(supportActions) = (_logic getVariable QGVAR(supportActions));
GVAR(actionsAceOnly) = (_logic getVariable QGVAR(actionsAceOnly));

RydxHQ_NoRestPlayers = (_logic getVariable "RydxHQ_NoRestPlayers");
RydxHQ_NoCargoPlayers = (_logic getVariable "RydxHQ_NoCargoPlayers");

RydxHQ_AIChatDensity = (_logic getVariable "RydxHQ_AIChatDensity");
RydxHQ_GarrisonV2 = (_logic getVariable "RydxHQ_GarrisonV2");
RydxHQ_NEAware = (_logic getVariable "RydxHQ_NEAware");
GVAR(slingDrop) = (_logic getVariable QGVAR(slingDrop));
GVAR(rHQAutoFill) = (_logic getVariable QGVAR(rHQAutoFill));

GVAR(pathFinding) = (_logic getVariable QGVAR(pathFinding));

RydxHQ_MagicHeal = (_logic getVariable "RydxHQ_MagicHeal");
RydxHQ_MagicRepair = (_logic getVariable "RydxHQ_MagicRepair");
RydxHQ_MagicRearm = (_logic getVariable "RydxHQ_MagicRearm");
RydxHQ_MagicRefuel = (_logic getVariable "RydxHQ_MagicRefuel");
