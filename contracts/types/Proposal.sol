// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

struct Proposal {
    address indexed creator;
    address[] voters; // Also used to count votes;
    enum ProposaType {
        MemberRem,
        FeeUpdate,
        StkUpdate,
        CategUpdate,
        SkillsUpdate
    }
    uint256 votingPeriod;
}