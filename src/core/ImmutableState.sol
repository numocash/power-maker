// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import { Factory } from "./Factory.sol";

import { IImmutableState } from "./interfaces/IImmutableState.sol";

abstract contract ImmutableState is IImmutableState {
  /// @inheritdoc IImmutableState
  address public immutable override factory;

  /// @inheritdoc IImmutableState
  address public immutable override token0;

  /// @inheritdoc IImmutableState
  address public immutable override token1;

  /// @inheritdoc IImmutableState
  uint256 public immutable override strike;

  constructor() {
    factory = msg.sender;

    (token0, token1, strike, , ) = Factory(msg.sender).parameters();

  }
}
