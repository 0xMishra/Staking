const hre = require("hardhat");

async function main() {
  const RewardToken = await hre.ethers.getContractFactory("RewardToken");
  const rewardToken = await RewardToken.deploy();

  await rewardToken.deployed();

  console.log("Reward Token deployed to: ", rewardToken.address);

  const Staking = await hre.ethers.getContractFactory("Staking");
  const staking = await Staking.deploy(
    rewardToken.address,
    rewardToken.address
  );

  await staking.deployed();
  console.log("Staking deployed to: ", staking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
