// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig helper;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helper) = deployer.run();
        // Set balance of address to newBalance
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testPriceFeedSetCorrectly() public {
        address retrievedAddress = address(fundMe.getPriceFeed());
        address expectedPriceFeedAddress = helper.activeNetworkConfig();
        assertEq(retrievedAddress, expectedPriceFeedAddress);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundBalanceUpdated() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amoundFunded = address(fundMe).balance;
        assertEq(amoundFunded, SEND_VALUE);
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 funderAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(funderAmount, SEND_VALUE);
    }

    function testFundUpdatesFundersArray() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdrawFailsIfNotOwner() public {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromOneFunder() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 initialContractBalance = address(fundMe).balance;
        uint256 initialOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 expectedOwnerBalance = initialOwnerBalance +
            initialContractBalance;
        uint256 expectedContractBalance = 0;

        assertEq(expectedOwnerBalance, fundMe.getOwner().balance);
        assertEq(expectedContractBalance, address(fundMe).balance);
    }
}
