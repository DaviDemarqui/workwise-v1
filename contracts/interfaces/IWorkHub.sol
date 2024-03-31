// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Job} from "contracts/types/Job.sol";
import {Freelancer} from "contracts/types/Freelancer.sol";

interface IWorkHub {

    event newSkillAdded();
    event skillRemoved();
    event jobCategoryAdded();
    event jobCategoryRemoved();
    event jobDeleted();
    event jobCompleted();
    event freelancerAssigned(bytes32 _job, address _freelancer);

    error SkillAlreadyExists();
    error SkillNotFound(string _skill);
    error InvalidJobCreation(Job _job);
    error JobCategoryAlreadyExists();
    error JobAlreadyAssignedToFreelancer();
    error NotTheOwnerOfTheJob(address _sender);
    error CannotDeleteWhileWorking();

    function createFreelancer(Freelancer memory _freelancer) external;

    function deleteFreelancer(address _freelancer) external;

    function createJob(Job memory _job) external;

    function deleteJob(bytes32 _jobId) external;

    function completeJob(bytes32 _jobId) external;

    function assignToJob(bytes32 _jobId, address _freelancer) external;

    function addToSkills(string memory _newSkill) external;
    
    function removeFromSkills(string memory _skillToDelete) external;

    function addToJobCategory(string memory _newCategory) external;

    function removeFromJobCategory(string memory _jobCatToDelete) external;

}
