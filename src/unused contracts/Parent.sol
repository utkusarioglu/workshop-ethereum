// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./Child.sol";

contract Parent {
  Child private child1;

  constructor() {
    child1 = new Child(block.timestamp, "child1");
  }

  /**
   Returns the reported age of child1
   */
  function getChild1Age() external view returns (uint256) {
    return child1.getAge();
  }

  /**
   Returns the address of the child1 contract
   */
  function getChildAddress() external view returns (address) {
    return address(child1);
  }
}
