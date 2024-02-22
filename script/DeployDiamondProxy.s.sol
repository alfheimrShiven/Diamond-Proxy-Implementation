//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";
import {LibDiamond} from "library/LibDiamond.sol";
import {LibHelper} from "library/utils/LibHelper.sol";

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
    DiamondProxy diamondProxy;
    FacetA facetA;
    FacetB facetB;

    function run() external returns (DiamondProxy, FacetA, FacetB, address) {
        // preparing the FacetCut for the FacetA facet
        facetA = new FacetA();
        facetB = new FacetB();

        bytes4 setNumFunctionSelector = LibHelper.getFunctionSelector(
            "setNum(uint256)"
        );

        bytes4 getNumFunctionSelector = LibHelper.getFunctionSelector(
            "getNum()"
        );

        facetCut.facetAddress = address(facetA);
        facetCut.functionSelectors = [
            setNumFunctionSelector,
            getNumFunctionSelector
        ];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        diamondProxy = new DiamondProxy(facetCuts, owner);
        return (diamondProxy, facetA, facetB, owner);
    }
}
