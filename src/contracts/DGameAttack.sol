// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./SAttack.sol";

contract DGameAttack is VRFConsumerBaseV2 {
  // TODO set a config for coordinator at:
  // 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
  VRFCoordinatorV2Interface coordinator;
  address s_owner;
  address s_d_game;
  uint256 public s_requestId;
  uint256 public attackRound;

  /// @notice block.number => Attack properties struct
  mapping(uint256 => SAttack[]) attacks;

  /// @notice request id => block.number struct
  mapping(uint256 => uint256) requests;

  /// @notice block.number => number of attacks inside `attacks` mapping
  /// @notice for the block.number
  mapping(uint256 => uint32) attackCounts;

  /// @notice block.number => array of random words
  mapping(uint256 => uint256[]) attackWords;

  bytes32 keyHash =
    0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
  uint64 s_subscriptionId;
  uint32 callbackGasLimit = 1e5;
  uint16 minimumRequestConfirmations = 3;

  event AttackStart(
    address indexed player,
    uint256 indexed weaponId,
    uint8 attackCount
  );

  event AttackEnd(address indexed player, uint256 attackDamage);

  constructor(address _vrfCoordinator, uint64 _subscriptionId)
    VRFConsumerBaseV2(_vrfCoordinator)
  {
    coordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
    s_subscriptionId = _subscriptionId;
    s_owner = msg.sender;
  }

  function attack(
    address _player,
    uint256 _weaponId,
    uint8 _attackCount
  ) public onlyDGame {
    SAttack[] storage list = attacks[block.number];
    list.push(SAttack(_player, _weaponId, _attackCount));
    attackCounts[block.number]++;
    emit AttackStart(_player, _weaponId, _attackCount);
  }

  function requestRandomWords(uint256 _blockNumber) private {
    uint32 numWords = attackCounts[_blockNumber];
    s_requestId = coordinator.requestRandomWords(
      keyHash,
      s_subscriptionId,
      minimumRequestConfirmations,
      callbackGasLimit,
      numWords
    );
    requests[block.number] = s_requestId;
  }

  function fulfillRandomWords(uint256 _requestId, uint256[] memory randomWords)
    internal
    override
  {
    uint256 blockNumber = requests[_requestId];
    attackWords[blockNumber] = randomWords;
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }

  modifier onlyDGame() {
    require(msg.sender == s_d_game);
    _;
  }
}
