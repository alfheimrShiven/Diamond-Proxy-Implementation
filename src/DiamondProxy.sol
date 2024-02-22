// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {LibDiamond} from "library/LibDiamond.sol";

/// @dev The main proxy contract implementing the Diamond Proxy Pattern
contract DiamondProxy is Proxy {
    // Errors //
    error NoFacetFound(bytes4 msgSelector);
    error OwnerCannotCallFacet();

    constructor(LibDiamond.FacetCut[] memory facetCuts, address _owner) {
        LibDiamond._setDiamondProxyOwner(_owner);
        // adding implementation contract/facet details in DiamondProxy storage
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
    function _implementation() internal view override returns (address) {
        // get the function selector
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();

        // find and return the facet (implementation contract)
        address facet = ds.functionSelectorAndFacet[msg.sig];
        if (facet == address(0)) {
            revert NoFacetFound(msg.sig);
        }
        return facet;
    }

    /// @dev Will allow the proxy owner to perform facet actions
    /// @notice Can only be called by the owner. This also prevents
    function performFacetAction(
        LibDiamond.FacetCut[] memory facetCuts
    ) external {
        /// @dev forwarding call to implementation contract when called by non-owner tackling function selector clash.
        if (msg.sender != LibDiamond.getDiamondProxyOwner()) {
            _fallback();
        }

        // TODO: Perform all facet actions: ADD, REPLACE, REMOVE
    }

    /// @dev Following Transparent Proxy Pattern
    fallback() external payable override {
        if (msg.sender == LibDiamond.getDiamondProxyOwner()) {
            revert OwnerCannotCallFacet();
        }
        _fallback();
    }

    receive() external payable {}
}
