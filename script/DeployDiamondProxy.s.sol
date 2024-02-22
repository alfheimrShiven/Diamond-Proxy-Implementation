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

    function addNum(uint256 _num) external {
        num += _num;
    }

    function getNum() external view returns (uint256) {
        return num;
    }
}

contract DeployDiamondProxy is Script {
    LibDiamond.FacetCut facetCut;
    LibDiamond.FacetCut[] facetCuts;
    address owner = makeAddr("owner");
    DiamondProxy diamondProxy;
    FacetA facetA;

    function run() external returns (DiamondProxy, FacetA) {
        // preparing the FacetCut for the FacetA facet
        facetA = new FacetA();
        bytes4 setNumFunctionSelector = LibHelper.getFunctionSelector(
            "setNum(uint256)"
        );
        bytes4 addNumFunctionSelector = LibHelper.getFunctionSelector(
            "addNum(uint256)"
        );
        bytes4 getNumFunctionSelector = LibHelper.getFunctionSelector(
            "getNum()"
        );

        facetCut.facetAddress = address(facetA);
        facetCut.functionSelectors = [
            setNumFunctionSelector,
            addNumFunctionSelector,
            getNumFunctionSelector
        ];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        diamondProxy = new DiamondProxy(facetCuts, owner);
        return (diamondProxy, facetA);
    }
}
