// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Withdraw {
    // Events //
    event WithdrawSuccessful(address, uint256);

    // Errors //
    error TransferFailed(address, uint256);

    // States //
    mapping(address => uint256) public userBalances;

    function withdraw() external {
        require(
            userBalances[msg.sender] > 0,
            "DepositContract: No funds deposited"
        );
        uint256 userBal = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: userBal}("");
        if (!success) {
            revert TransferFailed(msg.sender, userBal);
        } else {
            emit WithdrawSuccessful(msg.sender, userBal);
        }
    }
}
