// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {GasRewardTool} from "contracts/plugins/eth-contracts/plugins/GasRewardTool.sol";
import {SGXProxyBase} from "../SGXProxyBase.sol";
import {MinerProxy} from "../../mine/MinerProxy.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {SGXOnChainResultMarketBase} from "./SGXOnChainResultMarketBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma experimental ABIEncoderV2;

contract SGXOnChainResultMarket is
    Ownable,
    GasRewardTool,
    SGXProxyBase,
    MinerProxy,
    SGXOnChainResultMarketBase
{
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender) {}

    function requestOnChain(
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
        )
        returns (bytes32)
    {
        return
            _requestOnChain(
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

    function submitOnChainResult(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory result,
        bytes memory sig
    ) public rewardGas need_confirm_hash(_vhash, request_hash) returns (bool) {
        return _submitOnChainResult(_vhash, request_hash, cost, result, sig);
    }
}
