// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BlockNumberContract {
    function getBlockNumber() public view returns (uint) {
        return block.number;
    }
}
