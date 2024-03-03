// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    // Errors
    error FundMe__NotOwner();
    error FundMe__NotEnoughETH();
    // Types
    using PriceConverter for uint256;
    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    // Events

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // Constructor
    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }
    // Receive / Fallback

    // External

    // Public
    function fund() public payable {
        // if msg.value is less than MINIMUM_USD, revert
        if(msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughETH();
        }

        // update s_addressToAmountFunded
        s_addressToAmountFunded[msg.sender] += msg.value;

        // push address to s_funders array
        s_funders.push(msg.sender);
    }

    function withdraw() public {}
}
