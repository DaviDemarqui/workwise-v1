// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IWorkHub} from "contracts/interfaces/IWorkHub.sol";
import {WGovernance} from "contracts/WGovernance.sol";
import {Freelancer} from "contracts/types/Freelancer.sol";
import {Job} from "contracts/types/Job.sol";

contract WorkHub is IWorkHub {

    address owner;

    WGovernance public wGovernance;

    string[] public jobCategories;
    string[] public availableSkills;

    mapping(bytes32 => Job) public jobs;
    mapping(address => Freelancer) public freelancers;

    constructor(address _owner) {
        owner = _owner;
        wGovernance = new WGovernance(address(this));
    }   

    // @inheritdoc: IWorkHub
    function createFreelancer(Freelancer memory _freelancer) override public {

        // Validating the freelancer skills
        for (uint256 i = 0; i < _freelancer.skills.length; i++) {
            if(checkIfPresent(_freelancer.skills[i], availableSkills) == false) {
                revert SkillNotFound(_freelancer.skills[i]);
            }
        }

        // Validating the jobPoints
        if(_freelancer.jobPoints > 0) {
            _freelancer.jobPoints = 0;
        }

        freelancers[_freelancer.freelancerAddress] = _freelancer;
    }

    // @inheritdoc: IWorkHub
    function deleteFreelancer(address _freelancer) override public {
        // TODO - Before delete it mush check if the freelancer has
        // jobs to complete.
    }

    // @inheritdoc: IWorkHub
    function assignToJob(bytes32 _jobId, address _freelancer) override public {
        
        Job memory job = jobs[_jobId]; 
        if (job.assignedFreelancer == _freelancer) {
            revert JobAlreadyAssignedToFreelancer();
        }

        job.assignedFreelancer = _freelancer;
        jobs[_jobId] = job;

        emit freelancerAssigned(_jobId, _freelancer);
    }

    // @inheritdoc: IWorkHub
    function createJob(Job memory _job) override public {

        if (_job.jobValue == 0 || _job.completed == false) {
            revert InvalidJobCreation(_job);
        }

        // TODO - Buid a library to generate ids;
    }

    // @inheritdoc: IWorkHub
    function deleteJob(bytes32 _jobId) override public {
        // Checking if the job is assigned to a freelancer and competed
        // before deleting.
        if (jobs[_jobId].assignedFreelancer != address(0) && 
            jobs[_jobId].completed == false) {
            revert CannotDeleteWhileWorking();
        } 

        delete jobs[_jobId];
        emit jobDeleted();
    }

    // @inheritdoc: IWorkHub
    function completeJob(bytes32 _jobId) override public {

    }


    //------------------------------------------------------------------
    // @notice The functions below work with the WGovernance.sol contract
    // to update the arrays "jobCategories" and "availableSkills".
    // -----------------------------------------------------------------

    // @inheritdoc: IWorkHub
    function addToSkills(string memory _newSkill) override external {

        bool isPresent = checkIfPresent(_newSkill, availableSkills); 
        if(isPresent) {
            revert SkillAlreadyExists();
        } else {
            availableSkills.push(_newSkill);
        }

        emit newSkillAdded();
    }

    // @inheritdoc: IWorkHub
    function removeFromSkills(string memory _skillToDelete) override external {

        uint256 skillIndex = findItemIndex(_skillToDelete, availableSkills);
        availableSkills[skillIndex] = availableSkills[availableSkills.length - 1];
        availableSkills.pop();

        emit skillRemoved();
    }

    // @inheritdoc: IWorkHub
    function addToJobCategory(string memory _newCategory) override external {
        
        bool isPresent = checkIfPresent(_newCategory, jobCategories);
        if(isPresent) {
            revert JobCategoryAlreadyExists();
        } else {
            jobCategories.push(_newCategory);
        }

        emit jobCategoryAdded();
    }

    // @inheritdoc: IWorkHub
    function removeFromJobCategory(string memory _jobCatToDelete) override external {
        
        uint256 jobIndex = findItemIndex(_jobCatToDelete, jobCategories);
        jobCategories[jobIndex] = jobCategories[jobCategories.length - 1];
        jobCategories.pop();

        emit jobCategoryRemoved();
    }

    //------------------------------------------------------------------
    // @notice The functions below work are functions that are being 
    // used to help functions above with it's specific needs.
    // -----------------------------------------------------------------

    // @notice this function is being used in functions need to find
    // the index of an item by the "_item" string parameter.
    function findItemIndex(string memory _item, string[] memory _itemList) internal pure returns (uint256 index) {
        for(uint256 i = 0; i < _itemList.length; i++) {
            if(keccak256(bytes(_itemList[i])) == keccak256(bytes(_item))) {
                index = i;
                break;
            }
        }
        
        return index;
    }

    // @notice This funcion is very similar to the above, but as the
    // name suggests its used to check if an "_item" is present in the
    // "_itemList" parameter array.
    function checkIfPresent(string memory _item, string[] memory _itemList) internal pure returns (bool isPresent) {
        for(uint256 i = 0; i < _itemList.length; i++) {
            if(keccak256(bytes(_itemList[i])) == keccak256(bytes(_item))) {
                isPresent = true;
                break;
            } else {
                isPresent = false;
                break;
            }
        }

        return isPresent;
    }
}