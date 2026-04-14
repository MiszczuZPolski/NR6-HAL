#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:590-669 (RYD_StatusQuo, block S4)

/**
 * @description Publishes ArtyFriendsX/ArtyArtX/ArtyArtGX globals for each named HQ (A through H)
 *              via publicVariable. Enables artillery coordination between HQ instances.
 * @param {Group} _HQ The HQ group
 * @param {Array} _friends Current friendly groups array
 * @param {Array} _Art Current friendly artillery units array
 * @param {Array} _ArtG Current friendly artillery groups array
 * @return {nil}
 */
params ["_HQ", "_friends", "_Art", "_ArtG"];

if not (isNil "LeaderHQ") then {if (_HQ == (group LeaderHQ)) then {
    ArtyFriendsA = _friends;
    ArtyArtA = _Art;
    ArtyArtGA = _ArtG;
    publicVariable "ArtyFriendsA";
    publicVariable "ArtyArtA";
    publicVariable "ArtyArtGA";
    }
};

if not (isNil "LeaderHQB") then {if (_HQ == (group LeaderHQB)) then {
    ArtyFriendsB = _friends;
    ArtyArtB = _Art;
    ArtyArtGB = _ArtG;
    publicVariable "ArtyFriendsB";
    publicVariable "ArtyArtB";
    publicVariable "ArtyArtGB";
    }
};

if not (isNil "LeaderHQC") then {if (_HQ == (group LeaderHQC)) then {
    ArtyFriendsC = _friends;
    ArtyArtC = _Art;
    ArtyArtGC = _ArtG;
    publicVariable "ArtyFriendsC";
    publicVariable "ArtyArtC";
    publicVariable "ArtyArtGC";
    }
};

if not (isNil "LeaderHQD") then {if (_HQ == (group LeaderHQD)) then {
    ArtyFriendsD = _friends;
    ArtyArtD = _Art;
    ArtyArtGD = _ArtG;
    publicVariable "ArtyFriendsD";
    publicVariable "ArtyArtD";
    publicVariable "ArtyArtGD";
    }
};

if not (isNil "LeaderHQE") then {if (_HQ == (group LeaderHQE)) then {
    ArtyFriendsE = _friends;
    ArtyArtE = _Art;
    ArtyArtGE = _ArtG;
    publicVariable "ArtyFriendsE";
    publicVariable "ArtyArtE";
    publicVariable "ArtyArtGE";
    }
};

if not (isNil "LeaderHQF") then {if (_HQ == (group LeaderHQF)) then {
    ArtyFriendsF = _friends;
    ArtyArtF = _Art;
    ArtyArtGF = _ArtG;
    publicVariable "ArtyFriendsF";
    publicVariable "ArtyArtF";
    publicVariable "ArtyArtGF";
    }
};

if not (isNil "LeaderHQG") then {if (_HQ == (group LeaderHQG)) then {
    ArtyFriendsG = _friends;
    ArtyArtG = _Art;
    ArtyArtGG = _ArtG;
    publicVariable "ArtyFriendsG";
    publicVariable "ArtyArtG";
    publicVariable "ArtyArtGG";
    }
};

if not (isNil "LeaderHQH") then {if (_HQ == (group LeaderHQH)) then {
    ArtyFriendsH = _friends;
    ArtyArtH = _Art;
    ArtyArtGH = _ArtG;
    publicVariable "ArtyFriendsH";
    publicVariable "ArtyArtH";
    publicVariable "ArtyArtGH";
    }
};
