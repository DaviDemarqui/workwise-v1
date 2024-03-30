// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Vote} from "contracts/types/Vote.sol";

enum ProposalType {
    MemberRem,
    FeeUpdate,
    StkUpdate,
    CategUpdate,
    SkillsUpdate
}

struct Proposal {
    bytes32 id;
    address creator;
    ProposalType proposaType;
    uint256 startingPeriod;
    uint256 endingPeriod;
    uint256 numberOfVotes;
    // Used in proposal
    address memberRem;
    uint256 feeUpdate;
    uint256 stkUpdate;
    string categUpdate;
    string skillUpdate;
}