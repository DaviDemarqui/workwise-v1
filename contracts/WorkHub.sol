// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IWorkHub} from "contracts/interfaces/IWorkHub.sol";

contract WorkHub is IWorkHub {

    string[] jobCategories;
    string[] availableSkills;
    constructor() {
        
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