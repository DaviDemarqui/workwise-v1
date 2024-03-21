// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IWorkHub} from "contracts/interfaces/IWorkHub.sol";

contract WorkHub is IWorkHub {

    string[] jobCategories;
    string[] availableSkills;
    constructor() {
        
    }

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

    function removeFromSkills(string memory _skillToDelete) override external {

        uint256 skillIndex = findItemIndex(_skillToDelete, availableSkills);
        availableSkills[skillIndex] = availableSkills[availableSkills.length - 1];
        availableSkills.pop();

        emit skillRemoved();
    }

    function addToJobCategory(string memory _newCategory) override external {
        
        bool isPresent = checkIfPresent(_newCategory, jobCategories);
        if(isPresent) {
            revert JobCategoryAlreadyExists();
        } else {
            jobCategories.push(_newCategory);
        }

        emit jobCategoryAdded();
    }

    function removeFromJobCategory(string memory _jobCatToDelete) override external {
        
        uint256 jobIndex = findItemIndex(_jobCatToDelete, jobCategories);
        jobCategories[jobIndex] = jobCategories[jobCategories.length - 1];
        jobCategories.pop();

        emit jobCategoryRemoved();
    }

    // @param _itemList is the array that we're working with.
    // @param _item represent the item that we're are searching in the
    // array.
    // @notice this function is being used in functions that use arrays
    // to find the index of an item by it's name.
    function findItemIndex(string memory _item, string[] memory _itemList) internal pure returns (uint256) {
        for(uint256 i = 0; i < _itemList.length; i++) {
            if(keccak256(bytes(_itemList[i])) == keccak256(bytes(_item))) {
                return i;
            }
        }
    }

    function checkIfPresent(string memory _item, string[] memory _itemList) internal pure returns (bool) {
        for(uint256 i = 0; i < _itemList.length; i++) {
            if(keccak256(bytes(_itemList[i])) == keccak256(bytes(_item))) {
                return true;
            } else {
                return false;
            }
        }
    }
}