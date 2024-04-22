// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface MultiSigInterface {
    function update_and_check_reach_majority(
        uint64 id,
        string memory name,
        bytes32 hash,
        address sender
    ) external returns (bool);

    function is_signer(address addr) external view returns (bool);
}
