// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

error FunctionSelectorAlreadyExists(bytes4 existingSelector);

library LibDiamond {
    /// @dev Defines the action to be performed for a particular FacetCut
    // 0: ADD, 1: REPLACE, 2: REMOVE
    enum FacetCutAction {
        ADD,
        REPLACE,
        REMOVE
    }

    /// @dev Struct defining a facet action and its corresponding info
    struct FacetCut {
        address facetAddress;
        bytes4[] functionSelectors;
        FacetCutAction action;
    }

    bytes32 constant DIAMOND_STORAGE_SLOT =
        keccak256("diamond.standard.diamond.storage");

    /// @dev Struct to store mapping of function selectors with respective implementation contract (aka facet), all function selectors and the owner of the proxy contract (assuming owner to be a single entity. Can be replace by more sophisticated entities like DAO to avoid centralisation.
    struct DiamondStorage {
        mapping(bytes4 => address) functionSelectorAndFacet;
        bytes4[] functionSelectors;
        address contractOwner;
    }

    /// @dev Assigns and returns a fixed arbitrary storage slot for the DiamondStorage struct. This is done to avoid storage collisions.
    function getDiamondStorage()
        public
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 storageSlot = DIAMOND_STORAGE_SLOT; // reference  var for assembly
        assembly {
            ds.slot := storageSlot
        }
    }

    /// @dev Setter function for contract owner
    function _setDiamondProxyOwner(address _owner) internal {
        DiamondStorage storage ds = getDiamondStorage();
        ds.contractOwner = _owner;
    }

    /// @dev Getter function for contract owner
    function getDiamondProxyOwner() public view returns (address) {
        DiamondStorage storage ds = getDiamondStorage();
        return ds.contractOwner;
    }

    /// @dev Setter function to store FacetCut info permanently into DiamondProxyStorage
    function _setFunctionSelectorsAndFacet(FacetCut memory facetCut) internal {
        DiamondStorage storage ds = getDiamondStorage();

        for (uint256 s = 0; s < facetCut.functionSelectors.length; s++) {
            bytes4 selector = facetCut.functionSelectors[s];

            /// @dev will prevent function selector collisions
            if (ds.functionSelectorAndFacet[selector] != address(0)) {
                revert FunctionSelectorAlreadyExists(selector);
            }

            ds.functionSelectorAndFacet[selector] = facetCut.facetAddress;

            ds.functionSelectors.push(selector);
        }
    }
}
