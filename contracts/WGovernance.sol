// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Member} from "contracts/types/Member.sol";
import {Vote} from "contracts/types/Vote.sol";
import {Proposal, ProposalType} from "contracts/types/Proposal.sol";
import {IWGovernance} from "contracts/interfaces/IWGovernance.sol";
import {WorkHub} from "contracts/WorkHub.sol";

contract WGovernance is IWGovernance {

    uint256 public currentFee;
    uint256 public requiredStake;
    uint256 public membersCount;
    uint256 public govReserve;

    WorkHub public workHubContract;
    
    mapping(address => Member) public members;
    mapping(bytes32 => Proposal) public proposals;

    uint256[] votesIds;
    mapping(uint256 => Vote) votes;

    constructor(
        address _workHubContract
    ) payable {
        workHubContract = WorkHub(_workHubContract);
        members[msg.sender] = Member(msg.sender, msg.value);
        membersCount++;
        govReserve = msg.value;
    }

    // @notice this modifier is used to validate if the user
    // already voted to the informed proposal
    modifier validateNewVoter(bytes32 _proposalId) {
        if(hasVoted(msg.sender)) {
            revert AlreadyVoted();
        }
        _;
    }

    function getMember(address member) public view returns (Member memory) {
        return members[member];
    }

    // @inheritdoc: IWGovernance
    function joinGovernance() external payable override {

        if(msg.value < requiredStake || msg.value > requiredStake) {
            // @inheritdoc: IWGovernance
            revert InvalidEthAmount();
        }

        if (msg.sender == members[msg.sender].memberAddress) {
            revert AlreadyJoined();
        }

        govReserve += msg.value;

        members[msg.sender] = Member(msg.sender, msg.value);

        membersCount++;

        // @inheritdoc: IWGovernance
        emit newMemberJoined(msg.sender);
    }

    // @inheritdoc: IWGovernance
    function leaveGovernance() external override {

        if (msg.sender == members[msg.sender].memberAddress) {
            revert MemberDoestExist();
        }

        uint256 amountToTransfer = members[msg.sender].amountStk;
        address removedMemberAddress = members[msg.sender].memberAddress;
        govReserve -= amountToTransfer;

        delete members[msg.sender];
        payable(msg.sender).transfer(amountToTransfer);

        // @inheritdoc: IWGovernance
        emit memberLeaved(removedMemberAddress);
    }

    // @inheritdoc: IWGovernance
    function createProposal(
        ProposalType _proposalType,
        uint256 _votingPeriod,
        address _memberRem,
        uint256 _feeUpdate,
        uint256 _stkUpdate,
        string calldata _categUpdate,
        string calldata _skillUpdate
    ) public override {

        if (_proposalType != ProposalType.MemberRem ||
            _proposalType != ProposalType.FeeUpdate ||
            _proposalType != ProposalType.StkUpdate ||
            _proposalType != ProposalType.CategUpdate ||
            _proposalType != ProposalType.SkillsUpdate 
        ) { revert InvalidProposalType(); }

        Proposal memory newProposal = Proposal({
            id: generatePropId(),
            creator: msg.sender,
            proposaType: _proposalType,
            startingPeriod: block.timestamp,
            endingPeriod: block.timestamp + _votingPeriod,
            numberOfVotes: 0,
            memberRem: _proposalType == ProposalType.MemberRem ? _memberRem : address(0),
            feeUpdate: _proposalType == ProposalType.FeeUpdate ? _feeUpdate : 0,
            stkUpdate:  _proposalType == ProposalType.StkUpdate ? _stkUpdate : 0,
            categUpdate:  _proposalType == ProposalType.CategUpdate ? _categUpdate : "",
            skillUpdate: _proposalType == ProposalType.SkillsUpdate ? _skillUpdate : ""
        });

        proposals[newProposal.id] = newProposal;

        emit proposalCreated(msg.sender);
    }

    // @inheritdoc: IWGovernance
    function voteForProposal(bytes32 _proposalId, bool _vote) external virtual override validateNewVoter(_proposalId) {
        
        if (members[msg.sender].memberAddress == address(0)) {
            revert SenderIsNotAMember();
        }
        if (proposals[_proposalId].creator == msg.sender) {
            revert ProposalCreatorCantVote();
        }
        if (proposals[_proposalId].endingPeriod == block.timestamp) {
            completeProposal(_proposalId); // complete proposal automatically
        }

        uint256 currentId = votesIds.length; 
        votes[currentId++] = Vote({ proposalId: _proposalId,member: msg.sender,vote: _vote});
        votesIds.push(currentId++);

        if (proposals[_proposalId].numberOfVotes == membersCount) {
            completeProposal(_proposalId);
        } else {
            emit proposalVoted(msg.sender, _proposalId);
        }
    }

    // @inheritdoc: IWGovernance
    function completeProposal(bytes32 _proposalId) public virtual override {
        
        uint256 trueVotes = 0;
        uint256 falseVotes = 0;

        // Counting the votes
        for (uint256 i = 0; i < votesIds.length; i++) {
            if (votes[i].vote) {
                trueVotes++;
            } else {
                falseVotes++;
            }
        }

        if (trueVotes > falseVotes) {
            Proposal memory proposal = proposals[_proposalId];
            if (proposal.proposaType == ProposalType.MemberRem) {
                removeMember(proposal.memberRem);
            } else if (proposal.proposaType == ProposalType.FeeUpdate) {
                updateFeeRate(proposal.feeUpdate);
            } else if (proposal.proposaType == ProposalType.StkUpdate) {
                updateStakeReq(proposal.stkUpdate);
            } else if (proposal.proposaType == ProposalType.CategUpdate) {
                updateWorkHubCategory(proposal.categUpdate);
            } else if (proposal.proposaType == ProposalType.SkillsUpdate) {
                updateWorkHubSkill(proposal.skillUpdate);
            }
            delete proposals[_proposalId]; 
            emit proposalAccepted(_proposalId);
        } else {
            delete proposals[_proposalId]; 
            emit proposalRefused(_proposalId); 
        }
    }

    // @inheritdoc: IWGovernance
    function updateFeeRate(uint256 _newFee) internal virtual {
        require(_newFee != 0, "The fee cannot be 0");
        currentFee = _newFee;
    }

    // @inheritdoc: IWGovernance
    function updateStakeReq(uint256 _newStk) internal virtual {
        require(_newStk != 0, "The stake cannot be zero");
        requiredStake = _newStk;
    }

    // @inheritdoc: IWGovernance
    function removeMember(address _member) internal virtual {
        uint256 amountStk = members[_member].amountStk;
        delete members[_member];

        payable(_member).transfer(amountStk);
    }

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

    // @notice this function is used to validate if the voter has already voted
    // for that specific proposal. 
    function hasVoted(address _voter) internal view returns (bool) {

         uint256 newId = votesIds.length;

        if (votes[newId++].member == _voter) {
            return true;
        }
        return false;
    }

    // ----------------------------------------------------------------------

    // @notice these functions below are going to call WorkHub to update the 
    // Skills or Category arrays
    function updateWorkHubCategory(string memory _category) internal {

    }
    function updateWorkHubSkill(string memory _skill) internal {

    }
}