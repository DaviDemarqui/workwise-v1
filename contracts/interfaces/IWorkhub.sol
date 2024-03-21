// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

interface IWorkHub {

    event newSkillAdded();
    event skillRemoved();
    event jobCategoryAdded();
    event jobCategoryRemoved();

    error SkillAlreadyExists();
    error JobCategoryAlreadyExists();

    function addToSkills(string memory _newSkill) external;
    
    function removeFromSkills(string memory _skillToDelete) external;

    function addToJobCategory(string memory _newCategory) external;

    function removeFromJobCategory(string memory _jobCatToDelete) external;

}