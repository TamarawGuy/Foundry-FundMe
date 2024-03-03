// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * @param _priceFeed An instance of the AggregatorV3Interface,
     * the price feed oracle (ETH/USD), which provides the latest
     * round data.
     * @notice _priceFeed.latestRoundData() returns a int256 answer with
     * 8 decimals (if ETH is $2000, it will return 2000,00000000), so
     * we return a uint256 with 18 zeros.
     */
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = _priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    /**
     * @param _priceFeed An instance of the AggregatorV3Interface,
     * the price feed oracle (ETH/USD), which provides the latest
     * round data.
     * @notice if ethPrice is 2000e18, and ethAMount is is 0.5e18, we
     * divide by 1e18, to get 1000e18, which is 1000 USD.
     */
    function getConversionRate(
        uint256 _ethAmount,
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(_priceFeed);
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
