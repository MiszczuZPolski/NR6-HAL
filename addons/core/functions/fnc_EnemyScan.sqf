#include "..\script_component.hpp"

/**
 * @description Scans for enemies near friendly groups and adjusts their behavior accordingly
 * @param {Object} HQ The headquarters object that has references to all friendly/enemy groups
 * @return {Nothing} None
 */
params ["_HQ"];

// Cache frequently used variables to avoid repeated lookups
private _friendlyGroups = _HQ getVariable ["RydHQ_Friends", []];
private _enemyGroups = _HQ getVariable ["RydHQ_KnEnemiesG", []];

// Early exit if we have no enemy groups to process - save a lot of processing
if (count _enemyGroups == 0) exitWith {
    {
        _x setVariable ["NearE", 0];
    } forEach _friendlyGroups;
    _HQ setVariable ["RydHQ_ES", true];
};

private _isDebugEnabled = _HQ getVariable ["RydHQ_DebugII", false];
private _airGroups = _HQ getVariable ["RydHQ_AirG", []];
private _chatDensity = missionNamespace getVariable ["RydxHQ_AIChatDensity", 0];
private _isDynFormEnabled = _HQ getVariable ["RydHQ_DynForm", false];
private _excludedGroups = (_HQ getVariable ["RydHQ_NavalG", []]) +
                          (_HQ getVariable ["RydHQ_SupportG", []]) +
                          (_HQ getVariable ["RydHQ_ArtG", []]);
private _NCCargoMinusCrewInf = (_HQ getVariable ["RydHQ_NCCargoG", []]) -
                             ((_HQ getVariable ["RydHQ_NCrewInfG", []]) -
                             (_HQ getVariable ["RydHQ_SupportG", []]));

// Final list of combat units to process
private _combatUnitGroups = _friendlyGroups - (_excludedGroups + _NCCargoMinusCrewInf);
private _combatUnitGroupsMinusAir = _combatUnitGroups - _airGroups;

// Pre-cache enemy group positions to avoid repetitive position calculations
private _enemyPositionsMap = createHashMap;
{
    if (!isNull _x && {alive (leader _x)}) then {
        _enemyPositionsMap set [_x, getPosATL (vehicle (leader _x))];
    };
} forEach _enemyGroups;

// Pre-calculate unit counts for performance
private _groupStrengthMap = createHashMap;
private _groupPositionMap = createHashMap;
{
    if (!isNull _x && {alive (leader _x)}) then {
        _groupStrengthMap set [_x, count (units _x)];
        _groupPositionMap set [_x, getPosATL (vehicle (leader _x))];
    };
} forEach _combatUnitGroups;

// Handle debug marker creation if enabled - only once per mission start
if (_isDebugEnabled) then {
    // Only create debug markers once to reduce overhead
    {
        if (!(_x getVariable ["RydHQ_MarkerES", false])) then {
            private _dangerValue = _x getVariable ["NearE", 0];
            private _marker = [(_groupPositionMap get _x), _x, "markDanger", "ColorGreen",
                            "ICON", "mil_dot", (str _dangerValue), ""] call EFUNC(common,mark);
            _x setVariable ["RydHQ_MarkerES", true];
        };
    } forEach _friendlyGroups;
    
    // Set up continuous debug marker updating only on first cycle
    if ((_HQ getVariable ["RydHQ_Cyclecount", 1]) == 1) then {
        [_HQ] spawn {
            params ["_HQ"];

            private _updateInterval = 10;
            
            while {!isNull _HQ && {!(_HQ getVariable ["RydHQ_KIA", false])}} do {
                private _friendlyGroups = _HQ getVariable ["RydHQ_Friends", []];
                
                {
                    // Skip invalid groups
                    if (isNull _x || {!alive (leader _x)}) then {
                        deleteMarker ("MarkDanger" + (str _x));
                        continue;
                    };
                    
                    // Only update the marker if it exists
                    private _markerName = "MarkDanger" + (str _x);
                    if (getMarkerType _markerName != "") then {
                        private _dangerValue = _x getVariable ["NearE", 0];
                        
                        // Update marker position and color based on danger level
                        _markerName setMarkerPosLocal (getPosATL (vehicle (leader _x)));
                        
                        private _markerColor = switch (true) do {
                            case (_dangerValue > 0.5): {"ColorRed"};
                            case (_dangerValue > 0.1): {"ColorOrange"};
                            default {"ColorGreen"};
                        };
                        
                        _markerName setMarkerColorLocal _markerColor;
                        _markerName setMarkerText (str _dangerValue);
                    };
                } forEach _friendlyGroups;
                
                sleep _updateInterval;
            };
        };
    };
};

