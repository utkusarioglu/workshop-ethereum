// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkConsumer {
  AggregatorV3Interface internal priceFeed;

  constructor(address _aggregatorV3Interface) {
    priceFeed = AggregatorV3Interface(_aggregatorV3Interface);
  }

  function getLatestPrice() external view returns (int256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return price;
  }
}
