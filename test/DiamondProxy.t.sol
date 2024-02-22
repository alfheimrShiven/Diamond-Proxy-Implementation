// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DeployDiamondProxy, FacetA} from "script/DeployDiamondProxy.s.sol";
import {Test} from "forge-std/Test.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";

contract DiamondProxyTest is Test {
    DiamondProxy diamondProxy;
    FacetA facetA;

    function setUp() external {
        DeployDiamondProxy deployer = new DeployDiamondProxy();
        (diamondProxy, facetA) = deployer.run();
    }

    function testDeploy() external view {
        assert(address(diamondProxy) != address(0));
    }

    function testFunctionCallThroughProxy() external {
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
}
