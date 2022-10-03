// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// testing libraries
import "@forge-std/Test.sol";

// contract dependencies
import {GovHelpers} from "@aave-helpers/GovHelpers.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {ProposalPayload} from "../ProposalPayload.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";

contract ProposalPayloadE2ETest is Test {
    address public constant AAVE_WHALE = 0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    uint256 public proposalId;

    function setUp() public {
        // To fork at a specific block: vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);
        vm.createSelectFork(vm.rpcUrl("mainnet"));

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

        // Pass vote and execute proposal
        GovHelpers.passVoteAndExecute(vm, proposalId);

        // Post-execution assertations
    }
}
