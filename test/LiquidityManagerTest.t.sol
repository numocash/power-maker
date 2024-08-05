// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

// import { LiquidityManager } from "../src/periphery/LiquidityManager.sol";

// import { TestHelper } from "./utils/TestHelper.sol";

// contract LiquidityManagerTest is TestHelper {
//   event AddLiquidity(
//     address indexed from,
//     address indexed lendgine,
//     uint256 liquidity,
//     uint256 size,
//     uint256 amount0,
//     uint256 amount1,
//     address indexed to
//   );

//   event RemoveLiquidity(
//     address indexed from,
//     address indexed lendgine,
//     uint256 liquidity,
//     uint256 size,
//     uint256 amount0,
//     uint256 amount1,
//     address indexed to
//   );

//   event Collect(address indexed from, address indexed lendgine, uint256 amount, address indexed to);

//   LiquidityManager public liquidityManager;

//   function setUp() external {
//     _setUp();
//     liquidityManager = new LiquidityManager(address(factory), address(0));
//   }

//   function _addLiquidity(address to, address from, uint256 amount0, uint256 amount1, uint256 liquidity) internal {
//     token0.mint(from, amount0);
//     token1.mint(from, amount1);

//     if (from != address(this)) {
//       vm.startPrank(from);
//       token0.approve(address(liquidityManager), amount0);
//       token1.approve(address(liquidityManager), amount1);
//       vm.stopPrank();
//     } else {
//       token0.approve(address(liquidityManager), amount0);
//       token1.approve(address(liquidityManager), amount1);
//     }

//     if (from != address(this)) vm.prank(from);
//     liquidityManager.addLiquidity(
//       LiquidityManager.AddLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         liquidity: liquidity,
//         amount0Min: amount0,
//         amount1Min: amount1,
//         sizeMin: 0,
//         recipient: to,
//         deadline: block.timestamp
//       })
//     );
//   }

//   function testAddPositionEmpty() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 1 ether);
//     assertEq(lendgine.totalPositionSize(), 1 ether);
//     assertEq(lendgine.reserve0(), 1 ether);
//     assertEq(lendgine.reserve1(), 8 ether);

//     // test lendgine position
//     (uint256 positionSize,,) = lendgine.positions(address(liquidityManager));
//     assertEq(1 ether, positionSize);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize,,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(1 ether, positionSize);
//   }

//   function testAddPosition() external {
//     _deposit(address(this), address(this), 1 ether, 8 ether, 1 ether);

//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 2 ether);
//     assertEq(lendgine.totalPositionSize(), 2 ether);
//     assertEq(lendgine.reserve0(), 2 ether);
//     assertEq(lendgine.reserve1(), 16 ether);

//     // test lendgine position
//     (uint256 positionSize,,) = lendgine.positions(address(liquidityManager));
//     assertEq(1 ether, positionSize);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize,,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(1 ether, positionSize);
//   }

//   function testDeadline() external {
//     vm.warp(2);

//     vm.expectRevert(LiquidityManager.LivelinessError.selector);
//     liquidityManager.addLiquidity(
//       LiquidityManager.AddLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         liquidity: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         sizeMin: 1 ether,
//         recipient: alice,
//         deadline: 1
//       })
//     );
//   }

//   function testAmountErrorAdd() external {
//     token0.mint(alice, 1 ether);
//     token1.mint(alice, 8 ether);

//     vm.startPrank(alice);
//     token0.approve(address(liquidityManager), 1 ether);
//     token1.approve(address(liquidityManager), 8 ether);

//     vm.expectRevert(LiquidityManager.AmountError.selector);
//     liquidityManager.addLiquidity(
//       LiquidityManager.AddLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         liquidity: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         sizeMin: 1 ether + 1,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );
//     vm.stopPrank();
//   }

//   function testAccruePosition() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     _mint(address(this), address(this), 5 ether);

//     vm.warp(365 days + 1);

//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year
//     uint256 size = (1 ether * 1 ether) / (1 ether - lpDilution);

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 1.5 ether);
//     assertEq(lendgine.totalPositionSize(), 1 ether + size);
//     assertEq(lendgine.reserve0(), 1.5 ether);
//     assertEq(lendgine.reserve1(), 12 ether);

//     // test lendgine position
//     (uint256 positionSize, uint256 rewardPerPositionPaid, uint256 tokensOwed) =
//       lendgine.positions(address(liquidityManager));
//     assertEq(1 ether + size, positionSize);
//     assertEq(10 * lpDilution, rewardPerPositionPaid);
//     assertEq(10 * lpDilution, tokensOwed);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize, rewardPerPositionPaid, tokensOwed) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(size + 1 ether, positionSize);
//     assertEq(10 * lpDilution, rewardPerPositionPaid);
//     assertEq(10 * lpDilution, tokensOwed);
//   }

