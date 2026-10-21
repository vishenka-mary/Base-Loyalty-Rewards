const hre = require("hardhat");
async function main() {
  const LoyaltyFactory = await hre.ethers.getContractFactory("AuraLoyaltyRewards");
  const rewards = await LoyaltyFactory.deploy();
  await rewards.deployed();
  console.log("-> Loyalty Engine initialized at:", rewards.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
