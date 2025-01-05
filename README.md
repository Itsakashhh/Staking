# Staking
StakingContract: Secure and Dynamic Staking Solution
Description:

Introducing the StakingContract, a comprehensive and secure smart contract designed for staking ElevenToken with dynamic reward calculations and robust security features. Here’s a detailed overview:

Token Staking: Enables users to stake ElevenToken and earn rewards based on the duration and amount staked.

Ownership and Control: The contract is Ownable, giving the deployer control, and Pausable, allowing operations to be paused in emergencies.

Staking Mechanics:

Users can stake tokens and earn rewards over time.

Supports secure withdrawals after a lock-in period, with an option for early withdrawal subject to a penalty.

Emergency withdrawal is available for urgent cases, though it forfeits rewards.

Stake Details: Utilizes a struct to maintain stake details, including amount, start time, rewards, and active status.

Reward Parameters:

Base reward rate set at 1.

Lock-in period of 7 days for regular withdrawals.

Early withdrawal penalty set at 10%.

Dynamic Rewards: Calculates rewards dynamically based on staking duration and total staked amount, ensuring fair distribution.

Administrative Functions: Allows the owner to adjust reward rate, lock-in period, and early withdrawal penalty, ensuring adaptability.

Technical Details:

Language: Solidity (version ^0.8.25)

Libraries: OpenZeppelin's Ownable and Pausable contracts for ownership and control mechanisms.

Security: Implements modifiers and checks to ensure active stakes and prevent zero token stakes.

Events:

Staked: Logs staking details including user address, amount, and timestamp.

Withdrawn: Logs withdrawal details including user address, amount, and rewards.

PenaltyApplied: Logs early withdrawal penalties.

EmergencyWithdrawn: Logs emergency withdrawals without rewards.

This smart contract is a demonstration of my skills in Solidity, smart contract security, and token staking mechanisms. It highlights my ability to develop secure, dynamic, and user-friendly decentralized applications.
