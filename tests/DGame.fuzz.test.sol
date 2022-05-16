// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../src/contracts/DGame.sol";

contract DGameFuzz is DGame {
  uint256 input;
  uint256 anotherInput = 100;

  constructor() DGame("") {}

  function incrementInput(uint256 inputParam) public {
    input = inputParam;
  }

  function setAnotherInput(uint256 anotherInputParam) public {
    anotherInput = anotherInputParam;
  }

  function echidna_inputLessThan10() public view returns (bool) {
    return input * anotherInput != 18;
  }

  function echidna_anotherInputMoreThan80() public view returns (bool) {
    return anotherInput - input < 1000;
  }
}
