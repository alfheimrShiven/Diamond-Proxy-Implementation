// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

contract DiamondProxy is Proxy {
    bytes32 constant DIAMOND_STORAGE_SLOT =
        keccak256("diamond.standard.diamond.storage");

    /// @dev Struct to store mapping of function selectors with respective implementation contract (aka facet), all function selectors and the owner of the proxy contract (assuming owner to be a single entity. Can be replace by more sophisticated entities like DAO to avoid centralisation.
    struct DiamondStorage {
        mapping(bytes4 => address) functionSelectorAndFacet;
        bytes4[] functionSelectors;
        address owner;
    }

    /// @dev Assigns and returns a fixed arbitrary storage slot for the DiamondStorage struct. This is done to avoid storage collisions.
    function _getDiamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 storageSlot = DIAMOND_STORAGE_SLOT; // reference  var for assembly
        assembly {
            ds.slot := storageSlot
        }
    }

    /// @dev Will be called by Proxy:fallback() to get the implementation contract address. This will check for the implementation contract implementing the function signature and return its address.
    /// @return address Address of the implementation contract for the requested function call.
    function _implementation() internal view override returns (address) {}

    receive() external payable {}
}
