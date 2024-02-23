// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Deposit} from "src/Facets/Deposit.sol";
import {LibDiamond} from "../../library/LibDiamond.sol";

contract Withdraw is ReentrancyGuard {
    // Events //
    event WithdrawSuccessful(address, uint256);

    // Errors //
    error TransferFailed(address, uint256);

    function withdraw() external nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();

        require(
            ds.userBalances[msg.sender] > 0,
            "WithdrawContract: No funds deposited"
        );

        uint256 userBal = ds.userBalances[msg.sender];
        ds.userBalances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: userBal}("");
        if (!success) {
            revert TransferFailed(msg.sender, userBal);
        } else {
            emit WithdrawSuccessful(msg.sender, userBal);
        }
    }
}
