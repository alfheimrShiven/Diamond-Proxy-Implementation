// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract Staking {
    using Math for uint256;

    // Errors //
    error StakeAmountIsZero(address);
    error CannotUnStake(address);

    // Events //
    event Staked(address indexed staker, uint256 amount);
    event UnStaked(address indexed staker, uint256 amount);

    address public stakingToken;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public timestamps;

    constructor(address _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 amount) external {
        if (amount <= 0) {
            revert StakeAmountIsZero(msg.sender);
        }

        stakes[msg.sender] += amount;
        timestamps[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
        bool success = IERC20(stakingToken).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(success, "Staking Contract: Staking failed, reverting!");
    }

    /// @notice Calculates reward based on the stake amount and stake time.
    function calculateReward(address user) public view returns (uint256) {
        uint256 stakeAmount = stakes[user];
        uint256 stakeTime = block.timestamp - timestamps[user];

        if (stakeAmount == 0) {
            return 0;
        }

        // 0.01% of the (stake amount * stake time) should be the reward (for simplicity sake)
        uint256 reward = Math.mulDiv(stakeAmount, stakeTime, 10000);
        return reward;
    }

    function unstake() external {
        if (
            block.timestamp < timestamps[msg.sender] + 1 weeks ||
            stakes[msg.sender] == 0
        ) {
            revert CannotUnStake(msg.sender);
        }

        uint256 stakeReward = calculateReward(msg.sender);
        uint256 stakeAmount = stakes[msg.sender];

        stakes[msg.sender] = 0;
        delete timestamps[msg.sender];
        emit UnStaked(msg.sender, stakeAmount);

        bool success = IERC20(stakingToken).transfer(
            msg.sender,
            (stakeAmount + stakeReward)
        );
        require(success, "Staking Contract: Un-staking failed, reverting!");
    }
}
