// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Test.sol";
import "contracts/market/common/QuickSort.sol";

contract TestQuickSort is Test {
    bytes32 d1 =
        hex"3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
    bytes32 d2 =
        hex"362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a1";
    bytes32 d3 =
        hex"a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a532";

    function test_qSort() public view {
        bytes32[] memory data = new bytes32[](3);
        data[0] = d1;
        data[1] = d2;
        data[2] = d3;
        QuickSort.quickSort(data, int(0), int(data.length - 1));
        assert(data[0] > data[1]);
        assert(data[1] > data[2]);
    }
}
