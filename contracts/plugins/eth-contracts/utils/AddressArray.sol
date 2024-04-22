// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library AddressArray {
    function exists(
        address[] memory self,
        address addr
    ) public pure returns (bool) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function index_of(
        address[] memory self,
        address addr
    ) public pure returns (uint) {
        for (uint i = 0; i < self.length; i++) {
            if (self[i] == addr) {
                return i;
            }
        }
        require(false, "AddressArray:index_of, not exist");
        return 0; // 不会走到这一步
    }

    function remove(
        address[] storage self,
        address addr
    ) public returns (bool) {
        uint index = index_of(self, addr);
        self[index] = self[self.length - 1];

        self.pop();

        return true;
    }
}
