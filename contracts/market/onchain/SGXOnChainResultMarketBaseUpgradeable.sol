// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {GasRewardToolUpgradeable} from "contracts/plugins/eth-contracts/plugins/GasRewardToolUpgradeable.sol";
import {SGXProxyBaseUpgradeable} from "../SGXProxyBaseUpgradeable.sol";
import {MinerProxyUpgradeable} from "../../mine/MinerProxyUpgradeable.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interface/DataMarketPlaceInterface.sol";
pragma experimental ABIEncoderV2;

abstract contract SGXOnChainResultMarketBaseUpgradeable is
    OwnableUpgradeable,
    GasRewardToolUpgradeable,
    SGXProxyBaseUpgradeable,
    MinerProxyUpgradeable
{
    using SafeERC20 for IERC20;

    event SDMarketNewRequestOnChain(
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

    event SDMarketRejectRequest(
        bytes32 indexed vhash,
        bytes32 indexed request_hash
    );

    function _requestOnChain(
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
            IERC20(market.payment_token()).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            require(
                IERC20(market.payment_token()).balanceOf(address(this)) >=
                    amount,
                "invalid amount"
            );

            IERC20(market.payment_token()).approve(address(market), 0);
            IERC20(market.payment_token()).approve(address(market), amount);
        }
        bytes32 request_hash;
        {
            bytes memory data = abi.encodeWithSignature(
                "requestOnChain(bytes32,bytes,bytes,bytes,bytes32,uint256,bytes,uint256)",
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
        require(
            request_hash ==
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
                ),
            "invalid request hash"
        );

        {
            bytes memory d2 = abi.encodeWithSignature(
                "internalTransferRequestOwnership(bytes32,bytes32,address)",
                _vhash,
                request_hash,
                msg.sender
            );
            market.delegateCallUseData(data_lib_address, d2);
        }

        emit SDMarketNewRequestOnChain(
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

    event SDMarketSubmitResult(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        uint64 cost,
        bytes result,
        bytes sig
    );

    function _submitOnChainResult(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory result,
        bytes memory sig
    ) internal returns (bool) {
        bytes memory data = abi.encodeWithSignature(
            "submitOnChainResult(bytes32,bytes32,uint64,bytes,bytes)",
            _vhash,
            request_hash,
            cost,
            result,
            sig
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, data);
        bool v = abi.decode(ret, (bool));
        emit SDMarketSubmitResult(request_hash, _vhash, cost, result, sig);
        if (v) {
            mine_submit_result(_vhash, request_hash);
        }
        return v;
    }

    event SDMarketResultInsufficientFund(
        bytes32 indexed request_hash,
        bytes32 indexed vhash,
        uint256 gap,
        uint64 cost_gas
    );

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
        // {
        (address from, , , , , , ) = market.getRequestInfo1(
            _vhash,
            request_hash
        );
        //     require(from == msg.sender, "only request owner can refund");
        // }
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

    function multicall(
        bytes[] calldata data
    ) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory returndata) = address(this)
                .delegatecall(data[i]);
            if (success) {
                results[i] = returndata;
            } else {
                if (returndata.length > 0) {
                    assembly {
                        let returndata_size := mload(returndata)
                        revert(add(32, returndata), returndata_size)
                    }
                } else {
                    revert("multicall: delegate call failed");
                }
            }
        }
        return results;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20Permit(market.payment_token()).permit(
            owner,
            spender,
            value,
            deadline,
            v,
            r,
            s
        );
    }

    uint256[50] private __gap;
}
