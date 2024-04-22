// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface OwnerProxyInterface {
    function ownerOf(bytes32 hash) external view returns (address);

    function initOwnerOf(bytes32 hash, address owner) external returns (bool);

    function transferOwnership(bytes32 hash, address newOwner) external;
}
