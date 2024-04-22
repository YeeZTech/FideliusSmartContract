// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface SGXVirtualDataInterface {
    function createVirtualDataFromMultiData(
        bytes32[] calldata _vhashes
    ) external returns (bytes32);
}
