// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library LibHelper {
    function getFunctionSelector(
        string memory functionSignature
    ) public pure returns (bytes4 functionSelector) {
        functionSelector = bytes4(keccak256(bytes(functionSignature)));
    }
}
