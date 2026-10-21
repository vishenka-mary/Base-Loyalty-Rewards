// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;
interface IAuraLoyaltyRewards {
    function issueLoyaltyPoints(address user, uint256 amount) external;
    function burnPointsForReward(address vendorWallet, uint256 amount) external;
}
