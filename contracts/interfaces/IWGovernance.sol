// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Proposal} from "contracts/types/Proposal.sol";
import {Member} from "contracts/types/Member.sol";

contract IWGovernance {

    event joinedDao (
        Member indexed member
    );

    event leavedDao (
        Member indexed member
    );

    event proposalCreated (
        Member indexed creator,
        Proposal proposal
    );

    event proposalVoted (
        Member indexed voter,
        Proposal proposal
    );

    event proposalAccepted (
        Proposal proposal
    );

    event proposalRefused (
        Proposal proposal
    );    

    /* 
        The next events are for proposal results;
    */

    event feeRateChanged (
        uint256 newFee,
        Proposal proposal
    );

    event jobCategoryUpdated(
        string newCategory,
        string[] updatedCatList
    );

    event skillsUpdated(
        string newSkill,
        string[] updateSkillList
    );

    //@notice: When the requirements to become a member changes;
    event membershipReqChanged (
        uint256 stakingReq
    );

    //@notice: if the user is already a member
    error AlreadyJoined();
    //@notice: if the user is not in the member list
    error MemberDoestExist();
    //@notice: if the proposal already exists
    error ProposalExistent();
    //@notice: if the member already voted
    error AlreadyVoted();
    //@notice: if the proposal is already accepted
    error AlreadyAccepted();
    //@notice: if the proposal is aleary refused
    error AlreadyRefused();

    function joinGovernance() external;

    function leaveGovernance() external;

    function createProposal(Proposal _proposal) external;

    function voteForProposal() external;

    function updateFeeRate(uint256 _newFee) internal;

    function updateJobCategories(string memory _newCat) internal;

    function updateSkills(string memory _newSkill) internal;

    function remInactiveMember(address member) internal;

}