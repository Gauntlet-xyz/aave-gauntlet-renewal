// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@forge-std/console.sol";
import {Script} from "@forge-std/Script.sol";
import "../src/external/aave/IAaveGovernanceV2.sol";
import "../src/external/aave/IExecutorWithTimelock.sol";

library DeployMainnetProposal {
    IAaveGovernanceV2 internal constant aaveGovernanceV2 =
        IAaveGovernanceV2(0xEC568fffba86c094cf06b22134B23074DFE2252c);
    IExecutorWithTimelock internal constant aaveGovernanceShortExecutor =
        IExecutorWithTimelock(0xEE56e2B3D491590B5b31738cC34d5232F378a8D5);

    function _deployMainnetProposal(address payload, bytes32 ipfsHash) internal returns (uint256 proposalId) {
        require(payload != address(0), "ERROR: PAYLOAD can't be address(0)");
        require(ipfsHash != bytes32(0), "ERROR: IPFS_HASH can't be bytes32(0)");
        address[] memory targets = new address[](1);
        targets[0] = payload;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "execute()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        return
            aaveGovernanceV2.create(
                aaveGovernanceShortExecutor,
                targets,
                values,
                signatures,
                calldatas,
                withDelegatecalls,
                ipfsHash
            );
    }
}

contract DeployProposal is Script {
    function run() external {
        vm.startBroadcast();
        DeployMainnetProposal._deployMainnetProposal(
            address(0), // TODO: replace with mainnet payload address
            bytes32(0) // TODO: replace with actual ipfshash
        );
        vm.stopBroadcast();
    }
}
