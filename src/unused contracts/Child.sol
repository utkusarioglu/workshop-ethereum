// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 Models a child with a name and birthDate
 @dev 
 name of the child can be changed by the owner. 
 birthDate property is set at the constructor and cannot be modified
 */
contract Child is Ownable {
  uint256 private birthDate;
  string private name;

  constructor(uint256 _birthDate, string memory _name) {
    birthDate = _birthDate;
    name = _name;
  }

  /**
   Modifies the name of the child
   Can only be called by the owner (the parent)
   */
  function changeName(string memory _newName) public onlyOwner {
    name = _newName;
  }

  /**
   Returns the age of the child in seconds
   @dev
   The method uses `block.timestamp` to calculate the age. This value 
   does not represent the real time, but rather a time that the miner set.
   Also, note that the time may be off depending on the arrival duration of
   new blocks
   */
  function getAge() public view returns (uint256) {
    return block.timestamp - birthDate;
  }

  /**
   Returns the name of the child
   */
  function getName() public view returns (string memory) {
    return name;
  }
}
