// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getEthPrice() internal view returns (uint256) {
        // get eth price in USD from chainlink
        // Network: Sepolia 
        // Aggregator: ETH / USD
        // Contract Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // https://docs.chain.link/data-feeds/price-feeds/addresses#Sepolia%20Testnet
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 answer, , ,) = priceFeed.latestRoundData();

        // the answer will be 8 decimals and we need 18 decimals, so multiply 10 more decimals
        return uint256(answer * 10 ** 10);
    }

    function getUsdValueOfEth(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getEthPrice();                               // 10 ** 18 decimals
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10 ** 18);   // ethAmount is 10 ** 18 decimals
        return ethAmountInUsd;                                          // 10 ** 18 decimals
    }
}