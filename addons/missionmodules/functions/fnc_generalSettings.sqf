#include "..\script_component.hpp"
params ["_logic"];


//to be replace with GVAR
EGVAR(core,reconCargo) = (_logic getVariable QEGVAR(core,reconCargo));
EGVAR(core,synchroAttack) = (_logic getVariable QEGVAR(core,synchroAttack));
EGVAR(core,infoMarkersID) = (_logic getVariable QEGVAR(core,infoMarkersID));

GVAR(actions) = (_logic getVariable QGVAR(actions));
GVAR(actionsMenu) = (_logic getVariable QGVAR(actions));
GVAR(taskActions) = (_logic getVariable QGVAR(taskActions));
GVAR(supportActions) = (_logic getVariable QGVAR(supportActions));
GVAR(actionsAceOnly) = (_logic getVariable QGVAR(actionsAceOnly));

EGVAR(core,noRestPlayers) = (_logic getVariable QEGVAR(core,noRestPlayers));
EGVAR(core,noCargoPlayers) = (_logic getVariable QEGVAR(core,noCargoPlayers));

EGVAR(core,aIChatDensity) = (_logic getVariable QEGVAR(core,aIChatDensity));
EGVAR(core,garrisonV2) = (_logic getVariable QEGVAR(core,garrisonV2));
EGVAR(core,nEAware) = (_logic getVariable QEGVAR(core,nEAware));
GVAR(slingDrop) = (_logic getVariable QGVAR(slingDrop));
GVAR(rHQAutoFill) = (_logic getVariable QGVAR(rHQAutoFill));

GVAR(pathFinding) = (_logic getVariable QGVAR(pathFinding));

EGVAR(core,magicHeal) = (_logic getVariable QEGVAR(core,magicHeal));
EGVAR(core,magicRepair) = (_logic getVariable QEGVAR(core,magicRepair));
EGVAR(core,magicRearm) = (_logic getVariable QEGVAR(core,magicRearm));
EGVAR(core,magicRefuel) = (_logic getVariable QEGVAR(core,magicRefuel));
