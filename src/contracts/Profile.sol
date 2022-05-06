// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "hardhat/console.sol";

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

  function getProfile() external view returns (Profile memory) {
    Profile memory profile = profiles[msg.sender];
    // checks a value that will never be 0
    if (profile.size == 0) {
      return profiles[address(0)];
    }
    // console.log("sprite: %s by %s", profile.config, msg.sender);
    return profile;
  }

  function setProfile(string calldata sprite, uint256 size) external {
    require(size > 0, "SIZE_TOO_SMALL");
    profiles[msg.sender] = Profile(sprite, size);
    emit NewItem(msg.sender, sprite, size);
  }
}
