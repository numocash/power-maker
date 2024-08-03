// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

import { ImmutableState } from "./ImmutableState.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";

import { IPair } from "./interfaces/IPair.sol";
import { IPairMintCallback } from "./interfaces/callback/IPairMintCallback.sol";
import { ISwapCallback } from "./interfaces/callback/ISwapCallback.sol";

import { Balance } from "../libraries/Balance.sol";
import { FullMath } from "../libraries/FullMath.sol";
import { SafeCast } from "../libraries/SafeCast.sol";
import { SafeTransferLib } from "../libraries/SafeTransferLib.sol";
import { UD60x18, ud, mul, div, pow, sub } from "@prb/math/src/UD60x18.sol";


abstract contract Pair is ImmutableState, ReentrancyGuard, IPair {
  /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

  event Mint(uint256 amount0In, uint256 amount1In, uint256 liquidity);

  event Burn(uint256 amount0Out, uint256 amount1Out, uint256 liquidity, address indexed to);

  event Swap(uint256 amount0Out, uint256 amount1Out, uint256 amount0In, uint256 amount1In, address indexed to);

  /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

  error InvariantError();

  error InsufficientOutputError();

  /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/

  /// @inheritdoc IPair
  uint120 public override reserve0;

  /// @inheritdoc IPair
  uint120 public override reserve1;

  /// @inheritdoc IPair
  uint256 public override totalLiquidity;


  /*//////////////////////////////////////////////////////////////
                            SWAP FEE STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private constant FEE_DENOMINATOR = 1e6;
    uint256 private constant SWAP_FEE_VALUE = 7500; // 75 bps (3000/1e6)

    /// @inheritdoc IPair
    function swapFee() external pure override returns (uint256) {
        return SWAP_FEE_VALUE;
    }

  /*//////////////////////////////////////////////////////////////
                              PAIR LOGIC
    //////////////////////////////////////////////////////////////*/

  /// checks quartic invariant holds
  /// @param amount0 base token
  /// @param amount1 speculative token
  /// @param liquidity total liquidity 
  function invariant(
    uint256 amount0,
    uint256 amount1,
    uint256 liquidity
  ) public view returns (bool) {
    if (liquidity == 0) return (amount0 == 0 && amount1 == 0);
    require(liquidity > 0, "liquidity must be greater than zero");

    // Convert amounts to UD60x18 types
    UD60x18 udAmount0 = ud(amount0);
    UD60x18 udAmount1 = ud(amount1);
    UD60x18 udLiquidity = ud(liquidity);
    UD60x18 udStrike = ud(strike);

    // Calculate (amount0 / totalLiquidity) and (amount1 / totalLiquidity)
    UD60x18 scale0 = div(udAmount0, udLiquidity);
    UD60x18 scale1 = div(udAmount1, udLiquidity);

    // Convert 2 to UD60x18
    UD60x18 two = ud(2e18);

    if (scale1.unwrap() > mul(two, udStrike).unwrap()) 
    revert InvariantError();

    // Calculate strike^3
    UD60x18 expo4 = ud(3e18);
    UD60x18 strikeTo4 = pow(udStrike, expo4);

    // Calculate (strike^3 - (3/4 * scale1))^(4/3)
    UD60x18 insideTerm = sub(strikeTo4, mul(scale1, div(ud(3e18), ud(4e18))));
    UD60x18 fracExpo = div(ud(4e18), ud(3e18));
    UD60x18 termToExpo = pow(insideTerm, fracExpo);

    return scale0.unwrap() >= termToExpo.unwrap();
  }

  /// @dev assumes liquidity is non-zero
  function mint(uint256 liquidity, bytes calldata data) internal {
    uint120 _reserve0 = reserve0; // SLOAD
    uint120 _reserve1 = reserve1; // SLOAD
    uint256 _totalLiquidity = totalLiquidity; // SLOAD

    uint256 balance0Before = Balance.balance(token0);
    uint256 balance1Before = Balance.balance(token1);
    IPairMintCallback(msg.sender).pairMintCallback(liquidity, data);
    uint256 amount0In = Balance.balance(token0) - balance0Before;
    uint256 amount1In = Balance.balance(token1) - balance1Before;

    if (!invariant(_reserve0 + amount0In, _reserve1 + amount1In, _totalLiquidity + liquidity)) {
      revert InvariantError();
    }

    reserve0 = _reserve0 + SafeCast.toUint120(amount0In); // SSTORE
    reserve1 = _reserve1 + SafeCast.toUint120(amount1In); // SSTORE
    totalLiquidity = _totalLiquidity + liquidity; // SSTORE

    emit Mint(amount0In, amount1In, liquidity);
  }

  /// @dev assumes liquidity is non-zero
  function burn(address to, uint256 liquidity) internal returns (uint256 amount0, uint256 amount1) {
    uint120 _reserve0 = reserve0; // SLOAD
    uint120 _reserve1 = reserve1; // SLOAD
    uint256 _totalLiquidity = totalLiquidity; // SLOAD

    amount0 = FullMath.mulDiv(_reserve0, liquidity, _totalLiquidity);
    amount1 = FullMath.mulDiv(_reserve1, liquidity, _totalLiquidity);
    if (amount0 == 0 && amount1 == 0) revert InsufficientOutputError();

    if (amount0 > 0) SafeTransferLib.safeTransfer(token0, to, amount0);
    if (amount1 > 0) SafeTransferLib.safeTransfer(token1, to, amount1);

    // Extra check of the invariant
    if (!invariant(_reserve0 - amount0, _reserve1 - amount1, _totalLiquidity - liquidity)) revert InvariantError();

    reserve0 = _reserve0 - SafeCast.toUint120(amount0); // SSTORE
    reserve1 = _reserve1 - SafeCast.toUint120(amount1); // SSTORE
    totalLiquidity = _totalLiquidity - liquidity; // SSTORE

    emit Burn(amount0, amount1, liquidity, to);
  }

  /// @inheritdoc IPair
  function swap(address to, uint256 amount0Out, uint256 amount1Out, bytes calldata data) external override nonReentrant {
    if (amount0Out == 0 && amount1Out == 0) revert InsufficientOutputError();

    uint120 _reserve0 = reserve0; // SLOAD
    uint120 _reserve1 = reserve1; // SLOAD

    if (amount0Out > 0) SafeTransferLib.safeTransfer(token0, to, amount0Out);
    if (amount1Out > 0) SafeTransferLib.safeTransfer(token1, to, amount1Out);

    uint256 balance0Before = Balance.balance(token0);
    uint256 balance1Before = Balance.balance(token1);
    ISwapCallback(msg.sender).swapCallback(amount0Out, amount1Out, data);
    uint256 amount0In = Balance.balance(token0) - balance0Before;
    uint256 amount1In = Balance.balance(token1) - balance1Before;

    // Calculate the swap fee amounts
    uint256 fee0 = FullMath.mulDiv(amount0In, SWAP_FEE_VALUE, FEE_DENOMINATOR);
    uint256 fee1 = FullMath.mulDiv(amount1In, SWAP_FEE_VALUE, FEE_DENOMINATOR);

    // Adjust the input amounts by subtracting the swap fees
    amount0In -= fee0;
    amount1In -= fee1;

    if (!invariant(_reserve0 + amount0In - amount0Out, _reserve1 + amount1In - amount1Out, totalLiquidity)) {
      revert InvariantError();
    }

    reserve0 = _reserve0 + SafeCast.toUint120(amount0In) - SafeCast.toUint120(amount0Out); // SSTORE
    reserve1 = _reserve1 + SafeCast.toUint120(amount1In) - SafeCast.toUint120(amount1Out); // SSTORE

    emit Swap(amount0Out, amount1Out, amount0In, amount1In, to);
  }
}
