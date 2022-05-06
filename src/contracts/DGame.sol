// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

/// @title dGame
/// @author utkusarioglu
/// @notice This contract manages assets and events of dGame.
/// This is a workshop. This contract is not meant to handle real value.
/// @dev -
contract DGame is ERC1155 {
  uint256 public constant HEALTH = 0;
  uint256 public constant BFG = 1;
  uint256 public constant ROCKET = 2;
  uint256 public constant MACHINE_GUN = 3;
  uint256 public constant HAND_GUN = 4;

  /// @notice Emitted when an attack happens
  /// @dev These events are used for tracking which weapon has been used
  /// This is especially useful if the weapon is supposed to have a limited
  /// firing capability (such as once an hour)
  /// @param player address of the player doing the firing action
  /// @param weaponId token id of the weapon
  /// @param fireCount the number of times the weapon is being fired
  event Attack(
    address indexed player,
    uint256 indexed weaponId,
    uint256 fireCount
  );

  constructor(string memory _uri) ERC1155(_uri) {
    _mint(msg.sender, HEALTH, 10**2, "");
    _mint(msg.sender, BFG, 1, "");
    _mint(msg.sender, ROCKET, 10 * 5, "");
    _mint(msg.sender, MACHINE_GUN, 2**128 - 1, "");
    _mint(msg.sender, HAND_GUN, 2**256 - 1, "");
  }

  /// @notice Registers the use of a certain weapon
  /// @dev -
  /// @param weaponId the weapon's token id
  /// @param fireCount the number of times the weapon is fired
  function attack(uint256 weaponId, uint256 fireCount) external {
    emit Attack(msg.sender, weaponId, fireCount);
  }
}
