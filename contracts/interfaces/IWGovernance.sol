// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {ProposalType} from "contracts/types/Proposal.sol";
import {Proposal} from "contracts/types/Proposal.sol";
import {Member} from "contracts/types/Member.sol";

interface IWGovernance {

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

    error AlreadyJoined();
    error MemberDoestExist();
    error ProposalExistent();
    error AlreadyVoted();

    function joinGovernance() payable external virtual;

    function leaveGovernance() external virtual;

    function createProposal(ProposalType _proposalType, uint256 _votingPeriod,
        address _memberRem, uint256 _feeUpdate, uint256 _stkUpdate, string memory _categUpdate,
        string memory _skillUpdate) external virtual;

    function voteForProposal(bytes32 _proposalId) external virtual;

    function completeProposal(bytes32 _proposalId) external virtual;

    function updateFeeRate(uint256 _newFee) internal virtual;

    function updateStakeReq(uint256 _newStk) internal virtual;

    function updateJobCategories(string memory _newCat) internal virtual;

    function updateSkills(string memory _newSkill) internal virtual;

    function removeMember(address _member) internal virtual;

}