// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./Child.sol";

abstract contract EchidnaChild is Child {
  constructor() Child(block.timestamp, "utku") {}

  /**
   Fuzz test for ensuring that the child cannot have a negative age
   */
  function echidna_age_never_negative() public view returns (bool) {
    return getAge() >= 0;
  }
}
