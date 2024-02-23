// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DeployDiamondProxy} from "script/DeployDiamondProxy.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";
import {LibHelper} from "library/utils/LibHelper.sol";
import {LibDiamond} from "library/LibDiamond.sol";

contract DiamondProxyTest is Test {
    // Events //
    event Deposited(address, uint256);
    event WithdrawSuccessful(address, uint256);

    DiamondProxy public diamondProxy;
    address public owner;

    function setUp() external {
        DeployDiamondProxy deployer = new DeployDiamondProxy();
        (diamondProxy, , , owner) = deployer.run();
    }

    function testSetNumberThroughProxy() external {
        // Setting number through proxy contract
        bytes memory setNumTrnx = abi.encodeWithSignature(
            "setNum(uint256)",
            25
        );
        (bool setNumSuccess, ) = address(diamondProxy).call(setNumTrnx);
        // Silencing solc warning
        setNumSuccess = setNumSuccess;

        // Getting number through proxy contract
        bytes memory getNumTrnx = abi.encodeWithSignature("getNum()");
        (bool getNumsuccess, bytes memory numData) = address(diamondProxy).call(
            getNumTrnx
        );
        // Silencing solc warning
        getNumsuccess = getNumsuccess;
        uint256 returnedNum = abi.decode(numData, (uint256));

        assertEq(returnedNum, 25);
    }

    function testDepositAndGetBalanceThroughProxy() external {
        bytes memory depositTxn = abi.encodeWithSignature("deposit()");
        uint256 depositAmt = 2 ether;

        (bool depositSuccess, ) = address(diamondProxy).call{value: depositAmt}(
            depositTxn
        );
        (depositSuccess) = (depositSuccess);

        bytes memory getBalanceTxn = abi.encodeWithSignature("getBalance()");

        (bool balSuccess, bytes memory balReturnData) = address(diamondProxy)
            .call(getBalanceTxn);
        (balSuccess, balReturnData) = (balSuccess, balReturnData);
        uint256 returnedBal = abi.decode(balReturnData, (uint256));

        assertEq(returnedBal, depositAmt);
    }

    function testDepositAndWithdrawThroughProxy() external {
        bytes memory depositTxn = abi.encodeWithSignature("deposit()");
        uint256 depositAmt = 2 ether;

        vm.expectEmit(true, true, false, true);
        emit Deposited(address(this), depositAmt);
        (bool depositSuccess, ) = address(diamondProxy).call{value: depositAmt}(
            depositTxn
        );
        (depositSuccess) = (depositSuccess);

        // withdrawing
        bytes memory withdrawTxn = abi.encodeWithSignature("withdraw()");

        vm.expectEmit(true, true, false, true);
        emit WithdrawSuccessful(address(this), depositAmt);
        (bool withdrawSuccess, ) = address(diamondProxy).call(withdrawTxn);
        withdrawSuccess = withdrawSuccess;

        bytes memory getBalanceTxn = abi.encodeWithSignature("getBalance()");

        (bool balSuccess, bytes memory balReturnData) = address(diamondProxy)
            .call(getBalanceTxn);
        (balSuccess, balReturnData) = (balSuccess, balReturnData);
        uint256 returnedBal = abi.decode(balReturnData, (uint256));

        assertEq(returnedBal, 0);
    }

    /// @dev adding receive() for withdrawal tests
    receive() external payable {}
}
