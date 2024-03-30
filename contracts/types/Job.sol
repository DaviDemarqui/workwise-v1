// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

struct Job {
    bytes32 id;
    address creator;
    string title;
    string description;
    string category;
    address assignedFreelancer;
    uint256 jobValue;
}