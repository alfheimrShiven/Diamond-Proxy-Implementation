// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DeployDiamondProxy, FacetA, FacetB} from "script/DeployDiamondProxy.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";
import {LibHelper} from "library/utils/LibHelper.sol";
import {LibDiamond} from "library/LibDiamond.sol";

contract DiamondProxyTest is Test {
    // Errors //
    error NoFacetFound(bytes4);

    // Events //
    event Deposited(address, uint256);
    event WithdrawSuccessful(address, uint256);

    DiamondProxy public diamondProxy;
    FacetA public facetA;
    FacetB public facetB;
    address public owner;

    uint256 public constant DEPOSIT_AMT = 2 ether;

    function setUp() external {
        DeployDiamondProxy deployer = new DeployDiamondProxy();
        (diamondProxy, facetA, facetB, owner) = deployer.run();
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

    // Facet Action tests //

    function testAddFacetAction() external {
        bytes4 addNumFunctionSelector = LibHelper.getFunctionSelector(
            "addNum(uint256)"
        );

        vm.startPrank(owner);
        assertEq(diamondProxy.getFacet(addNumFunctionSelector), address(0));

        _performSelectorAddAction();

        assert(diamondProxy.getFacet(addNumFunctionSelector) != address(0));
        vm.stopPrank();
    }

    function testRemoveFacetAction() external {
        bytes4 addNumFunctionSelector = LibHelper.getFunctionSelector(
            "addNum(uint256)"
        );

        vm.startPrank(owner);
        _performSelectorAddAction();

        // removing
        // ADD facetCut to add a new function selector `addNum()`
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = addNumFunctionSelector;

        LibDiamond.FacetCut memory removeFacetCut = LibDiamond.FacetCut({
            facetAddress: address(0),
            functionSelectors: functionSelectors,
            action: LibDiamond.FacetCutAction.REMOVE
        });

        LibDiamond.FacetCut[] memory facetCuts = new LibDiamond.FacetCut[](1);
        facetCuts[0] = removeFacetCut;

        diamondProxy.performFacetAction(facetCuts);

        assert(diamondProxy.getFacet(addNumFunctionSelector) == address(0));
        vm.stopPrank();
    }

    function testReplaceFacetAction() external {
        bytes4 addNumFunctionSelector = LibHelper.getFunctionSelector(
            "addNum(uint256)"
        );

        vm.startPrank(owner);
        _performSelectorAddAction();

        assertEq(
            diamondProxy.getFacet(addNumFunctionSelector),
            address(facetA)
        );

        // replacing
        // ADD facetCut to add a new function selector `addNum()`
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = addNumFunctionSelector;

        LibDiamond.FacetCut memory replaceFacetCut = LibDiamond.FacetCut({
            facetAddress: address(facetB),
            functionSelectors: functionSelectors,
            action: LibDiamond.FacetCutAction.REPLACE
        });

        LibDiamond.FacetCut[] memory facetCuts = new LibDiamond.FacetCut[](1);
        facetCuts[0] = replaceFacetCut;

        diamondProxy.performFacetAction(facetCuts);

        assertEq(
            diamondProxy.getFacet(addNumFunctionSelector),
            address(facetB)
        );
        vm.stopPrank();
    }

    // Helper Functions //
    function _performSelectorAddAction() internal {
        bytes4 addNumFunctionSelector = LibHelper.getFunctionSelector(
            "addNum(uint256)"
        );

        // ADD facetCut to add a new function selector `addNum()`
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = addNumFunctionSelector;

        LibDiamond.FacetCut memory addFacetCut = LibDiamond.FacetCut({
            facetAddress: address(facetA),
            functionSelectors: functionSelectors,
            action: LibDiamond.FacetCutAction.ADD
        });

        LibDiamond.FacetCut[] memory facetCuts = new LibDiamond.FacetCut[](1);
        facetCuts[0] = addFacetCut;

        diamondProxy.performFacetAction(facetCuts);
    }

    // Transaction Through Proxy Tests //
    function testDepositThroughProxy() external {
        bytes memory depositTxn = abi.encodeWithSignature("deposit()");

        vm.expectEmit(true, true, false, true);
        emit Deposited(address(this), DEPOSIT_AMT);
        (bool depositSuccess, ) = address(diamondProxy).call{
            value: DEPOSIT_AMT
        }(depositTxn);
        (depositSuccess) = (depositSuccess);
    }

    function testWithdrawThroughProxy() external {
        bytes memory depositTxn = abi.encodeWithSignature("deposit()");
        (bool depositSuccess, ) = address(diamondProxy).call{
            value: DEPOSIT_AMT
        }(depositTxn);
        (depositSuccess) = (depositSuccess);

        bytes memory withdrawTxn = abi.encodeWithSignature("withdraw()");

        vm.expectEmit(true, true, false, true);
        emit WithdrawSuccessful(address(this), DEPOSIT_AMT);
        (bool withdrawSuccess, ) = address(diamondProxy).call(withdrawTxn);
        withdrawSuccess = withdrawSuccess;
    }

    /// @dev adding receive() for withdrawal tests
    receive() external payable {}
}
