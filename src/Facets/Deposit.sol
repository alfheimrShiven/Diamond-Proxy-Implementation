// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {LibDiamond} from "../../library/LibDiamond.sol";

contract Deposit {
    // Events //
    event Deposited(address, uint256);

    // States //
    mapping(address => uint256) public userBalances;

    function deposit() external payable {
        require(
            msg.value > 0,
            "DepositContract: Value should be more than zero"
        );
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        ds.userBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        return ds.userBalances[msg.sender];
    }
}
