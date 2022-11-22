// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// testing libraries
import "@forge-std/Test.sol";

// contract dependencies
import {GovHelpers} from "@aave-helpers/GovHelpers.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {ProposalPayload} from "../ProposalPayload.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";
import {IStreamable} from "../external/aave/IStreamable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract ProposalPayloadE2ETest is Test {
    address public constant AAVE_WHALE = 0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    uint256 public proposalId;

    IERC20 public constant AUSDC = IERC20(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    IERC20 public constant AAVE = IERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

    address public constant BENEFICIARY = 0xD20c9667bf0047F313228F9fE11F8b9F8Dc29bBa;
    uint256 public constant AUSDC_VAULT_AMOUNT = 772417e6;
    uint256 public constant AAVE_VESTING_AMOUNT = 9753000000000016896000; // 18 decimals
    uint256 public constant AUSDC_VESTING_AMOUNT = 1029915648000; // 6 decimals
    uint256 public constant VESTING_DURATION = 360 days;

    // December 10th 2022, 00:00:00 UTC
    uint256 public constant AAVE_VESTING_START = 1670659200;

    address public constant AAVE_ECOSYSTEM_RESERVE = 0x25F2226B597E8F9514B3F68F00f494cF4f286491;
    IStreamable public constant STREAMABLE_AAVE_ECOSYSTEM_RESERVE = IStreamable(AAVE_ECOSYSTEM_RESERVE);
    IStreamable public constant STREAMABLE_AAVE_MAINNET_RESERVE_FACTOR = IStreamable(AaveV2Ethereum.COLLECTOR);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16023456);

        // Deploy Payload
        ProposalPayload proposalPayload = new ProposalPayload();

        // Create Proposal
        vm.prank(AAVE_WHALE);
        proposalId = DeployMainnetProposal._deployMainnetProposal(
            address(proposalPayload),
            0x344d3181f08b3186228b93bac0005a3a961238164b8b06cbb5f0428a9180b8a7 // TODO: Replace with actual IPFS Hash
        );
    }

    function testExecute() public {
        // Pre-execution assertations
        uint256 initialGauntletAUSDCBalance = AUSDC.balanceOf(BENEFICIARY);
        uint256 nextEcosystemReserveStreamID = STREAMABLE_AAVE_ECOSYSTEM_RESERVE.getNextStreamId();
        uint256 nextMainnetReserveFactorStreamID = STREAMABLE_AAVE_MAINNET_RESERVE_FACTOR.getNextStreamId();

        // Pass vote and execute proposal
        GovHelpers.passVoteAndExecute(vm, proposalId);

        // Post-execution assertations

        // Check upfront transfer
        assertApproxEqAbs(initialGauntletAUSDCBalance + AUSDC_VAULT_AMOUNT, AUSDC.balanceOf(BENEFICIARY), 1);

        // Check aUSDC stream
        (
            address senderAusdc,
            address recipientAusdc,
            uint256 depositAusdc,
            address tokenAddressAusdc,
            uint256 startTimeAusdc,
            uint256 stopTimeAusdc,
            uint256 remainingBalanceAusdc,
            uint256 ratePerSecondAusdc
        ) = STREAMABLE_AAVE_MAINNET_RESERVE_FACTOR.getStream(nextMainnetReserveFactorStreamID);

        assertEq(senderAusdc, AaveV2Ethereum.COLLECTOR);
        assertEq(recipientAusdc, BENEFICIARY);
        assertEq(depositAusdc, AUSDC_VESTING_AMOUNT);
        assertEq(tokenAddressAusdc, address(AUSDC));
        assertEq(stopTimeAusdc - startTimeAusdc, VESTING_DURATION);
        assertEq(remainingBalanceAusdc, AUSDC_VESTING_AMOUNT);

        // Check aave stream
        (
            address senderAave,
            address recipientAave,
            uint256 depositAave,
            address tokenAddressAave,
            uint256 startTimeAave,
            uint256 stopTimeAave,
            uint256 remainingBalanceAave,
            uint256 ratePerSecondAave
        ) = STREAMABLE_AAVE_ECOSYSTEM_RESERVE.getStream(nextEcosystemReserveStreamID);

        assertEq(senderAave, AAVE_ECOSYSTEM_RESERVE);
        assertEq(recipientAave, BENEFICIARY);
        assertEq(depositAave, AAVE_VESTING_AMOUNT);
        assertEq(tokenAddressAave, address(AAVE));
        assertEq(stopTimeAave - startTimeAave, VESTING_DURATION);
        assertEq(remainingBalanceAave, AAVE_VESTING_AMOUNT);

        // Check that withdrawals work
        vm.startPrank(BENEFICIARY);

        // Checking withdrawal every 30 days for 360 days
        vm.warp(AAVE_VESTING_START);
        for (uint256 i = 0; i < 12; i++) {
            vm.warp(block.timestamp + 30 days);

            uint256 currentAaveGauntletBalance = AAVE.balanceOf(BENEFICIARY);
            uint256 currentAaveGauntletStreamBalance = STREAMABLE_AAVE_ECOSYSTEM_RESERVE.balanceOf(
                nextEcosystemReserveStreamID,
                BENEFICIARY
            );
            uint256 currentAusdcGauntletBalance = AUSDC.balanceOf(BENEFICIARY);
            uint256 currentAusdcGauntletStreamBalance = STREAMABLE_AAVE_MAINNET_RESERVE_FACTOR.balanceOf(
                nextMainnetReserveFactorStreamID,
                BENEFICIARY
            );

            STREAMABLE_AAVE_ECOSYSTEM_RESERVE.withdrawFromStream(
                nextEcosystemReserveStreamID,
                currentAaveGauntletStreamBalance
            );

            STREAMABLE_AAVE_MAINNET_RESERVE_FACTOR.withdrawFromStream(
                nextMainnetReserveFactorStreamID,
                currentAusdcGauntletStreamBalance
            );

            // Checking aUSDC stream amount
            assertApproxEqAbs(
                AUSDC.balanceOf(BENEFICIARY),
                currentAusdcGauntletBalance + currentAusdcGauntletStreamBalance,
                1
            );
            assertApproxEqAbs(
                AUSDC.balanceOf(BENEFICIARY),
                currentAusdcGauntletBalance + (ratePerSecondAusdc * 30 days),
                1
            );

            // Checking AAVE stream amount
            assertEq(AAVE.balanceOf(BENEFICIARY), currentAaveGauntletBalance + currentAaveGauntletStreamBalance);
            assertEq(AAVE.balanceOf(BENEFICIARY), currentAaveGauntletBalance + (ratePerSecondAave * 30 days));
        }
        vm.stopPrank();
    }
}
