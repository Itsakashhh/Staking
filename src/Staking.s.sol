// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import { ElevenToken } from "./ElevenToken.s.sol";
import { Ownable } from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { Pausable } from "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract StakingContract is Ownable, Pausable {
    // Token to be staked
    ElevenToken public stakingToken;

    // Struct to hold staking details
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 rewards;
        bool active;
    }

    // Mapping of user address to their stake details
    mapping(address => Stake) public stakes;

    // Total staked amount
    uint256 public totalStaked;

    // Reward rates and parameters
    uint256 public rewardRate = 1; // Base reward rate
    uint256 public lockInPeriod = 7 days; // Lock-in period for staking
    uint256 public earlyWithdrawalPenalty = 10; // Penalty percentage for early withdrawal

    // Events
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 rewards);
    event PenaltyApplied(address indexed user, uint256 penalty);
    event EmergencyWithdrawn(address indexed user, uint256 amount);

    // Constructor
    constructor(ElevenToken _stakingToken) Ownable(msg.sender) {
    stakingToken = _stakingToken;
    }

    // Modifier to check active stake
    modifier hasStake() {
        require(stakes[msg.sender].active, "No active stake found");
        _;
    }

    // Stake tokens
    function stake(uint256 _amount) external whenNotPaused {
        require(_amount > 0, "Cannot stake zero tokens");

        // Transfer tokens to this contract
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        // Update stake details
        Stake storage userStake = stakes[msg.sender];
        userStake.amount += _amount;
        userStake.startTime = block.timestamp;
        userStake.active = true;

        // Update total staked amount
        totalStaked += _amount;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    // Withdraw tokens with rewards
    function withdraw() external hasStake whenNotPaused {
        Stake storage userStake = stakes[msg.sender];
        require(block.timestamp >= userStake.startTime + lockInPeriod, "Cannot withdraw before lock-in period");

        uint256 rewards = calculateRewards(msg.sender);
        uint256 totalAmount = userStake.amount + rewards;

        // Reset stake details
        totalStaked -= userStake.amount;
        delete stakes[msg.sender];

        // Transfer tokens and rewards to the user
        stakingToken.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, userStake.amount, rewards);
    }

    // Early withdrawal with penalty
    function earlyWithdraw() external hasStake whenNotPaused {
        Stake storage userStake = stakes[msg.sender];
        require(block.timestamp < userStake.startTime + lockInPeriod, "Lock-in period over, use regular withdraw");

        uint256 penalty = (userStake.amount * earlyWithdrawalPenalty) / 100;
        uint256 remainingAmount = userStake.amount - penalty;

        // Reset stake details
        totalStaked -= userStake.amount;
        delete stakes[msg.sender];

        // Transfer tokens back to user minus penalty
        stakingToken.transfer(msg.sender, remainingAmount);

        emit PenaltyApplied(msg.sender, penalty);
        emit Withdrawn(msg.sender, remainingAmount, 0);
    }

    // Emergency withdrawal (no rewards)
    function emergencyWithdraw() external hasStake whenNotPaused {
        Stake storage userStake = stakes[msg.sender];

        uint256 stakedAmount = userStake.amount;
        totalStaked -= stakedAmount;
        delete stakes[msg.sender];

        // Transfer staked tokens back to user
        stakingToken.transfer(msg.sender, stakedAmount);

        emit EmergencyWithdrawn(msg.sender, stakedAmount);
    }

    // Calculate rewards dynamically based on stake duration and total staked
    function calculateRewards(address _user) public view returns (uint256) {
        Stake storage userStake = stakes[_user];
        uint256 duration = block.timestamp - userStake.startTime;

        // Rewards increase with duration and are dynamic based on total staked
        return (userStake.amount * rewardRate * duration) / (1 days * (totalStaked + 1));
    }

    // Admin functions
    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardRate = _rate;
    }

    function setLockInPeriod(uint256 _period) external onlyOwner {
        lockInPeriod = _period;
    }

    function setEarlyWithdrawalPenalty(uint256 _penalty) external onlyOwner {
        require(_penalty <= 50, "Penalty too high");
        earlyWithdrawalPenalty = _penalty;
    }

    function pauseStaking() external onlyOwner {
        _pause();
    }

    function unpauseStaking() external onlyOwner {
        _unpause();
    }

    function stopStaking() external onlyOwner {
        rewardRate = 0; // Stops rewards effectively ending staking
        _pause();
    }
}