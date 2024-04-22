// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {GasRewardTool} from "contracts/plugins/eth-contracts/plugins/GasRewardTool.sol";
import {SGXProxyBase} from "../SGXProxyBase.sol";
import {SGXOffChainResultMarketBase} from "./SGXOffChainResultMarketBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
pragma experimental ABIEncoderV2;

contract SGXOffChainResultMarket is
    Ownable,
    GasRewardTool,
    SGXProxyBase,
    SGXOffChainResultMarketBase
{
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender) {}

    function requestOffChain(
        bytes32 _vhash,
        bytes memory secret,
        bytes memory input,
        bytes memory forward_sig,
        bytes32 program_hash,
        uint256 gas_price,
        bytes memory pkey,
        uint256 amount
    )
        public
        rewardGas
        need_confirm_hash(
            _vhash,
            keccak256(
                abi.encode(
                    msg.sender,
                    pkey,
                    secret,
                    input,
                    forward_sig,
                    program_hash,
                    gas_price,
                    block.number
                )
            )
        )
        returns (bytes32)
    {
        return
            _requestOffChain(
                _vhash,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey,
                amount
            );
    }

    function submitOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory skey,
        bytes memory sig
    ) public rewardGas need_confirm_hash(_vhash, request_hash) returns (bool) {
        return _submitOffChainSkey(_vhash, request_hash, cost, skey, sig);
    }
}
