// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {GasRewardToolUpgradeable} from "contracts/plugins/eth-contracts/plugins/GasRewardToolUpgradeable.sol";
import {SGXProxyBaseUpgradeable} from "../SGXProxyBaseUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MinerProxyUpgradeable} from "../../mine/MinerProxyUpgradeable.sol";

// import {Miscellaneous} from "../../utils/Miscellaneous.sol";
pragma experimental ABIEncoderV2;

abstract contract SGXOffChainResultMarketBaseUpgradeable is
    OwnableUpgradeable,
    GasRewardToolUpgradeable,
    SGXProxyBaseUpgradeable,
    MinerProxyUpgradeable
{
    using SafeERC20 for IERC20;
    // using Miscellaneous for IERC20;

    // function changeMarket(address _market) public override onlyOwner {
    //     address old = address(market);
    //     market = DataMarketPlaceInterface(_market);
    //     emit ChangeMarket(old, address(market));
    // }

    // function changeDataLib(address _new_lib) public override onlyOwner {
    //     address old = data_lib_address;
    //     data_lib_address = _new_lib;
    //     emit ChangeDataLib(old, data_lib_address);
    // }

    event SDMarketResultInsufficientFund(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        uint256 gap,
        uint64 cost_gas
    );

    event SDMarketRejectRequest(
        bytes32 indexed vhash,
        bytes32 indexed request_hash
    );

    constructor() {}

    function remindRequestCost(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig
    ) public rewardGas returns (uint256 gap) {
        bytes memory data = abi.encodeWithSignature(
            "remindRequestCost(bytes32,bytes32,uint64,bytes)",
            _vhash,
            request_hash,
            cost,
            sig
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        uint256 _gap = abi.decode(ret, (uint256));
        if (_gap > 0) {
            emit SDMarketResultInsufficientFund(
                request_hash,
                _vhash,
                _gap,
                cost
            );
        }
        return _gap;
    }

    //////////////////////////////////////////
    event SDMarketNewRequestOffChain(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        bytes secret,
        bytes input,
        bytes forward_sig,
        bytes32 program_hash,
        uint256 gas_price,
        bytes pkey,
        uint256 amount
    );

    function _requestOffChain(
        bytes32 _vhash,
        bytes memory secret,
        bytes memory input,
        bytes memory forward_sig,
        bytes32 program_hash,
        uint256 gas_price,
        bytes memory pkey,
        uint256 amount
    ) internal returns (bytes32) {
        if (amount > 0 && market.payment_token() != address(0x0)) {
            // IERC20(market.payment_token()).transferConfirmedAndApprove(
            //     address(market),
            //     amount
            // );

            // 将Miscellaneous.sol中的合约函数transferConfirmedAndApprove()拷贝到此处
            uint256 balanceBefore = IERC20(market.payment_token()).balanceOf(
                address(this)
            );
            IERC20(market.payment_token()).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            uint256 balanceAfter = IERC20(market.payment_token()).balanceOf(
                address(this)
            );
            require(balanceAfter - balanceBefore == amount, "invalid amount");

            IERC20(market.payment_token()).approve(address(market), 0);
            IERC20(market.payment_token()).approve(address(market), amount);

            // Miscellaneous.transferConfirmedAndApprove(
            //     IERC20(market.payment_token()),
            //     address(market),
            //     amount
            // );
        }
        bytes32 request_hash;
        {
            bytes memory data = abi.encodeWithSignature(
                "requestOffChain(bytes32,bytes,bytes,bytes,bytes32,uint256,bytes,uint256)",
                _vhash,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey,
                amount
            );
            bytes memory ret = market.delegateCallUseData(
                data_lib_address,
                data
            );
            (request_hash) = abi.decode(ret, (bytes32));
        }

        {
            bytes memory d2 = abi.encodeWithSignature(
                "internalTransferRequestOwnership(bytes32,bytes32,address)",
                _vhash,
                request_hash,
                msg.sender
            );
            market.delegateCallUseData(data_lib_address, d2);
        }

        emit SDMarketNewRequestOffChain(
            request_hash,
            _vhash,
            secret,
            input,
            forward_sig,
            program_hash,
            gas_price,
            pkey,
            amount
        );
        return request_hash;
    }

    event SDMarketSubmitOffChainResultReady(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        uint64 cost,
        bytes sig,
        bytes32 result_hash
    );

    function submitOffChainResultReady(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory sig,
        bytes32 result_hash
    ) public rewardGas need_confirm_hash(_vhash, request_hash) returns (bool) {
        bytes memory data = abi.encodeWithSignature(
            "submitOffChainResultReady(bytes32,bytes32,uint64,bytes)",
            _vhash,
            request_hash,
            cost,
            sig
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        bool r = abi.decode(ret, (bool));
        emit SDMarketSubmitOffChainResultReady(
            request_hash,
            _vhash,
            cost,
            sig,
            result_hash
        );
        return r;
    }

    event SDMarketRequestOffChainSkey(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        bytes32 result_hash
    );

    function requestOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        bytes32 result_hash
    ) public rewardGas need_confirm_hash(_vhash, request_hash) returns (bool) {
        {
            (address from, , , , , , ) = market.getRequestInfo1(
                _vhash,
                request_hash
            );
            require(from == msg.sender, "only request owner can request skey");
        }
        bytes memory d1 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            address(this)
        );
        market.delegateCallUseData(data_lib_address, d1);

        bytes memory data = abi.encodeWithSignature(
            "requestOffChainSkey(bytes32,bytes32,bytes32)",
            _vhash,
            request_hash,
            result_hash
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        bool r = abi.decode(ret, (bool));

        bytes memory d2 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            msg.sender
        );
        market.delegateCallUseData(data_lib_address, d2);

        emit SDMarketRequestOffChainSkey(request_hash, _vhash, result_hash);
        return r;
    }

    event SDMarketSubmitOffChainSkey(
        bytes32 indexed request_hash,
        bytes32 indexed _vhash,
        uint64 cost,
        bytes skey,
        bytes sig
    );

    function _submitOffChainSkey(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory skey,
        bytes memory sig
    ) internal returns (bool) {
        bytes memory data = abi.encodeWithSignature(
            "submitOffChainSkey(bytes32,bytes32,uint64,bytes,bytes)",
            _vhash,
            request_hash,
            cost,
            skey,
            sig
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        bool r = abi.decode(ret, (bool));

        emit SDMarketSubmitOffChainSkey(request_hash, _vhash, cost, skey, sig);
        return r;
    }

    event SDMarketRefundRequest(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        uint256 refund_amount
    );

    function refundRequest(
        bytes32 _vhash,
        bytes32 request_hash,
        uint256 refund_amount
    ) public rewardGas need_confirm_hash(_vhash, request_hash) {
        if (market.payment_token() == address(0x0)) return;

        (address from, , , , , , ) = market.getRequestInfo1(
            _vhash,
            request_hash
        );
        bytes memory d1 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            address(this)
        );
        market.delegateCallUseData(data_lib_address, d1);

        IERC20(market.payment_token()).safeTransferFrom(
            msg.sender,
            address(this),
            refund_amount
        );
        IERC20(market.payment_token()).approve(address(market), 0);
        IERC20(market.payment_token()).approve(address(market), refund_amount);

        bytes memory data = abi.encodeWithSignature(
            "refundRequest(bytes32,bytes32,uint256)",
            _vhash,
            request_hash,
            refund_amount
        );
        market.delegateCallUseData(data_lib_address, data);

        bytes memory d2 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            from
        );
        market.delegateCallUseData(data_lib_address, d2);
        emit SDMarketRefundRequest(request_hash, _vhash, refund_amount);
    }

    event SDMarketRevokeRequest(
        bytes32 indexed request_hash,
        bytes32 indexed vhash
    );

    function revokeRequest(
        bytes32 _vhash,
        bytes32 request_hash
    ) public rewardGas need_confirm_hash(_vhash, request_hash) {
        {
            (address from, , , , , , ) = market.getRequestInfo1(
                _vhash,
                request_hash
            );
            require(from == msg.sender, "only request owner can revoke");
        }
        //firstly, transfer request's ownership to off-chain market (e.g.,address(this), not address(market)),
        //so the token temporarily belongs to market for following transfer
        bytes memory d1 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            address(this)
        );
        market.delegateCallUseData(data_lib_address, d1);

        bytes memory data = abi.encodeWithSignature(
            "revokeRequest(bytes32,bytes32)",
            _vhash,
            request_hash
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        uint256 token_amount = abi.decode(ret, (uint256));

        bytes memory d2 = abi.encodeWithSignature(
            "internalTransferRequestOwnership(bytes32,bytes32,address)",
            _vhash,
            request_hash,
            msg.sender
        );
        market.delegateCallUseData(data_lib_address, d2);

        if (market.payment_token() != address(0x0))
            IERC20(market.payment_token()).safeTransfer(
                msg.sender,
                token_amount
            );
        emit SDMarketRevokeRequest(request_hash, _vhash);
    }

    uint256[50] private __gap;
}