// Pre-compute friendly group proximity map to avoid recalculating relationships
private _friendlyProximityMap = createHashMap;
{
    private _group = _x;
    if (!isNull _group && {alive (leader _group)}) then {
        private _nearbyFriendlyStrength = _groupStrengthMap get _group;
        private _groupPos = _groupPositionMap get _group;
        
        // Find nearby friendly groups
        private _nearbyGroups = [];
        {
            if (_x != _group && {!isNull _x} && {alive (leader _x)}) then {
                private _otherPos = _groupPositionMap get _x;
                private _distance = _groupPos distance _otherPos;
                
                if (_distance < 500 && _distance > 0) then {
                    _nearbyFriendlyStrength = _nearbyFriendlyStrength + ((_groupStrengthMap get _x) / (_distance/3));
                    _nearbyGroups pushBack [_x, _distance];
                };
            };
        } forEach _combatUnitGroups;
        
        _friendlyProximityMap set [_group, [_nearbyFriendlyStrength, _nearbyGroups]];
    };
} forEach _combatUnitGroups;

// Process all combat groups
{
    private _group = _x;
    
    // Skip processing if the group is invalid
    if (isNull _group || {!alive (leader _group)}) then {continue};
    
    private _groupPos = _groupPositionMap get _group;
    private _totalFriendlyStrength = (_friendlyProximityMap get _group) select 0;
    
    // Calculate danger value based on enemy proximity and strength
    private _dangerValue = 0;
    {
        private _enemyGroup = _x;
        if (!isNull _enemyGroup && {alive (leader _enemyGroup)}) then {
            private _enemyPos = _enemyPositionsMap get _enemyGroup;
            private _enemyDistance = _groupPos vectorDistance _enemyPos;
            
            if (_enemyDistance < 1000) then {
                private _enemyStrength = _groupStrengthMap getOrDefault [_enemyGroup, count (units _enemyGroup)];
                _dangerValue = _dangerValue + ((_enemyStrength * _enemyStrength / _totalFriendlyStrength) / ((_enemyDistance+1)/3));
            };
        };
    } forEach _enemyGroups;
    
    // Round danger value slightly to reduce state changes
    _dangerValue = (round (_dangerValue * 100)) / 100;
    
    // Store calculated danger value
    _group setVariable ["NearE", _dangerValue];
    
    // Send danger message to AI if appropriate
    private _groupLeader = leader _group;
    if (_dangerValue > 0.15 && {!isPlayer _groupLeader} && {random 100 < _chatDensity}) then {
        [_groupLeader, (missionNamespace getVariable ["RydxHQ_AIC_InDanger", ["SentCombatDanger"]]), "InDanger"] call EFUNC(common,AIChatter);
    };
    
    // Skip formation changes entirely for air units
    if (_isDynFormEnabled && {!(_group in _airGroups)}) then {
        private _formationData = _group getVariable ["FormChanged", nil];
        
        if (_dangerValue > 0.005) then {
            // Save original formation if not already saved
            if (isNil "_formationData") then {
                _group setVariable ["FormChanged", [formation _group, behaviour _groupLeader, speedMode _group]];
                
                // Only set these values if they need to change
                if ((behaviour _groupLeader) in ["CARELESS", "SAFE"]) then {
                    _group setBehaviour "AWARE";
                };
                
                if ((speedMode _group) == "LIMITED") then {
                    _group setSpeedMode "NORMAL";
                };
                
                if ((formation _group) != "WEDGE") then {
                    _group setFormation "WEDGE";
                };
            };
        } else {
            // Restore original formation if danger has passed
            if (!isNil "_formationData") then {
                // Extract all values at once
                _formationData params ["_originalFormation", "_originalBehavior", "_originalSpeed"];
                
                // Only change values that are different
                if ((behaviour _groupLeader) != _originalBehavior) then {
                    _group setBehaviour _originalBehavior;
                };
                
                if ((speedMode _group) != _originalSpeed) then {
                    _group setSpeedMode _originalSpeed;
                };
                
                if ((formation _group) != _originalFormation) then {
                    _group setFormation _originalFormation;
                };
                
                _group setVariable ["FormChanged", nil];
            };
        };
    };
} forEach _combatUnitGroupsMinusAir;

// Mark scan as complete
_HQ setVariable ["RydHQ_ES", true];
