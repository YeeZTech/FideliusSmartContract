// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../onchain/SGXOnChainResult.sol";
import "../interface/ProgramProxyInterface.sol";
import "../interface/KeyVerifierInterface.sol";
import {SignatureVerifier} from "../SignatureVerifier.sol";
import {SGXRequest} from "../SGXRequest.sol";
import {SGXStaticData} from "../SGXStaticData.sol";
import {SGXStaticDataMarketStorage} from "../SGXStaticDataMarketStorage.sol";
import {QuickSort} from "../common/QuickSort.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

//import "forge-std/Test.sol";

//virtual-data-impl: 0x670A29d0b3e9f13E4f4D1D9Bc61e61F4C5D898a9
contract SGXVirtualDataImplV1 is SGXStaticDataMarketStorage {
    using SGXRequest for mapping(bytes32 => SGXRequest.Request);
    using SGXStaticData for mapping(bytes32 => SGXStaticData.Data);

    using SignatureVerifier for bytes32;
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender) {}

    // 虚拟数据是链上对于数据的一种抽象表示
    function createVirtualDataFromMultiData(
        bytes32[] memory _vhashes
    ) public returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](_vhashes.length);
        for (uint i = 0; i < _vhashes.length; i++) {
            hashes[i] = all_data[_vhashes[i]].data_hash;
        }

        bytes32[] memory ts = QuickSort.sort(hashes); // sort hash

        bytes32 hash = keccak256(abi.encodePacked(ts));
        string memory extra = iToHex(abi.encodePacked(ts));
        uint256 price = 0;
        uint256 revoke_block_num = 0;
        for (uint i = 0; i < _vhashes.length; i++) {
            require(all_data[_vhashes[i]].exists, "data vhash not exist");
            price = price + all_data[_vhashes[i]].price; // total price
            if (
                all_data[_vhashes[i]].revoke_timeout_block_num >
                revoke_block_num
            ) {
                revoke_block_num = all_data[_vhashes[i]]
                    .revoke_timeout_block_num;
            }
        }
        bytes32 vhash = all_data.init(
            hash,
            extra,
            price,
            revoke_block_num,
            bytes(extra)
        ); // new vhash for miltiData
        owner_proxy.initOwnerOf(vhash, msg.sender); // 该数据的所有者为msg.sender(market)
        return vhash;
    }

    function iToHex(bytes memory buffer) public pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

    // function internalTransferVirtualDataOwnership(
    //     bytes32 _vhash,
    //     address payable new_owner
    // ) public {
    //     owner_proxy.initOwnerOf(_vhash, new_owner); // 该数据的所有者为msg.sender
    // }
}
