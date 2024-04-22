// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnerProxyInterface} from "../market/interface/OwnerProxyInterface.sol";

pragma experimental ABIEncoderV2;

contract NaiveOwner is OwnerProxyInterface {
    mapping(bytes32 => address) public data;

    function ownerOf(bytes32 hash) public view returns (address) {
        return data[hash];
    }

    function initOwnerOf(bytes32 hash, address owner) external returns (bool) {
        if (data[hash] != address(0x0)) {
            return false;
        }
        data[hash] = owner;
        return true;
    }

    event TransferOwnership(bytes32 hash, address newOwner);

    function transferOwnership(bytes32 hash, address newOwner) external {
        require(
            data[hash] != address(0),
            "HTOwnerProxy: This hash doesn't exist"
        );
        require(
            data[hash] == msg.sender,
            "HTOwnerProxy: The caller is not the owner"
        );
        data[hash] = newOwner;
        emit TransferOwnership(hash, newOwner);
    }
}

contract NaiveOwnerFactory {
    event NewNaiveOwner(address addr);

    function createNaiveOwner() public returns (address) {
        NaiveOwner no = new NaiveOwner();
        emit NewNaiveOwner(address(no));
        return address(no);
    }
}
