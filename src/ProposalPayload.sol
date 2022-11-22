// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IAaveEcosystemReserveController} from "./external/aave/IAaveEcosystemReserveController.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";

/**
 * @title Gauntlet <> Aave Renewal
 * @author Paul Lei, Deepa Talwar, Jesse Kao, Jonathan Reem, Nick Cannon, Nathan Lord, Watson Fu, Sarah Chen
 * @notice Gauntlet <> Aave Renewal
 * Governance Forum Post: https://governance.aave.com/t/arc-gauntlet-aave-renewal/10516
 * Snapshot:
 */
contract ProposalPayload {
    address public constant BENEFICIARY = 0xD20c9667bf0047F313228F9fE11F8b9F8Dc29bBa;
    // 772,417 aUSDC vaulted upfront amount
    uint256 public constant AUSDC_VAULT_AMOUNT = 772417e6;
    // Have to add a small amount so that the amount divides evenly by the stream duration.
    // ```python
    // amount = AMOUNT * int(1eDECIMALS)
    // duration = 360 * 24 * 60 * 60
    // remainder = amount % duration
    // exact = amount + (duration - remainder)
    // print(exact)
    // ```
    // 9,753 AAVE, with added rounding amount
    uint256 public constant AAVE_VESTING_AMOUNT = 9753000000000016896000; // 18 decimals
    // 1,029,888 aUSDC, with added rounding amount
    uint256 public constant AUSDC_VESTING_AMOUNT = 1029915648000; // 6 decimals
    uint256 public constant VESTING_DURATION = 360 days;

    // December 10th 2022, 00:00:00 UTC
    uint256 public constant AAVE_VESTING_START = 1670659200;

    address public constant AUSDC_TOKEN = 0xBcca60bB61934080951369a648Fb03DF4F96263C;
    address public constant AAVE_TOKEN = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    address public constant AAVE_ECOSYSTEM_RESERVE = 0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    function execute() external {
        // aUSDC vault transfer
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            AUSDC_TOKEN,
            BENEFICIARY,
            AUSDC_VAULT_AMOUNT
        );

        // aave and ausdc streams

        // aave stream
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).createStream(
            AAVE_ECOSYSTEM_RESERVE,
            BENEFICIARY,
            AAVE_VESTING_AMOUNT,
            AAVE_TOKEN,
            AAVE_VESTING_START,
            AAVE_VESTING_START + VESTING_DURATION
        );

        // ausdc stream
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).createStream(
            AaveV2Ethereum.COLLECTOR,
            BENEFICIARY,
            AUSDC_VESTING_AMOUNT,
            AUSDC_TOKEN,
            AAVE_VESTING_START,
            AAVE_VESTING_START + VESTING_DURATION
        );
    }
}
