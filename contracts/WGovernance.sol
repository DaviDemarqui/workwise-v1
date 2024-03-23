// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Member} from "contracts/types/Member.sol";
import {Vote} from "contracts/types/Vote.sol";
import {Proposal, ProposalType} from "contracts/types/Proposal.sol";
import {IWGovernance} from "contracts/interfaces/IWGovernance.sol";
import {IWorkHub} from "contracts/interfaces/IWorkHub.sol";

contract WGovernance is IWGovernance {

    uint256 currentFee;
    uint256 requiredStake;
    uint256 membersCount;
    uint256 govReserve;

    IWorkHub public iWorkHubContract;
    
    mapping(address => Member) members;
    mapping(bytes32 => Proposal) proposals;

    uint256[] votesIds;
    mapping(uint256 => Vote) votes;

    constructor(
        uint256 _currentFee,
        uint256 _requiredStake,
        uint256 _membersCount,
        uint256 _govReserve,
        address _iWorkHubContract
    ) payable {
        currentFee = _currentFee;
        requiredStake = _requiredStake;
        membersCount = _membersCount;
        govReserve = _govReserve; 
        iWorkHubContract = IWorkHub(_iWorkHubContract);

        members[msg.sender] = Member(msg.sender, msg.value);
    }

    // @param _proposalId inform what proposal we're working
    // with to find it in the mapping.
    // @notice this modifier is used to validate if the user
    // already voted to the informed proposal and if all
    // the members already voted.
    modifier validateNewVoter(bytes32 _proposalId) {

        require(!hasVoted(msg.sender),
        "Already voted to this proposal.");
        require(proposals[_proposalId].numberOfVotes < membersCount,
        "All the members have voted");
        _;
    }

    // @inheritdoc: IWGovernance
    function joinGovernance() external payable override {
        require(msg.value >= requiredStake, "Invalid Ammount");

        if (msg.sender == members[msg.sender].memberAddress) {
            revert AlreadyJoined();
        }

        govReserve += msg.value;

        Member memory newMember = Member(msg.sender, msg.value);
        members[msg.sender] = newMember;

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
    // @param _proposalType chosen by the member to define the type of the proposal
    // @param _votingPeriod used to determinate the period and calculate the endingPeriod
    // @param _memberRem indicate the member that will be removed based on the _votingPeriod
    // @param _feeUpdate indicate the new value for currentFee based on the _votingPeriod
    // @param _stkUpdate indicate the new requiredStake to become a member based on _votingPeriod
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

        Proposal memory newProposal = Proposal({
            id: generatePropId(),
            creator: msg.sender,
            proposaType: _proposalType,
            votingPeriod: _votingPeriod,
            startingPeriod: block.timestamp,
            endingPeriod: block.timestamp + _votingPeriod,
            numberOfVotes: 0,
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
    // @param _proposalId is used to find the Proposal and also validade if
    // the sender already voted to the chosen proposal.
    // @param _vote is used to set the user vote in the Vote struct.
    function voteForProposal(bytes32 _proposalId, bool _vote) external virtual override validateNewVoter(_proposalId) {
        require(
            members[msg.sender].memberAddress != address(0), 
            "Sender is not a Governance member"
        );
        require(
            proposals[_proposalId].creator != msg.sender,
            "The creator of the proposal can't vote"
        );

        Vote memory newVote = Vote({
            proposalId: _proposalId,
            member: msg.sender,
            vote: _vote
        });

        uint256 newId = votesIds.length;
        votes[newId += 1] = newVote;

        votesIds.push(newId++);

        if (proposals[_proposalId].numberOfVotes == membersCount) {
            completeProposal(_proposalId);
        } else {
            emit proposalVoted(msg.sender, _proposalId);
        }
    }

    // @inheritdoc: IWGovernance
    // @param _proposalId is used to get the proposal and deleted after
    // the competion of the process.
    function completeProposal(bytes32 _proposalId) public virtual override {
        
        uint256 trueVotes = 0;
        uint256 falseVotes = 0;

        Proposal memory proposal = proposals[_proposalId];

        for (uint256 i = 0; i < votesIds.length; i++) {
            if (votes[i].vote) {
                trueVotes++;
            } else {
                falseVotes++;
            }
        }

        if (trueVotes > falseVotes) {
             if (proposal.proposaType == ProposalType.MemberRem) {
                removeMember(proposal.memberRem);
            } else if (proposal.proposaType == ProposalType.FeeUpdate) {
                updateFeeRate(proposal.feeUpdate);
            } else if (proposal.proposaType == ProposalType.StkUpdate) {
                updateStakeReq(proposal.stkUpdate);
            } else if (proposal.proposaType == ProposalType.CategUpdate) {
                // TODO - Do the update in the WorkHub.sol
            } else if (proposal.proposaType == ProposalType.SkillsUpdate) {
                // TODO - Do the update in the WorkHub.sol
            }
            emit proposalAccepted(_proposalId);
        } else { emit proposalRefused(_proposalId); }
        
        // deleting the proposal after the completion.
        delete proposals[_proposalId]; 
    }

    // @inheritdoc: IWGovernance
    // @param _newFee will be the current fee rate through jobs payments
    function updateFeeRate(uint256 _newFee) internal virtual {
        require(_newFee != 0, "The fee cannot be 0");
        currentFee = _newFee;
    }

    // @inheritdoc: IWGovernance
    // @param _newStk will be the current staking requirement for a new
    // user entrance to the governance membership.
    function updateStakeReq(uint256 _newStk) internal virtual {
        require(_newStk != 0, "The stake cannot be zero");
        requiredStake = _newStk;
    }

    // @inheritdoc: IWGovernance
    // @param _newCat indicated the new categorie that is about to be created
    function updateJobCategories(
        string memory _newCat
    ) internal virtual {}

    // @inheritdoc: IWGovernance
    // @param _newSkill indicates the skill that is about to be created
    function updateSkills(string memory _newSkill) internal virtual {}

    // @inheritdoc: IWGovernance
    // @param _member indicates the member that is about to be removed from the governance
    function removeMember(address _member) internal virtual {
        uint256 amountStk = members[_member].amountStk;
        delete members[_member];

        payable(_member).transfer(amountStk);
    }

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

    // @notice this function is used to validate if the voter has already voted
    // for that specific proposal. 
    // @param _proposalId will be reponsable to find the Proposal in the mapping.
    // @param _voter is the voter to be validated.
    function hasVoted(address _voter) internal view returns (bool) {

         uint256 newId = votesIds.length;

        if (votes[newId++].member == _voter) {
            return true;
        }
        return false;
    }

    // ----------------------------------------------------------------------

    // The functions below are going to update the arrays of "jobCategories"
    // and "availableSkills" in the WorkHub.sol contract.

    // @param _newJobCategory is the string that will be added to the array
    // of job  category in the WorkHub contract.
    function newWorkHubJob(string memory _newJobCategory) internal {
        iWorkHubContract.addToJobCategory(_newJobCategory);
    }

    function removeWorkHubJob(string memory _jobCategoryToRemove) internal {
        iWorkHubContract.removeFromJobCategory(_jobCategoryToRemove);
    }

    // @param _newSkill will be added to the array of skills in the
    // WorkHub contract.
    function newWorkHubSkill(string memory _newSkill) internal {
        iWorkHubContract.addToSkills(_newSkill);
    }

    function removeWorkHubSkill(string memory _skillToRemove) internal {
        iWorkHubContract.removeFromSkills(_skillToRemove);
    }
}