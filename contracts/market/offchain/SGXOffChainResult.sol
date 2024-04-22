// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXRequest, ProgramProxyInterface} from "../SGXRequest.sol";
import {SignatureVerifier, ECDSA} from "../SignatureVerifier.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library SGXOffChainResult {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using SignatureVerifier for bytes32;
    struct ResultParam {
        bytes32 data_hash;
        address payable data_recver;
        ProgramProxyInterface program_proxy;
        uint256 cost;
        bytes skey;
        bytes sig;
        address payable fee_pool;
        uint256 fee;
        uint256 ratio_base;
    }

    // 链下结果已经准备好交付
    function submit_offchain_result_ready(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig,
        bytes32 data_hash,
        ProgramProxyInterface program_proxy
    ) public returns (bool) {
        require(request_infos[request_hash].exists, "request not exist");
        require(
            request_infos[request_hash].result_type ==
                SGXRequest.ResultType.offchain,
            "only for offchain result"
        );
        require(
            request_infos[request_hash].status == SGXRequest.RequestStatus.init,
            "invalid status"
        );
        SGXRequest.Request storage r = request_infos[request_hash];
        r.status = SGXRequest.RequestStatus.ready;
        {
            bytes memory d = abi.encodePacked(
                r.input,
                data_hash,
                program_proxy.enclave_hash(r.program_hash),
                uint64(cost)
            );
            // bytes memory d = abi.encodePacked(r.input, data_hash, program_proxy.enclave_hash(r.program_hash));
            bytes32 vhash = keccak256(d);
            bool v = vhash.toEthSignedMessageHash().verify_signature(
                sig,
                r.pkey4v
            );
            require(v, "invalid signature");
        }
        return true;
    }

    // 数据使用方请求获取链下结果数据的私钥
    function request_offchain_skey(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 request_hash,
        bytes32 result_hash
    ) internal returns (bool) {
        require(request_infos[request_hash].exists, "request not exist");
        require(
            request_infos[request_hash].result_type ==
                SGXRequest.ResultType.offchain,
            "only for offchain result"
        );
        require(
            request_infos[request_hash].status ==
                SGXRequest.RequestStatus.ready ||
                request_infos[request_hash].status ==
                SGXRequest.RequestStatus.request_key,
            "invalid status"
        );
        require(
            request_infos[request_hash].from == msg.sender,
            "only for request owner"
        );
        SGXRequest.Request storage r = request_infos[request_hash];
        r.status = SGXRequest.RequestStatus.request_key;
        r.result_hash = result_hash;
        return true;
    }

    // 计算节点向智能合约发送链下结果的私钥
    function submit_offchain_skey(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 request_hash,
        SGXOffChainResult.ResultParam memory result_param
    ) internal returns (bool) {
        require(request_infos[request_hash].exists, "request not exist");
        require(
            request_infos[request_hash].status ==
                SGXRequest.RequestStatus.request_key,
            "invalid status"
        );
        SGXRequest.Request storage r = request_infos[request_hash];
        if (r.target_token != address(0)) {
            uint256 amount = result_param.cost * r.gas_price;
            uint256 program_price = r.program_use_price;
            amount = amount + r.data_use_price + program_price;

            uint256 fee = 0;
            require(amount <= r.token_amount, "insufficient amount");

            if (address(result_param.fee_pool) != address(0)) {
                fee = (amount * result_param.fee) / result_param.ratio_base;
                amount = amount + fee;

                //pay fee
                IERC20(r.target_token).safeTransfer(
                    address(result_param.fee_pool),
                    fee
                );
            }

            r.status = SGXRequest.RequestStatus.settled;

            //pay data provider
            IERC20(r.target_token).safeTransfer(
                result_param.data_recver,
                result_param.cost * r.gas_price + r.data_use_price
            );

            //pay program author
            IERC20(r.target_token).safeTransfer(
                result_param.program_proxy.program_owner(r.program_hash),
                program_price
            );

            uint256 rest = r.token_amount - amount;
            if (rest > 0) {
                IERC20(r.target_token).safeTransfer(r.from, rest);
            }
        }

        {
            bytes memory d = abi.encodePacked(
                result_param.skey,
                r.result_hash,
                r.input,
                result_param.data_hash,
                uint64(result_param.cost),
                result_param.program_proxy.enclave_hash(r.program_hash)
            );
            // bytes memory d = abi.encodePacked(
            //     result_param.skey,
            //     r.result_hash,
            //     r.input,
            //     result_param.data_hash,
            //     result_param.program_proxy.enclave_hash(r.program_hash),
            //     uint64(result_param.cost)
            // );
            bytes32 vhash = keccak256(d);
            bool v = vhash.toEthSignedMessageHash().verify_signature(
                result_param.sig,
                r.pkey4v
            );
            require(v, "invalid data");
        }

        return true;
    }
}
