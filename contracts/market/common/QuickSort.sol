// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library QuickSort {
    function quickSort(
        bytes32[] memory arr,
        int left,
        int right
    ) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        bytes32 pivot = (arr[uint(left + (right - left) / 2)]);
        while (i <= j) {
            while (arr[uint(i)] > pivot) i++;
            while (pivot > arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function sort(
        bytes32[] memory data
    ) public pure returns (bytes32[] memory) {
        quickSort(data, int(0), int(data.length - 1));
        return data;
    }
}
