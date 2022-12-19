// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@forge-std/console.sol";
import {Script} from "@forge-std/Script.sol";
import {Test} from "@forge-std/Test.sol";
import {AaveGovernanceV2, IExecutorWithTimelock} from "@aave-address-book/AaveGovernanceV2.sol";

library DeployMainnetProposal {
    function _deployMainnetProposal(address payload, bytes32 ipfsHash) internal returns (bytes memory) {
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
            abi.encodeWithSelector(
                AaveGovernanceV2.GOV.create.selector,
                IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR),
                targets,
                values,
                signatures,
                calldatas,
                withDelegatecalls,
                ipfsHash
            );
    }
}

contract DeployProposal is Script, Test {
    function run() external {
        address payload = 0x03232b5ee80369A88620615f8328BeEC1884b731;
        bytes32 ipfsHash = 0x98f5bcf905c773dbb9d5336b52f8f6aea62254c092de928fd45b1a4cef5129a7;

        bytes memory encodedPayload = DeployMainnetProposal._deployMainnetProposal(
            payload,
            ipfsHash
        );
        emit log_bytes(encodedPayload);
    }
}
