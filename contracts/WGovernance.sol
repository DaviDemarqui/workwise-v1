// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Member} from "contracts/types/Member.sol";
import {Proposal} from "contracts/types/Proposal.sol";
import {IWGovernance} from "contracts/interfaces/IWGovernance.sol";

contract WGovernance is IWGovernance {

    uint256 currentFee;
    uint256 stakingReq;

    mapping (address => Member) members;
    mapping (address => Proposal) proposals;
    mapping (address => uint256) lastVote;
    mapping (address => uint256) govReserve;
    mapping (address => bool) public isTransferring;

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
    function joinGovernance() payable {
        require(msg.value == stakingReq, "Invalid Ammount");
        require(msg.sender == members[msg.sender].memberAddress, "The address is not from a member");

        Member newMember = Member(msg.sender, msg.value);
        members[msg.sender] = newMember;
    }

    // function leaveGovernance() {
    //     require(msg.sender == members[msg.sender].memberAddress, "The address is not from a member");
    //     require(payable(msg.sender).transfer(members[msg.sender].amountStk), "delete here")

    //     require(members[msg.sender].amountStk >= msg.value, "Insufficient balance");
    //     require(!isTransferring[msg.sender], "Transfer in progress");

    //     isTransferring[msg.sender] = true;

    //     uint256 amountToTransfer = msg.value;
    // }



}