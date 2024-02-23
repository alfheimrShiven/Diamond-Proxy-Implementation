// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
        userBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint256) {
        return userBalances[msg.sender];
    }
}
