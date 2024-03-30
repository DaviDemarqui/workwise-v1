// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

//import "forge-std/Test.sol";
import "../lib/forge-std/src/Test.sol";
import {WorkHub} from "../contracts/WorkHub.sol";
import {WGovernance} from "../contracts/WGovernance.sol";
import {IWGovernance} from "../contracts/interfaces/IWGovernance.sol";
import {Member} from "../contracts/types/Member.sol";

contract WGovernanceTest is Test {

    WGovernance wGovernance;
    WorkHub workHub;

    function setUp() public {
        // iWorkHub = new IWorkHub();
        workHub = new WorkHub();
        wGovernance = new WGovernance(address(workHub));
    }

    function testJoinGovernanceInvaidAmount() public {
        uint256 requiredStake = wGovernance.requiredStake();
        uint256 oldBalance = address(wGovernance).balance;

        vm.expectRevert();
        wGovernance.joinGovernance{value: requiredStake - 1 ether}();

        // Check if the balance didn't changed
        assertEq(address(wGovernance).balance, oldBalance);
    }

    function testJoinGovernance() public {
        uint256 requiredStake = wGovernance.requiredStake();
        uint256 oldMemberCound = wGovernance.membersCount();
        uint256 oldBalance = address(wGovernance).balance;

        vm.expectEmit(false, false, false, false, address(wGovernance));
        emit IWGovernance.newMemberJoined(address(this));

        wGovernance.joinGovernance{value: requiredStake}();

        // Assert:  Checking if the balance was correcly updated
        // assertEq(address(wGovernance).balance, oldBalance + requiredStake);
        //assertEq(wGovernance.govReserve, oldBalance + requiredStake);
        // assertEq(wGovernance.govReserve(), address(wGovernance).balance);
        
        // Assert False: Check if the member was created
        // assertFalse(wGovernance.getMember(msg.sender).memberAddress == address(0) &&
        // wGovernance.getMember(msg.sender).amountStk == 0);

        // Assert: The memberCount was updated after the member creation
        // assertEq(wGovernance.membersCount(), oldMemberCound += 1);

    }
}