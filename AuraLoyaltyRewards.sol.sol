// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

contract AuraLoyaltyRewards {
    struct Vendor {
        bool isActive;
        string brandName;
    }

    address payable public immutable hubAdmin;
    string public hubDescriptor;
    uint256 public accumulatedFees;
    bool public isHubHalted;

    mapping(address => Vendor) public vendors;
    mapping(address => mapping(address => uint256)) public userPoints; // user -> vendor -> points

    event VendorAdded(address indexed vendor, string brandName);
    event PointsBurned(address indexed user, address indexed vendor, uint256 amount);
    event VendorCanceled(address indexed vendor);
    event TreasuryDeposited(address indexed funder, uint256 amount);
    event ReservesEmptied(address indexed admin, uint256 amount);
    event FeesGathered(address indexed admin, uint256 amount);
    event HubHaltToggled(bool isHalted);
    event PointsIssued(address indexed vendor, address indexed user, uint256 amount);
    event VendorRevoked(address indexed vendor);
    event DescriptorUpdated(string newDescriptor);

    modifier onlyAdmin() {
        require(msg.sender == hubAdmin, "AuraLoyalty: Access denied");
        _;
    }

    modifier whenNotHalted() {
        require(!isHubHalted, "AuraLoyalty: Hub is halted");
        _;
    }

    constructor() {
        hubAdmin = payable(msg.sender);
        hubDescriptor = "Aura Base Loyalty Rewards v1";
        isHubHalted = false;
        vendors[msg.sender] = Vendor(true, "Aura Default Vendor");
    }

    // 1. addParticipatingVendor
    function addParticipatingVendor(address vendorWallet, string calldata brandName) external onlyAdmin {
        require(!vendors[vendorWallet].isActive, "AuraLoyalty: Already active");
        vendors[vendorWallet] = Vendor({
            isActive: true,
            brandName: brandName
        });
        emit VendorAdded(vendorWallet, brandName);
    }

    // 2. burnPointsForReward
    function burnPointsForReward(address vendorWallet, uint256 amount) external whenNotHalted {
        require(amount > 0, "AuraLoyalty: Zero amount");
        require(vendors[vendorWallet].isActive, "AuraLoyalty: Inactive vendor");
        require(userPoints[msg.sender][vendorWallet] >= amount, "AuraLoyalty: Insufficient points");

        userPoints[msg.sender][vendorWallet] -= amount;
        emit PointsBurned(msg.sender, vendorWallet, amount);
    }

    // 3. cancelVendorProgram
    function cancelVendorProgram() external {
        require(vendors[msg.sender].isActive, "AuraLoyalty: Not an active vendor");
        vendors[msg.sender].isActive = false;
        emit VendorCanceled(msg.sender);
    }

    // 4. depositPlatformTreasury
    function depositPlatformTreasury() external payable whenNotHalted {
        require(msg.value > 0, "AuraLoyalty: Zero deposit");
        accumulatedFees += msg.value;
        emit TreasuryDeposited(msg.sender, msg.value);
    }

    // 5. emptyPlatformReserves
    function emptyPlatformReserves() external onlyAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "AuraLoyalty: Zero balance");

        accumulatedFees = 0;
        (bool sent, ) = hubAdmin.call{value: balance}("");
        require(sent, "AuraLoyalty: Sweep failed");

        emit ReservesEmptied(hubAdmin, balance);
    }

    // 6. gatherPlatformFees
    function gatherPlatformFees() external onlyAdmin {
        uint256 amount = accumulatedFees;
        require(amount > 0, "AuraLoyalty: Zero fees");

        accumulatedFees = 0;
        (bool sent, ) = hubAdmin.call{value: amount}("");
        require(sent, "AuraLoyalty: Harvest failed");

        emit FeesGathered(hubAdmin, amount);
    }

    // 7. haltLoyaltyHub
    function haltLoyaltyHub(bool isHalted) external onlyAdmin {
        isHubHalted = isHalted;
        emit HubHaltToggled(isHalted);
    }

    // 8. issueLoyaltyPoints
    function issueLoyaltyPoints(address user, uint256 amount) external whenNotHalted {
        require(vendors[msg.sender].isActive, "AuraLoyalty: Not an active vendor");
        require(amount > 0, "AuraLoyalty: Zero points");
        require(user != address(0), "AuraLoyalty: Zero address");

        userPoints[user][msg.sender] += amount;
        emit PointsIssued(msg.sender, user, amount);
    }

    // 9. revokeVendorStatus
    function revokeVendorStatus(address vendorWallet) external onlyAdmin {
        require(vendors[vendorWallet].isActive, "AuraLoyalty: Inactive vendor");
        require(vendorWallet != msg.sender, "AuraLoyalty: Cannot revoke self");
        vendors[vendorWallet].isActive = false;
        emit VendorRevoked(vendorWallet);
    }

    // 10. updateHubDescriptor
    function updateHubDescriptor(string calldata newDescriptor) external onlyAdmin {
        require(bytes(newDescriptor).length > 0, "AuraLoyalty: Empty string");
        hubDescriptor = newDescriptor;
        emit DescriptorUpdated(newDescriptor);
    }
}