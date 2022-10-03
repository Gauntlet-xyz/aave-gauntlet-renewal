// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IAaveEcosystemReserveController} from "./external/aave/IAaveEcosystemReserveController.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";

/**
 * @title <TITLE>
 * @author Llama
 * @notice <DESCRIPTION>
 * Governance Forum Post:
 * Snapshot:
 */
contract ProposalPayload {
    /// @notice The AAVE governance executor calls this function to implement the proposal.
    function execute() external {}
}
