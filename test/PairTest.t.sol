// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

// import { Test } from "../lib/forge-std/src/Test.sol";
// import { QFMM } from "../src/core/QFMM.sol";
// import { MockERC20 } from "../test/utils/mocks/MockERC20.sol";
// import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";

// contract QFMMInvariantTest is Test {
//     QFMM QFMM;
//     MockERC20 token0;
//     MockERC20 token1;

//     function setUp() public {
//         token0 = new MockERC20("Circle Dollar", "USDC");
//         token1 = new MockERC20("Ether", "ETH");

//         QFMM = new QFMM(address(token0), address(token1));

//         _deposit(address(this), address(this), 1 ether, 8 ether, 1 ether);

//     }


//     function testInvariantHolds() public {
//         uint256 amount0 = 100 ether;
//         uint256 amount1 = 200 ether;
//         uint256 liquidity = 100 ether;

//         assertTrue(QFMM.invariant(
//                                     amount0, 
//                                     amount1, 
//                                     liquidity
//                                 ), "Invariant should hold with valid parameters");
//     }

//     function testInvariantFailsWithZeroLiquidity() public {
//         uint256 amount0 = 100 ether;
//         uint256 amount1 = 200 ether;
//         uint256 liquidity = 0;

//         assertTrue(!QFMM.invariant(
//                                     amount0, 
//                                     amount1, 
//                                     liquidity
//                                 ), "Invariant should fail with zero liquidity");
//     }

//     function testInvariantFailsWithInvalidAmounts() public {
//         uint256 amount0 = 100 ether;
//         uint256 amount1 = 1000 ether; // Invalid amount1
//         uint256 liquidity = 100 ether;

//         assertTrue(!QFMM.invariant(
//                                     amount0, 
//                                     amount1, 
//                                     liquidity
//                                 ), "Invariant should fail with invalid amount1");
//     }

//     function testInvariantEdgeCases() public {
//         uint256 amount0 = 0;
//         uint256 amount1 = 0;
//         uint256 liquidity = 0;

//         assertTrue(QFMM.invariant(
//                                     amount0, 
//                                     amount1, 
//                                     liquidity
//                                 ), "Invariant should hold with zero amounts and zero liquidity");

//         amount0 = 1 ether;
//         amount1 = 1 ether;
//         liquidity = 1 ether;

//         assertTrue(QFMM.invariant(
//                                     amount0, 
//                                     amount1, 
//                                     liquidity
//                                 ), "Invariant should hold with small amounts and liquidity");
//     }
// }
