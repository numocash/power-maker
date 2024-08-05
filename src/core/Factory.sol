// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import { Lendgine } from "./Lendgine.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IERC20 } from "./interfaces/IERC20.sol";

contract Factory is IFactory {

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event LendgineCreated(
        address indexed token0,
        address indexed token1,
        uint256 indexed strike,
        address lendgine
    );

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error SameTokenError();
    error ZeroAddressError();
    error DeployedError();
    error UnsupportedTokenError();

    /*//////////////////////////////////////////////////////////////
                            FACTORY STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFactory
    mapping(address => mapping(address => mapping(uint256 => address)))
        public
        override getLendgine;

    /*//////////////////////////////////////////////////////////////
                        TEMPORARY DEPLOY STORAGE
    //////////////////////////////////////////////////////////////*/

    struct Parameters {
        address token0;
        address token1;
        uint256 strike;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    /// @inheritdoc IFactory
    Parameters public override parameters;

    /*//////////////////////////////////////////////////////////////
                              FACTORY LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFactory
    function createLendgine(
        address token0,
        address token1,
        uint256 strike
    )
        external
        override
        returns (address lendgine)
    {
        if (token0 == token1) revert SameTokenError();
        if (token0 == address(0) || token1 == address(0)) revert ZeroAddressError();
        if (getLendgine[token0][token1][strike] != address(0)) revert DeployedError();

        // Ensure tokens implement the decimals method
        uint8 token0Decimals = IERC20(token0).decimals();
        uint8 token1Decimals = IERC20(token1).decimals();
        if (token0Decimals == 0 || token1Decimals == 0) revert UnsupportedTokenError();

        parameters = Parameters({
            token0: token0,
            token1: token1,
            strike: strike,
            token0Decimals: token0Decimals,
            token1Decimals: token1Decimals
        });

        lendgine = address(new Lendgine{ salt: keccak256(abi.encode(token0, token1, strike)) }());

        delete parameters;

        getLendgine[token0][token1][strike] = lendgine;
        emit LendgineCreated(token0, token1, strike, lendgine);
    }
}