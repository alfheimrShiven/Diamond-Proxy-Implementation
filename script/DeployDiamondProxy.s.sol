//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {DiamondProxy} from "src/DiamondProxy.sol";
import {LibDiamond} from "library/LibDiamond.sol";
import {LibHelper} from "library/utils/LibHelper.sol";

contract FacetA {
    uint256 num;

    function setNum(uint256 _num) external {
        num = _num;
    }

    function addNum(uint256 _num) external {
        num += _num;
    }
}

contract DeployDiamondProxy is Script {
    LibDiamond.FacetCut facetCut;
    LibDiamond.FacetCut[] facetCuts;
    address owner = makeAddr("owner");
    DiamondProxy diamondProxy;

    function run() external returns (DiamondProxy) {
        FacetA facetA = new FacetA();
        bytes4 setNumFunctionSelector = LibHelper.getFunctionSelector(
            "setNum(uint256)"
        );

        facetCut.facetAddress = address(facetA);
        facetCut.functionSelectors = [setNumFunctionSelector];
        facetCut.action = LibDiamond.FacetCutAction.ADD;

        facetCuts.push(facetCut);

        diamondProxy = new DiamondProxy(facetCuts, owner);
        return diamondProxy;
    }
}
