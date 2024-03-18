// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

enum ProposalType {
    MemberRem,
    FeeUpdate,
    StkUpdate,
    CategUpdate,
    SkillsUpdate
}

struct Proposal {
    address creator;
    address[] voters; // Also used to count votes;
    ProposalType proposaType;
    uint256 votingPeriod;
    uint256 startingPeriod;
}