// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

error NoBytecodeAtFacetContract(address);

library LibHelper {
    function getFunctionSelector(
        string memory functionSignature
    ) public pure returns (bytes4 functionSelector) {
        functionSelector = bytes4(keccak256(bytes(functionSignature)));
    }

    function enforceFacetHasContractCode(address _contract) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert NoBytecodeAtFacetContract(_contract);
        }
    }
}