//   function testNewPositionAccrued() external {
//     _addLiquidity(address(this), address(this), 1 ether, 8 ether, 1 ether);

//     _mint(address(this), address(this), 5 ether);

//     vm.warp(365 days + 1);

//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year
//     uint256 size = (1 ether * 1 ether) / (1 ether - lpDilution);

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 1.5 ether);
//     assertEq(lendgine.totalPositionSize(), 1 ether + size);
//     assertEq(lendgine.reserve0(), 1.5 ether);
//     assertEq(lendgine.reserve1(), 12 ether);

//     // test lendgine position
//     (uint256 positionSize, uint256 rewardPerPositionPaid,) = lendgine.positions(address(liquidityManager));
//     assertEq(1 ether + size, positionSize);
//     assertEq(10 * lpDilution, rewardPerPositionPaid);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize, rewardPerPositionPaid,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(size, positionSize);
//     assertEq(10 * lpDilution, rewardPerPositionPaid);
//   }

//   function testCallbackValidation() external {
//     vm.expectRevert(LiquidityManager.ValidationError.selector);
//     liquidityManager.QFMMMintCallback(
//       0,
//       abi.encode(
//         LiquidityManager.QFMMMintCallbackData({
//           token0: address(token0),
//           token1: address(token1),
//           token0Exp: token0Scale,
//           token1Exp: token1Scale,
//           strike: strike,
//           amount0: 0,
//           amount1: 0,
//           payer: address(this)
//         })
//       )
//     );
//   }

//   function testEmitAdd() external {
//     token0.mint(alice, 1 ether);
//     token1.mint(alice, 8 ether);

//     vm.startPrank(alice);
//     token0.approve(address(liquidityManager), 1 ether);
//     token1.approve(address(liquidityManager), 8 ether);

//     vm.expectEmit(true, true, true, true, address(liquidityManager));
//     emit AddLiquidity(alice, address(lendgine), 1 ether, 1 ether, 1 ether, 8 ether, alice);
//     liquidityManager.addLiquidity(
//       LiquidityManager.AddLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         liquidity: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         sizeMin: 1 ether,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );
//     vm.stopPrank();
//   }

//   function testRemovePosition() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     vm.prank(alice);
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 0);
//     assertEq(lendgine.totalPositionSize(), 0);
//     assertEq(lendgine.reserve0(), 0);
//     assertEq(lendgine.reserve1(), 0);

//     // test lendgine position
//     (uint256 positionSize,,) = lendgine.positions(address(liquidityManager));
//     assertEq(0, positionSize);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize,,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(0, positionSize);
//   }

//   function testRemoveAmountError() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     vm.prank(alice);
//     vm.expectRevert(LiquidityManager.AmountError.selector);
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 1 ether,
//         amount0Min: 1 ether + 1,
//         amount1Min: 8 ether + 1,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );
//   }

//   function testRemoveNoRecipient() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     vm.prank(alice);
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         recipient: address(0),
//         deadline: block.timestamp
//       })
//     );

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), 0);
//     assertEq(lendgine.totalPositionSize(), 0);
//     assertEq(lendgine.reserve0(), 0);
//     assertEq(lendgine.reserve1(), 0);

//     // test lendgine position
//     (uint256 positionSize,,) = lendgine.positions(address(liquidityManager));
//     assertEq(0, positionSize);

//     // test balances
//     assertEq(1 ether, token0.balanceOf(address(liquidityManager)));
//     assertEq(8 ether, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize,,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(0, positionSize);
//   }

//   function testOverRemove() external {
//     _addLiquidity(address(this), address(this), 1 ether, 8 ether, 1 ether);
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     vm.prank(alice);
//     vm.expectRevert();
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 1.5 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         recipient: address(0),
//         deadline: block.timestamp
//       })
//     );
//   }

//   function testEmitRemove() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);

//     vm.prank(alice);
//     vm.expectEmit(true, true, true, true, address(liquidityManager));
//     emit RemoveLiquidity(alice, address(lendgine), 1 ether, 1 ether, 1 ether, 8 ether, alice);
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 1 ether,
//         amount0Min: 1 ether,
//         amount1Min: 8 ether,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );
//   }

//   function testRemoveAccrue() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);
//     _mint(address(this), address(this), 5 ether);
//     vm.warp(365 days + 1);

