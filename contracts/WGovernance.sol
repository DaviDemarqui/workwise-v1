// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Member} from "contracts/types/Member.sol";
import {Proposal, ProposalType} from "contracts/types/Proposal.sol";
import {IWGovernance} from "contracts/interfaces/IWGovernance.sol";

contract WGovernance is IWGovernance {

    uint256 currentFee;
    uint256 stakingReq;

    mapping (address => Member) members;
    mapping (address => Proposal) proposals;
    mapping (address => uint256) lastVote;
    mapping (address => uint256) govReserve;

    /* 
        What we need in Governance:
        
        * Core Functions
        joinGovernance
        leaveGovernance
        createProposal
        voteForProposal

        * Results of proposals:
        updateFeeRate
        updateJobCategories
        updateSkills

        * Security Measures
        removeInactiveMember
    */

    //@inheritdoc: IWGovernance
    function joinGovernance() external payable {

        require(msg.value == stakingReq, "Invalid Ammount");

        if (msg.sender == members[msg.sender].memberAddress) {
            revert AlreadyJoined();
        }

        Member newMember = Member(msg.sender, msg.value);
        members[msg.sender] = newMember;

        //@inheritdoc: IWGovernance
        emit joinedDao();
    }

    //@inheritdoc: IWGovernance
    function leaveGovernance() external {

        require(members[msg.sender].amountStk > msg.value, "Insufficient balance");

        if (msg.sender == members[msg.sender].memberAddress) {
            revert MemberDoestExist();
        }

        uint256 amountToTransfer = members[msg.sender].amountStk;

        delete members[msg.sender];
        payable(msg.sender).transfer(amountToTransfer);

        //@inheritdoc: IWGovernance
        emit leavedDao();
    }

    /* 
        TODO - Build the logic for the how the conclusion fo the Proposal is goint to work
        ex: how to fill the data accordingly to the ProposalType and validate it;
        Also decide if the member will be able to create more than on proposal;
    */
    function createProposal(ProposalType _proposalType, uint256 _votingPeriod) public {
        require(_votingPeriod > 0, "Voting period must be greater than 0");
        require(
            _proposalType == ProposalType.MemberRem ||
            _proposalType == ProposalType.FeeUpdate ||
            _proposalType == ProposalType.StkUpdate ||
            _proposalType == ProposalType.CategUpdate ||
            _proposalType == ProposalType.SkillsUpdate, 
        "Invalid proposal type");

        uint256 endTime = block.timestamp + _votingPeriod;

        Proposal memory newProposal = Proposal({
            creator: msg.sender,
            voters: [],
            ProposalType: _proposalType,
            votingPeriod: _votingPeriod,
            startTime: block.timestamp
        });

        proposals[msg.sender] = newProposal;
    }



}