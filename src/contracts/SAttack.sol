// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

/// @notice stores the data required for an attack
struct SAttack {
  address player;
  uint256 weaponId;
  uint8 attackCount;
}