//     vm.prank(alice);
//     liquidityManager.removeLiquidity(
//       LiquidityManager.RemoveLiquidityParams({
//         token0: address(token0),
//         token1: address(token1),
//         token0Exp: token0Scale,
//         token1Exp: token1Scale,
//         strike: strike,
//         size: 0.5 ether,
//         amount0Min: 0,
//         amount1Min: 0,
//         recipient: alice,
//         deadline: block.timestamp
//       })
//     );

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year

//     // test lendgine storage
//     assertEq(lendgine.totalLiquidity(), lpDilution / 2);
//     assertEq(lendgine.totalPositionSize(), 0.5 ether);
//     assertEq(lendgine.reserve0(), lpDilution / 2);
//     assertEq(lendgine.reserve1(), lpDilution * 4);

//     // test lendgine position
//     (uint256 positionSize, uint256 rewardPerPositionPaid,) = lendgine.positions(address(liquidityManager));
//     assertEq(0.5 ether, positionSize);
//     assertEq(lpDilution * 10, rewardPerPositionPaid);

//     // test balances
//     assertEq(0, token0.balanceOf(address(liquidityManager)));
//     assertEq(0, token1.balanceOf(address(liquidityManager)));

//     // test liquidity manager position
//     (positionSize, rewardPerPositionPaid,) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(0.5 ether, positionSize);
//     assertEq(lpDilution * 10, rewardPerPositionPaid);
//   }

//   function testCollect() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);
//     _mint(address(this), address(this), 5 ether);
//     vm.warp(365 days + 1);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year

//     vm.prank(alice);
//     liquidityManager.collect(
//       LiquidityManager.CollectParams({ lendgine: address(lendgine), recipient: alice, amountRequested: lpDilution * 10 })
//     );

//     // test lendgine storage slots
//     assertEq(lpDilution * 10, lendgine.rewardPerPositionStored());

//     // test lendgine position
//     (, uint256 rewardPerPositionPaid, uint256 tokensOwed) = lendgine.positions(address(liquidityManager));
//     assertEq(lpDilution * 10, rewardPerPositionPaid);
//     assertEq(0, tokensOwed);

//     // test liquidity manager position
//     (, rewardPerPositionPaid, tokensOwed) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(lpDilution * 10, rewardPerPositionPaid);
//     assertEq(0, tokensOwed);

//     // test user balances
//     assertEq(token1.balanceOf(alice), lpDilution * 10);
//   }

//   function testOverCollect() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);
//     _mint(address(this), address(this), 5 ether);
//     vm.warp(365 days + 1);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year

//     vm.prank(alice);
//     liquidityManager.collect(
//       LiquidityManager.CollectParams({ lendgine: address(lendgine), recipient: alice, amountRequested: 100 ether })
//     );

//     // test lendgine storage slots
//     assertEq(lpDilution * 10, lendgine.rewardPerPositionStored());

//     // test lendgine position
//     (, uint256 rewardPerPositionPaid, uint256 tokensOwed) = lendgine.positions(address(liquidityManager));
//     assertEq(lpDilution * 10, rewardPerPositionPaid);
//     assertEq(0, tokensOwed);

//     // test liquidity manager position
//     (, rewardPerPositionPaid, tokensOwed) = liquidityManager.positions(alice, address(lendgine));
//     assertEq(lpDilution * 10, rewardPerPositionPaid);
//     assertEq(0, tokensOwed);

//     // test user balances
//     assertEq(token1.balanceOf(alice), lpDilution * 10);
//   }

//   function testCollectNoRecipient() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);
//     _mint(address(this), address(this), 5 ether);
//     vm.warp(365 days + 1);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year

//     vm.prank(alice);
//     liquidityManager.collect(
//       LiquidityManager.CollectParams({
//         lendgine: address(lendgine),
//         recipient: address(0),
//         amountRequested: lpDilution * 10
//       })
//     );

//     // test user balances
//     assertEq(token1.balanceOf(address(liquidityManager)), lpDilution * 10);
//   }

//   function testEmitCollect() external {
//     _addLiquidity(alice, alice, 1 ether, 8 ether, 1 ether);
//     _mint(address(this), address(this), 5 ether);
//     vm.warp(365 days + 1);

//     uint256 borrowRate = lendgine.getBorrowRate(0.5 ether, 1 ether);
//     uint256 lpDilution = borrowRate / 2; // 0.5 lp for one year

//     vm.prank(alice);
//     vm.expectEmit(true, true, true, true, address(liquidityManager));
//     emit Collect(alice, address(lendgine), lpDilution * 10, alice);
//     liquidityManager.collect(
//       LiquidityManager.CollectParams({ lendgine: address(lendgine), recipient: alice, amountRequested: lpDilution * 10 })
//     );
//   }
// }
