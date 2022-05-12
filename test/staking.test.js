const { expect } = require("chai");
const { ethers } = require("hardhat");
const { moveBlocks } = require("../utils/move-block");
const { moveTime } = require("../utils/move-time");

const SECONDS_IN_A_DAY = 86400;
const SECONDS_IN_A_YEAR = 31449600;
describe("Staking", function () {
  let Staking,
    staking,
    ownerAccount,
    otherAccount,
    RewardToken,
    rewardToken,
    stakeAmount;

  beforeEach(async () => {
    [ownerAccount, otherAccount] = await ethers.getSigners();

    RewardToken = await hre.ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy();
    await rewardToken.deployed();

    Staking = await ethers.getContractFactory("Staking");
    staking = await Staking.deploy(rewardToken.address, rewardToken.address);
    await staking.deployed();
    stakeAmount = ethers.utils.parseEther("10000");
  });

  it("Allows users to stake token and claim rewards", async function () {
    let approveTxn = await rewardToken.approve(staking.address, stakeAmount);
    await approveTxn.wait();
    let stakeTxn = await staking.stake(stakeAmount);
    await stakeTxn.wait();
    const startingEarned = await staking.totalEarned(ownerAccount.address);
    console.log("Starting Earned: ", startingEarned);

    await moveBlocks(1);
    await moveTime(SECONDS_IN_A_YEAR);
    const endingEarned = await staking.totalEarned(ownerAccount.address);
    console.log("Ending Earned: ", endingEarned);
  });
});
