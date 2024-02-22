// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DeployDiamondProxy} from "script/DeployDiamondProxy.s.sol";
import {Test} from "forge-std/Test.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";

contract DiamondProxyTest is Test {
    DiamondProxy diamondProxy;

    function setUp() external {
        DeployDiamondProxy deployer = new DeployDiamondProxy();
        diamondProxy = deployer.run();
    }

    function testDeploy() external view {
        assert(address(diamondProxy) != address(0));
    }
}
