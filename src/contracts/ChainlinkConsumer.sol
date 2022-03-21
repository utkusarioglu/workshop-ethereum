// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkConsumer {
  AggregatorV3Interface internal priceFeed;

  constructor(address _aggregatorV3Interface) {
    priceFeed = AggregatorV3Interface(_aggregatorV3Interface);
  }

  function getLatestPrice() external view returns (int256) {
    (
      uint80 roundId,
      int256 price,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return price;
  }
}
