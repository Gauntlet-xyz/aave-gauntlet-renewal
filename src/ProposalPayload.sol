// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {ILendingPool} from "./external/aave/ILendingPool.sol";

/// @title <TITLE>
/// @author <AUTHOR>
/// @notice <DESCRIPTION>
contract ProposalPayload {
    /*///////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice EXAMPLE CONSTANT.
    /// @notice AAVE V2 lending pool.
    ILendingPool private constant lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    /// @notice EXAMPLE CONSTANT.
    /// @notice usdc token.
    address private constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    /// @notice The AAVE governance executor calls this function to implement the proposal.
    function execute() external {}
}
