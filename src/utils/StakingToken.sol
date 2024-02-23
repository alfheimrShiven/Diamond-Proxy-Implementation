// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// imports
import {ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice This token is meant to be owned by the Staking contract. This is an ERC20 token which is minted by DeployDiamondProxy.

contract StakingToken is Ownable, ERC20 {
    // errors
    error DiamondStakingToken__NotZeroAddress();
    error DiamondStakingToken__AmountMustBeMoreThanZero();

    constructor() ERC20("DiamondStakingToken", "DST") Ownable(msg.sender) {}

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DiamondStakingToken__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DiamondStakingToken__AmountMustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
