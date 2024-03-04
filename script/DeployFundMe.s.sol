// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    FundMe fundMe;
    HelperConfig helper;

    function run() external returns (FundMe, HelperConfig) {
        helper = new HelperConfig();
        address priceFeed = helper.activeNetworkConfig();

        vm.startBroadcast();
        fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();

        return (fundMe, helper);
    }
}
