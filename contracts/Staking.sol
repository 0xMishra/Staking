//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();
error Staking__IsMoreThanZero();

contract Staking {
  IERC20 public stakingToken;
  IERC20 public rewardToken;

  // Address to how much they staked
  mapping(address => uint256) public stakedbalances;

  // mapping of how much each address has been paid
  mapping(address => uint256) public userRewardPerTokenPaid;

  // mapping of how much reward each address has
  mapping(address => uint256) public rewards;
  // No. of tokens present in the contract
  uint256 public totalTokenSupply;
  uint256 public constant REWARD_RATE = 100;
  uint256 public rewardPerTokenStored;
  uint256 public lastUpdateTime;

  // To update the reward of user everytime they stake
  modifier updateReward(address account) {
    // how much reward per token
    // last timestamp
    // 12 -1, user earned some tokens
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = block.timestamp;
    rewards[account] = totalEarned(account);
    userRewardPerTokenPaid[account] = rewardPerTokenStored;
    _;
  }

  modifier moreThanZero(uint256 amount) {
    if (amount == 0) {
      revert Staking__IsMoreThanZero();
      _;
    }
  }

  function totalEarned(address account) public view returns (uint256) {
    uint256 currentBalance = stakedbalances[account];
    uint256 amountPaid = userRewardPerTokenPaid[account];
    uint256 currentRewardPerToken = rewardPerToken();
    uint256 pastRewards = rewards[account];

    uint256 earned = (currentBalance * (currentRewardPerToken - amountPaid)) /
      1e18 +
      pastRewards;
    return earned;
  }

  // Based on how long its been during this most recent snapshot
  function rewardPerToken() public view returns (uint256) {
    if (totalTokenSupply == 0) {
      return rewardPerTokenStored;
    }
    return
      rewardPerTokenStored +
      (((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) /
        totalTokenSupply);
  }

  constructor(address _stakingToken, address _rewardToken) {
    stakingToken = IERC20(_stakingToken);
    rewardToken = IERC20(_rewardToken);
  }

  function stake(uint256 amount)
    external
    updateReward(msg.sender)
    moreThanZero(amount)
  {
    stakedbalances[msg.sender] = stakedbalances[msg.sender] + amount;
    totalTokenSupply = totalTokenSupply + amount;
    bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
    if (!success) {
      revert Staking__TransferFailed();
    }
  }

  function withdraw(uint256 amount)
    external
    updateReward(msg.sender)
    moreThanZero(amount)
  {
    stakedbalances[msg.sender] = stakedbalances[msg.sender] - amount;
    totalTokenSupply = totalTokenSupply - amount;
    bool success = stakingToken.transfer(msg.sender, amount);
    if (!success) {
      revert Staking__TransferFailed();
    }
  }

  function claimReward() external updateReward(msg.sender) {
    uint256 reward = rewards[msg.sender];
    bool success = rewardToken.transfer(msg.sender, reward);
    if (!success) {
      revert Staking__TransferFailed();
    }
  }
}
