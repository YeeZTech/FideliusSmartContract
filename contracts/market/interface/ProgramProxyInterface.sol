// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ProgramProxyInterface {
    function is_program_hash_available(
        bytes32 hash
    ) external view returns (bool);

    function program_price(bytes32 hash) external view returns (uint256);

    function program_owner(bytes32 hash) external view returns (address);

    function enclave_hash(bytes32 hash) external view returns (bytes32);
}
