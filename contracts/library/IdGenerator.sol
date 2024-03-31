// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

library IdGenerator {
    
    // @notice using the address of the sender and the blockhash to generate
    // a unique identifier for the proposal.
    function generateId(address _sender) internal view returns (bytes32 gId) {
        gId = bytes32(
            keccak256(abi.encodePacked(_sender, blockhash(block.number)))
        );
        return gId;
    }
}