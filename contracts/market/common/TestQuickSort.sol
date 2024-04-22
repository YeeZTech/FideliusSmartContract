// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {QuickSort} from "./QuickSort.sol";

contract TestQuickSort {
    function quickSort(
        bytes32[] memory arr,
        int256 left,
        int256 right
    ) public pure returns (bytes32[] memory) {
        QuickSort.quickSort(arr, left, right);
        return arr;
    }

    function sort(
        bytes32[] memory data
    ) public pure returns (bytes32[] memory) {
        return QuickSort.sort(data);
    }
}
