// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SignatureVerifier} from "../SignatureVerifier.sol";
import {Address} from "@chainlink/contracts/src/v0.7/vendor/Address.sol";
import {SGXRequest} from "../SGXRequest.sol";
import {SGXStaticData} from "../SGXStaticData.sol";
import {SGXOffChainResult} from "./SGXOffChainResult.sol";
import {SGXStaticDataMarketStorage} from "../SGXStaticDataMarketStorage.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SGXOffChainResultMarketImplV1 is SGXStaticDataMarketStorage {
    using SGXOffChainResult for mapping(bytes32 => SGXRequest.Request);
    using SGXRequest for mapping(bytes32 => SGXRequest.Request);
    using SignatureVerifier for bytes32;
    using SafeERC20 for IERC20;
    using Address for address;

    constructor() Ownable(msg.sender) {}

    function remindRequestCost(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig
    ) public view returns (uint256 gap) {
        require(all_data[_vhash].exists, "not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        //This is unncessary
        //require(d.owner == msg.sender, "only data owner can remind");
        return
            d.requests.remind_cost(
                d.data_hash,
                d.price,
                program_proxy,
                request_hash,
                cost,
                sig,
                ratio_base,
                fee_ratio
            );
    }

    function refundRequest(
        bytes32 _vhash,
        bytes32 request_hash,
        uint256 refund_amount
    ) public {
        require(all_data[_vhash].exists, "not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        d.requests.refund_request(request_hash, refund_amount);
    }

    function revokeRequest(
        bytes32 _vhash,
        bytes32 request_hash
    ) public returns (uint256 token_amount) {
        require(all_data[_vhash].exists, "not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        return d.requests.revoke_request(request_hash);
    }

    function rejectRequest(bytes32 _vhash, bytes32 request_hash) public {
        require(all_data[_vhash].exists, "data not exist");

        require(
            all_data[_vhash].requests[request_hash].exists,
            "request not exist"
        );
        SGXRequest.Request storage r = all_data[_vhash].requests[request_hash];
        require(r.status == SGXRequest.RequestStatus.init, "invalid status");

        r.status = SGXRequest.RequestStatus.rejected;
        if (r.target_token != address(0x0)) {
            IERC20(r.target_token).safeTransfer(r.from, r.token_amount);
        }
    }

    function requestOffChain(
        bytes32 _vhash,
        bytes memory secret,
        bytes memory input,
        bytes memory forward_sig,
        bytes32 program_hash,
        uint gas_price,
        bytes memory pkey,
        uint256 amount
    ) public returns (bytes32 request_hash) {
        require(all_data[_vhash].exists, "data vhash not exist");
        require(
            program_proxy.is_program_hash_available(program_hash),
            "invalid program"
        );
        request_hash = keccak256(
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
        );
        mapping(bytes32 => SGXRequest.Request) storage request_infos = all_data[
            _vhash
        ].requests;
        require(request_infos[request_hash].exists == false, "already exist");

        if (amount > 0 && payment_token != address(0x0)) {
            IERC20(payment_token).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
        }

        request_infos[request_hash].from = payable(msg.sender);
        request_infos[request_hash].pkey4v = pkey;
        request_infos[request_hash].secret = secret;
        request_infos[request_hash].input = input;
        request_infos[request_hash].data_use_price = all_data[_vhash].price;
        request_infos[request_hash].program_use_price = program_proxy
            .program_price(program_hash);
        request_infos[request_hash].forward_sig = forward_sig;
        request_infos[request_hash].program_hash = program_hash;
        request_infos[request_hash].token_amount = amount;
        request_infos[request_hash].gas_price = gas_price;
        request_infos[request_hash].block_number = block.number;
        request_infos[request_hash].revoke_block_num = all_data[_vhash]
            .revoke_timeout_block_num;
        request_infos[request_hash].status = SGXRequest.RequestStatus.init;
        request_infos[request_hash].result_type = SGXRequest
            .ResultType
            .offchain;
        request_infos[request_hash].exists = true;
        request_infos[request_hash].target_token = payment_token;
    }

    function submitOffChainResultReady(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig
    ) public returns (bool) {
        require(all_data[_vhash].exists, "data vhash not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        return
            d.requests.submit_offchain_result_ready(
                request_hash,
                cost,
                sig,
                d.data_hash,
                program_proxy
            );
    }

    function requestOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        bytes32 result_hash
    ) public returns (bool) {
        require(all_data[_vhash].exists, "data vhash not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        return d.requests.request_offchain_skey(request_hash, result_hash);
    }

    function submitOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory skey,
        bytes memory sig
    ) public returns (bool) {
        require(all_data[_vhash].exists, "data vhash not exist");
        SGXStaticData.Data storage d = all_data[_vhash];
        SGXOffChainResult.ResultParam memory p;
        p.data_hash = d.data_hash;
        p.data_recver = payable(owner_proxy.ownerOf(_vhash));
        p.program_proxy = program_proxy;
        p.cost = cost;
        p.skey = skey;
        p.sig = sig;
        p.fee_pool = fee_pool;
        p.fee = fee_ratio;
        p.ratio_base = ratio_base;
        return d.requests.submit_offchain_skey(request_hash, p);
    }

    function internalTransferRequestOwnership(
        bytes32 _vhash,
        bytes32 request_hash,
        address payable new_owner
    ) public {
        all_data[_vhash].requests[request_hash].from = new_owner;
    }
}
