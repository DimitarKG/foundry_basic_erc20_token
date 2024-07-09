// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployMyToken;

    address person = makeAddr("person");
    address person2 = makeAddr("person2");
    address person3 = makeAddr("person3");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployMyToken = new DeployMyToken();
        myToken = deployMyToken.run();

        vm.prank(msg.sender);

        myToken.transfer(person, STARTING_BALANCE);
    }

    function testPersonBalance() public view {
        assertEq(myToken.balanceOf(person), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1000;
        //person approves person2 to send tokeons on his behalf
        vm.prank(person);
        myToken.approve(person2, initialAllowance);

        vm.prank(person2);
        myToken.transferFrom(person, person2, transferAmount);

        assertEq(myToken.balanceOf(person2), transferAmount);
        assertEq(myToken.balanceOf(person), STARTING_BALANCE - transferAmount);
    }

    function testAllowanceDecreasesAfterTransferFrom() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // person approves person2 to send tokens on his behalf
        vm.prank(person);
        myToken.approve(person2, initialAllowance);

        // person2 transfers tokens from person to person2
        vm.prank(person2);
        myToken.transferFrom(person, person2, transferAmount);

        uint256 remainingAllowance = myToken.allowance(person, person2);
        assertEq(remainingAllowance, initialAllowance - transferAmount);
    }

    function testCannotTransferMoreThanAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1500;

        // person approves person2 to send tokens on his behalf
        vm.prank(person);
        myToken.approve(person2, initialAllowance);

        // person2 tries to transfer more tokens than allowed
        vm.prank(person2);
        vm.expectRevert();
        myToken.transferFrom(person, person2, transferAmount);
    }

    function testTransferBetweenAccounts() public {
        uint256 transferAmount = 10 ether;

        // person transfers tokens to person2
        vm.prank(person);
        myToken.transfer(person2, transferAmount);

        assertEq(myToken.balanceOf(person2), transferAmount);
        assertEq(myToken.balanceOf(person), STARTING_BALANCE - transferAmount);
    }

    function testCannotTransferMoreThanBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether;

        // person tries to transfer more tokens than they have
        vm.prank(person);
        vm.expectRevert();
        myToken.transfer(person2, transferAmount);
    }

    function testApproveAndTransferFromMultipleAccounts() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // person approves person2 and person3 to send tokens on his behalf
        vm.prank(person);
        myToken.approve(person2, initialAllowance);
        vm.prank(person);
        myToken.approve(person3, initialAllowance);

        // person2 transfers tokens from person to person2
        vm.prank(person2);
        myToken.transferFrom(person, person2, transferAmount);

        // person3 transfers tokens from person to person3
        vm.prank(person3);
        myToken.transferFrom(person, person3, transferAmount);

        assertEq(myToken.balanceOf(person2), transferAmount);
        assertEq(myToken.balanceOf(person3), transferAmount);
        assertEq(
            myToken.balanceOf(person),
            STARTING_BALANCE - 2 * transferAmount
        );
    }

    function testAllowanceAfterTransferFrom() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // person approves person2 to send tokens on his behalf
        vm.prank(person);
        myToken.approve(person2, initialAllowance);

        // person2 transfers tokens from person to person2
        vm.prank(person2);
        myToken.transferFrom(person, person2, transferAmount);

        // person2 transfers tokens from person to person2 again
        vm.prank(person2);
        myToken.transferFrom(person, person2, transferAmount);

        assertEq(
            myToken.allowance(person, person2),
            initialAllowance - 2 * transferAmount
        );
    }
}
