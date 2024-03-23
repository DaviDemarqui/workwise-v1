// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

struct Vote {
    bytes32 proposalId;
    address member;
    bool vote;
}