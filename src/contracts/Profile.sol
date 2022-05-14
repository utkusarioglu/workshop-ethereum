// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

struct Profile {
  string config;
  uint256 size;
}

contract Profiles {
  mapping(address => Profile) private profiles;

  event NewItem(address owner, string sprite, uint256 size);

  constructor() {
    profiles[address(0)] = Profile(
      "https://ipfs.io/ipfs/QmYV9HA1475SLrPuRbRtYWWiWrwHAisYmKALCUWgR4DRpU",
      64
    );
  }

  /// @dev #1 checks a value that will never be 0
  function getProfile() external view returns (Profile memory) {
    Profile memory profile = profiles[msg.sender];
    if (profile.size == 0) {
      // #1
      return profiles[address(0)];
    }
    return profile;
  }

  function setProfile(string calldata sprite, uint256 size) external {
    require(size > 0, "SIZE_TOO_SMALL");
    profiles[msg.sender] = Profile(sprite, size);
    emit NewItem(msg.sender, sprite, size);
  }

  /// this function is deliberately problematic.
  /// it's intended for testing tools to catch
  function check(uint256 a) external returns (bool) {
    require(a >= 10);
  }
}
