// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {LibDiamond} from "library/LibDiamond.sol";

/// @dev The main proxy contract implementing the Diamond Proxy Pattern
contract DiamondProxy is Proxy {
    constructor(LibDiamond.FacetCut[] memory facetCuts, address _owner) {
        LibDiamond._setDiamondProxyOwner(_owner);
        for (uint256 f = 0; f < facetCuts.length; f++) {
            require(
                facetCuts[f].action == LibDiamond.FacetCutAction.ADD,
                "DiamondProxy: Can only add facets while initiliazing proxy"
            );

            LibDiamond._setFunctionSelectorsAndFacet(facetCuts[f]);
        }
    }

    /// @dev Will be called by Proxy:fallback() to get the implementation contract address. This will check for the implementation contract implementing the function signature and return its address.
    /// @return address Address of the implementation contract for the requested function call.
    function _implementation() internal view override returns (address) {}

    receive() external payable {}
}
