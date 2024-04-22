// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {GasRewardToolUpgradeable} from "contracts/plugins/eth-contracts/plugins/GasRewardToolUpgradeable.sol";
import {SGXProxyBaseUpgradeable} from "../SGXProxyBaseUpgradeable.sol";
import {SGXVirtualDataBaseUpgradeable} from "../multi/SGXVirtualDataBaseUpgradeable.sol";
import {SGXOffChainResultMarketBaseUpgradeable} from "../offchain/SGXOffChainResultMarketBaseUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
pragma experimental ABIEncoderV2;

contract SGXMultiOffChainResultMarketUpgradeable is
    OwnableUpgradeable,
    GasRewardToolUpgradeable,
    SGXProxyBaseUpgradeable,
    SGXVirtualDataBaseUpgradeable,
    SGXOffChainResultMarketBaseUpgradeable
{
    using SafeERC20 for IERC20;

    //constructor() Ownable(msg.sender) {}
    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function requestOffChain(
        bytes32[] memory _vhashes,
        bytes memory secret,
        bytes memory input,
        bytes memory forward_sig,
        bytes32 program_hash,
        uint256 gas_price,
        bytes memory pkey,
        uint256 amount
    ) public rewardGas returns (bytes32, bytes32) {
        bytes32 vhash = createVirtualData(market, _vhashes);

        // confirm before
        bytes32 transferRequestHash;
        {
            transferRequestHash = _beforeConfirm(
                vhash,
                keccak256(
                    abi.encode(
                        address(this),
                        pkey,
                        secret,
                        input,
                        forward_sig,
                        program_hash,
                        gas_price,
                        block.number
                    )
                )
            );
        }
        bytes32 request_hash = _requestOffChain(
            vhash,
            secret,
            input,
            forward_sig,
            program_hash,
            gas_price,
            pkey,
            amount
        );
        // create a copy of _vhashes to aovid stack too deep error
        bytes32[] memory vhashes = _vhashes;
        recordDataSource(market, request_hash, vhashes);

        // confirm after
        _afterConfirm(vhash, request_hash, transferRequestHash);

        return (vhash, request_hash);
    }

    function submitOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory skey,
        bytes memory sig
    ) public rewardGas need_confirm_hash(_vhash, request_hash) returns (bool) {
        bool v = _submitOffChainSkey(_vhash, request_hash, cost, skey, sig);
        dispatchFee(market, _vhash, request_hash, cost);
        return v;
    }

    function rejectRequest(
        bytes32 _vhash,
        bytes32 request_hash
    ) public rewardGas need_confirm_hash(_vhash, request_hash) {
        require(
            belongDataOwner(market, request_hash, msg.sender),
            "only data owner may reject"
        );
        {
            bytes memory data = abi.encodeWithSignature(
                "rejectRequest(bytes32,bytes32)",
                _vhash,
                request_hash
            );
            market.delegateCallUseData(data_lib_address, data);
        }
        emit SDMarketRejectRequest(_vhash, request_hash);
    }
}
