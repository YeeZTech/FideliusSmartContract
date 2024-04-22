// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SignatureVerifier, ECDSA} from "./SignatureVerifier.sol";
import {ProgramProxyInterface} from "./interface/ProgramProxyInterface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//import "forge-std/Test.sol";

library SGXRequest {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using SignatureVerifier for bytes32;

    enum RequestStatus {
        invalid, //invalid request
        init,
        init_need_confirm,
        ready,
        ready_need_confirm,
        request_key,
        request_key_need_confirm,
        settled,
        settled_need_confirm,
        revoked,
        revoked_need_confirm,
        rejected,
        rejected_need_confirm
    }

    enum ResultType {
        offchain,
        onchain
    }

    struct Request {
        address payable from;
        bytes pkey4v;
        bytes secret;
        bytes input;
        bytes forward_sig;
        bytes32 program_hash;
        bytes32 result_hash;
        address target_token;
        uint256 token_amount;
        uint256 gas_price;
        uint256 block_number;
        uint256 revoke_block_num;
        uint256 data_use_price;
        uint256 program_use_price;
        RequestStatus status;
        ResultType result_type;
        bool exists;
    }
    struct RequestInitParam {
        bytes secret;
        bytes input;
        bytes forward_sig;
        bytes32 program_hash;
        uint256 gas_price;
        bytes pkey;
        uint256 data_use_price;
        uint256 program_use_price;
        ProgramProxyInterface program_proxy;
    }

    function refund_request(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 request_hash,
        uint256 refund_amount
    ) internal {
        require(request_infos[request_hash].exists, "request not exist");
        require(
            request_infos[request_hash].status ==
                SGXRequest.RequestStatus.init ||
                request_infos[request_hash].status ==
                SGXRequest.RequestStatus.ready ||
                request_infos[request_hash].status ==
                SGXRequest.RequestStatus.request_key,
            "invalid status"
        );

        request_infos[request_hash].token_amount =
            request_infos[request_hash].token_amount +
            refund_amount;

        if (request_infos[request_hash].target_token != address(0x0)) {
            IERC20(request_infos[request_hash].target_token).safeTransferFrom(
                msg.sender,
                address(this),
                refund_amount
            );
        }
    }

    function remind_cost(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 data_hash,
        uint256 data_price,
        ProgramProxyInterface program_proxy,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig,
        uint256 ratio_base,
        uint256 fee_ratio
    ) internal view returns (uint256 gap) {
        require(request_infos[request_hash].exists, "request not exist");
        require(
            request_infos[request_hash].status == SGXRequest.RequestStatus.init,
            "invalid status"
        );

        SGXRequest.Request storage r = request_infos[request_hash];
        {
            bytes memory cost_msg = abi.encodePacked(
                r.input,
                data_hash,
                program_proxy.enclave_hash(r.program_hash),
                uint64(cost)
            );
            bytes32 vhash = keccak256(cost_msg);

            bool v = vhash.toEthSignedMessageHash().verify_signature(
                sig,
                r.pkey4v
            );
            require(v, "invalid cost signature");
        }

        uint256 c = cost;
        uint256 amount = c * r.gas_price;

        amount =
            amount +
            data_price +
            program_proxy.program_price(r.program_hash);
        uint256 fee = (amount * fee_ratio) / ratio_base;
        amount = amount + fee;

        if (amount > request_infos[request_hash].token_amount) {
            return amount - request_infos[request_hash].token_amount;
        } else {
            return 0;
        }
    }

    function revoke_request(
        mapping(bytes32 => SGXRequest.Request) storage request_infos,
        bytes32 request_hash
    ) internal returns (uint256) {
        require(request_infos[request_hash].exists, "request not exist");
        SGXRequest.Request storage r = request_infos[request_hash];
        require(
            r.status == SGXRequest.RequestStatus.init ||
                r.status == SGXRequest.RequestStatus.ready ||
                r.status == SGXRequest.RequestStatus.request_key,
            "invalid status"
        );

        require(
            block.number - r.block_number >= r.revoke_block_num,
            "not long enough for revoke"
        );

        //TODO: charge fee for revoke
        r.status = SGXRequest.RequestStatus.revoked;
        if (r.target_token != address(0x0)) {
            IERC20(r.target_token).safeTransfer(r.from, r.token_amount);
        }
        return r.token_amount;
    }
}
