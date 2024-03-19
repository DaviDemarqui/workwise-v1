// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Member} from "contracts/types/Member.sol";
import {Proposal, ProposalType} from "contracts/types/Proposal.sol";
import {IWGovernance} from "contracts/interfaces/IWGovernance.sol";

contract WGovernance is IWGovernance {
    uint256 currentFee;
    uint256 stakingReq;

    mapping(address => Member) members;
    mapping(bytes32 => Proposal) proposals;
    mapping(address => uint256) lastVote;
    mapping(address => uint256) govReserve;

    // @inheritdoc: IWGovernance
    function joinGovernance() external payable override {
        require(msg.value == stakingReq, "Invalid Ammount");

        if (msg.sender == members[msg.sender].memberAddress) {
            revert AlreadyJoined();
        }

        Member memory newMember = Member(msg.sender, msg.value);
        members[msg.sender] = newMember;

        // @inheritdoc: IWGovernance
        emit joinedDao(members[msg.sender]);
    }

    // @inheritdoc: IWGovernance
    function leaveGovernance() external override {
        if (msg.sender == members[msg.sender].memberAddress) {
            revert MemberDoestExist();
        }

        uint256 amountToTransfer = members[msg.sender].amountStk;

        // @inheritdoc: IWGovernance
        emit leavedDao(members[msg.sender]);

        delete members[msg.sender];
        payable(msg.sender).transfer(amountToTransfer);
    }

    // @inheritdoc: IWGovernance
    // @param _proposalType chosen by the member to define the type of the proposal
    // @param _votingPeriod used to determinate the period and calculate the endingPeriod
    // @param _memberRem indicate the member that will be removed based on the _votingPeriod
    // @param _feeUpdate indicate the new value for currentFee based on the _votingPeriod
    // @param _stkUpdate indicate the new stakingReq to become a member based on _votingPeriod
    // @param _categUpdate indicate the category to be added based on _votingPeriod
    // @param _skillUpdate indicate the skil to be added based on _votingPeriod
    function createProposal(
        ProposalType _proposalType,
        uint256 _votingPeriod,
        address _memberRem,
        uint256 _feeUpdate,
        uint256 _stkUpdate,
        string memory _categUpdate,
        string memory _skillUpdate
    ) public override {
        require(_votingPeriod > 0, "Voting period must be greater than 0");
        require(
            _proposalType == ProposalType.MemberRem ||
                _proposalType == ProposalType.FeeUpdate ||
                _proposalType == ProposalType.StkUpdate ||
                _proposalType == ProposalType.CategUpdate ||
                _proposalType == ProposalType.SkillsUpdate,
            "Invalid proposal type"
        );

        // TODO - Find a way to dynamically atribute the value
        // depending on the @param _proposalType;
        address[] memory initialVoters;
        Proposal memory newProposal = Proposal({
            id: generatePropId(),
            creator: msg.sender,
            voters: initialVoters,
            proposaType: _proposalType,
            votingPeriod: _votingPeriod,
            startingPeriod: block.timestamp,
            endingPeriod: block.timestamp + _votingPeriod,
            memberRem: address(0),
            feeUpdate: 0,
            stkUpdate: 0,
            categUpdate: "",
            skillUpdate: ""
        });

        // @notice feeding the Proposal accordingly to the
        // _proposalType chosen.
        if (_proposalType == ProposalType.MemberRem) {
            newProposal.memberRem = _memberRem;
        } else if (_proposalType == ProposalType.FeeUpdate) {
            newProposal.feeUpdate = _feeUpdate;
        } else if (_proposalType == ProposalType.StkUpdate) {
            newProposal.stkUpdate = _stkUpdate;
        } else if (_proposalType == ProposalType.CategUpdate) {
            newProposal.categUpdate = _categUpdate;
        } else if (_proposalType == ProposalType.SkillsUpdate) {
            newProposal.skillUpdate = _skillUpdate;
        }

        proposals[newProposal.id] = newProposal;
    }

    // @inheritdoc: IWGovernance
    function voteForProposal(bytes32 _proposalId) external virtual override {
        require(
            proposals[_proposalId].creator != msg.sender,
            "The creator of the proposal can't vote"
        );
        // TODO - Verify the if the member already voted
        // before continue.
    }

    // @inheritdoc: IWGovernance
    function completeProposal(bytes32 _proposalId) external virtual override {}

    // @inheritdoc: IWGovernance
    // @param _newFee will be the current fee rate through jobs payments
    function updateFeeRate(uint256 _newFee) internal virtual override {}

    // @inheritdoc: IWGovernance
    // @param _newCat indicated the new categorie that is about to be created
    function updateJobCategories(
        string memory _newCat
    ) internal virtual override {}

    // @inheritdoc: IWGovernance
    // @param _newSkill indicates the skill that is about to be created
    function updateSkills(string memory _newSkill) internal virtual override {}

    // @inheritdoc: IWGovernance
    // @param _member indicates the member that is about to be removed from the governance
    function remInactiveMember(address _member) internal virtual override {}

    // @param _member will be used to generate a unique id for the Proposal
    // @notice using the address of the sender and the blockhash to generate
    // a unique identifier for the proposal.
    function generatePropId() internal returns (bytes32 gId) {
        gId = bytes32(
            keccak256(abi.encodePacked(msg.sender, blockhash(block.number)))
        );
        if (proposals[gId].id == gId) {
            generatePropId();
        }
        return gId;
    }

}