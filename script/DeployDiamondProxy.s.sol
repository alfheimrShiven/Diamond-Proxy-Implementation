//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";
import {LibDiamond} from "library/LibDiamond.sol";
import {LibHelper} from "library/utils/LibHelper.sol";
import {StakingToken as DiamondStakingToken} from "src/utils/StakingToken.sol";
import {Deposit as DepositFacet} from "src/Facets/Deposit.sol";
import {Withdraw as WithdrawFacet} from "src/Facets/Withdraw.sol";
import {Staking as StakingFacet} from "src/Facets/Staking.sol";

contract FacetA {
    uint256 public num;

    function setNum(uint256 _num) external {
        num = _num;
    }

    function addNum(uint256 _num) external returns (uint256) {
        num += _num;
        return num;
    }

    function getNum() external view returns (uint256) {
        return num;
    }
}

contract FacetB {
    uint256 public num = 0;

    function addNumDuplicate(uint256 _num) external returns (uint256) {
        num += _num;
        return num;
    }

    function getNumDuplicate() external view returns (uint256) {
        return num;
    }
}

contract DeployDiamondProxy is Script {
    LibDiamond.FacetCut facetCut;
    LibDiamond.FacetCut[] facetCuts;
    address public owner = makeAddr("owner");
    DiamondProxy public diamondProxy;
    FacetA public facetA;
    FacetB public facetB = new FacetB();
    DepositFacet public depositFacet;
    WithdrawFacet public withdrawFacet;

    function run() external returns (DiamondProxy, FacetA, FacetB, address) {
        // preparing the FacetCuts
        // 1. FacetA.sol
        facetA = new FacetA();
        // getting function selectors
        bytes4 setNumFunctionSelector = LibHelper.getFunctionSelector(
            "setNum(uint256)"
        );
        bytes4 getNumFunctionSelector = LibHelper.getFunctionSelector(
            "getNum()"
        );
        // creating facetCut
        facetCut.facetAddress = address(facetA);
        facetCut.functionSelectors = [
            setNumFunctionSelector,
            getNumFunctionSelector
        ];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        // 2. DepositFacet
        depositFacet = new DepositFacet();
        // getting function selectors
        bytes4 depositFunctionSelector = LibHelper.getFunctionSelector(
            "deposit()"
        );
        bytes4 getBalanceFunctionSelector = LibHelper.getFunctionSelector(
            "getBalance()"
        );

        // creating facetCut
        facetCut.facetAddress = address(depositFacet);
        facetCut.functionSelectors = [
            depositFunctionSelector,
            getBalanceFunctionSelector
        ];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        // 3. Withdraw Facet
        withdrawFacet = new WithdrawFacet();
        // getting function selectors
        bytes4 withdrawFunctionSelector = LibHelper.getFunctionSelector(
            "withdraw()"
        );

        // creating facetCut
        facetCut.facetAddress = address(withdrawFacet);
        facetCut.functionSelectors = [withdrawFunctionSelector];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        // 4. Staking Facet
        DiamondStakingToken dsToken = new DiamondStakingToken();
        StakingFacet stakingFacet = new StakingFacet(address(dsToken));

        // initial mint for staking facet to provide rewards to user
        dsToken.mint(address(stakingFacet), 100 ether);

        // getting function selectors
        bytes4 stakeFunctionSelector = LibHelper.getFunctionSelector(
            "stake(uint256 amount)"
        );
        bytes4 unstakeFunctionSelector = LibHelper.getFunctionSelector(
            "unstake()"
        );
        bytes4 rewardFunctionSelector = LibHelper.getFunctionSelector(
            "calculateReward(address)"
        );

        // creating facetCut
        facetCut.facetAddress = address(stakingFacet);
        facetCut.functionSelectors = [
            stakeFunctionSelector,
            unstakeFunctionSelector,
            rewardFunctionSelector
        ];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        // deploying DiamondProxy
        diamondProxy = new DiamondProxy(facetCuts, owner);
        return (diamondProxy, facetA, facetB, owner);
    }
}
