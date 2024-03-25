// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {ProposalType} from "contracts/types/Proposal.sol";
import {Proposal} from "contracts/types/Proposal.sol";
import {Member} from "contracts/types/Member.sol";

interface IWGovernance {

    event newMemberJoined (
        address indexed  member
    );

    event memberLeaved (
        address indexed  member
    );

    event proposalCreated (
        address creator
    );

    event proposalVoted (
        address voter,
        bytes32 proposalId
    );

    event proposalAccepted (
        bytes32 proposalId
    );

    event proposalRefused (
        bytes32 proposalId
    );    

    event feeRateChanged (
        uint256 newFee
    );

    event jobCategoryUpdated(
        string newCategory
    );

    event skillsUpdated(
        string newSkill
    );

    // @notice: When the requirements to become a member changes;
    event membershipReqChanged (
        uint256 stakingReq
    );

    error AlreadyJoined();
    error MemberDoestExist();
    error ProposalExistent();
    error AlreadyVoted();
    error InvalidEthAmount();
    error InvalidProposalType();
    error ProposalCreatorCantVote();
    error SenderIsNotAMember();

    function joinGovernance() payable external;

    function leaveGovernance() external;

    function createProposal(ProposalType _proposalType, uint256 _votingPeriod,
        address _memberRem, uint256 _feeUpdate, uint256 _stkUpdate, string memory _categUpdate,
        string memory _skillUpdate) external;

    function voteForProposal(bytes32 _proposalId, bool _vote) external;

    function completeProposal(bytes32 _proposalId) external;

}