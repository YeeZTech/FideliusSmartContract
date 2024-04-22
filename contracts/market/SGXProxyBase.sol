// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PaymentConfirmTool} from "contracts/plugins/payment-system/contracts/PaymentConfirmTool.sol";
import {IPaymentProxy} from "contracts/plugins/payment-system/contracts/interface/PaymentProxyInterface.sol";
import {SGXRequest} from "./SGXRequest.sol";
import {DataMarketPlaceInterface} from "./interface/DataMarketPlaceInterface.sol";

abstract contract SGXProxyBase is Ownable, PaymentConfirmTool {
    struct data_request_hash {
        bytes32 data_vhash;
        bytes32 request_hash;
    }

    mapping(bytes32 => data_request_hash) public transfer_to_request_hashes;

    DataMarketPlaceInterface public market;

    address public data_lib_address;

    event ChangeMarket(address old_market, address new_market);

    function changeMarket(address _market) public onlyOwner {
        address old = address(market);
        market = DataMarketPlaceInterface(_market);
        emit ChangeMarket(old, address(market));
    }

    event ChangeDataLib(address old_lib, address new_lib);

    function changeDataLib(address _new_lib) public onlyOwner {
        address old = data_lib_address;
        data_lib_address = _new_lib;
        emit ChangeDataLib(old, data_lib_address);
    }

    modifier need_confirm_hash(bytes32 data_vhash, bytes32 request_hash) {
        if (confirm_proxy != address(0x0)) {
            bytes32 local = IPaymentProxy(confirm_proxy).startTransferRequest();
            _;
            require(
                local == IPaymentProxy(confirm_proxy).endTransferRequest(),
                "invalid nonce"
            );
            emit PaymentConfirmRequest(local);
            if (getTransferRequestStatus(local) == 0) {
                int status = market.getRequestStatus(data_vhash, request_hash);
                market.updateRequestStatus(
                    data_vhash,
                    request_hash,
                    status + 1
                );
                transfer_to_request_hashes[local].data_vhash = data_vhash;
                transfer_to_request_hashes[local].request_hash = request_hash;
            }
        } else {
            _;
        }
    }

    function _beforeConfirm(
        bytes32 data_vhash,
        bytes32 request_hash
    ) internal returns (bytes32 transferRequestHash) {
        if (confirm_proxy != address(0x0)) {
            transferRequestHash = IPaymentProxy(confirm_proxy)
                .startTransferRequest();
        }
    }

    function _afterConfirm(
        bytes32 data_vhash,
        bytes32 request_hash,
        bytes32 transferRequestHash
    ) internal {
        if (confirm_proxy != address(0x0)) {
            require(
                transferRequestHash ==
                    IPaymentProxy(confirm_proxy).endTransferRequest(),
                "invalid nonce"
            );
            emit PaymentConfirmRequest(transferRequestHash);
            if (getTransferRequestStatus(transferRequestHash) == 0) {
                int status = market.getRequestStatus(data_vhash, request_hash);
                market.updateRequestStatus(
                    data_vhash,
                    request_hash,
                    status + 1
                );
                transfer_to_request_hashes[transferRequestHash]
                    .data_vhash = data_vhash;
                transfer_to_request_hashes[transferRequestHash]
                    .request_hash = request_hash;
            }
        }
    }

    function transferCommit(bytes32 hash, bool _value) public onlyOwner {
        if (getTransferRequestStatus(hash) != 0) {
            return;
        }
        IPaymentProxy(confirm_proxy).transferCommit(hash, _value);
        data_request_hash storage d = transfer_to_request_hashes[hash];
        int status = market.getRequestStatus(d.data_vhash, d.request_hash);
        if (_value) {
            market.updateRequestStatus(
                d.data_vhash,
                d.request_hash,
                status - 1
            );
        } else {
            if (
                uint256(status) ==
                uint256(SGXRequest.RequestStatus.init_need_confirm)
            ) {
                market.updateRequestStatus(
                    d.data_vhash,
                    d.request_hash,
                    int256(uint256(SGXRequest.RequestStatus.invalid))
                );
            } else if (
                uint256(status) ==
                uint256(SGXRequest.RequestStatus.settled_need_confirm)
            ) {
                require(false, "cannot commit false for settled tx");
            } else {
                market.updateRequestStatus(
                    d.data_vhash,
                    d.request_hash,
                    int256(uint256(SGXRequest.RequestStatus.init))
                );
            }
        }
    }

    function _autoTransferCommit(bytes32 hash, bool _value) internal {
        if (confirm_proxy != address(0x0)) {
            if (getTransferRequestStatus(hash) != 0) {
                return;
            }
            IPaymentProxy(confirm_proxy).transferCommit(hash, _value);
            data_request_hash storage d = transfer_to_request_hashes[hash];
            int status = market.getRequestStatus(d.data_vhash, d.request_hash);
            if (_value) {
                market.updateRequestStatus(
                    d.data_vhash,
                    d.request_hash,
                    status - 1
                );
            } else {
                if (
                    uint256(status) ==
                    uint256(SGXRequest.RequestStatus.init_need_confirm)
                ) {
                    market.updateRequestStatus(
                        d.data_vhash,
                        d.request_hash,
                        int256(uint256(SGXRequest.RequestStatus.invalid))
                    );
                } else if (
                    uint256(status) ==
                    uint256(SGXRequest.RequestStatus.settled_need_confirm)
                ) {
                    require(false, "cannot commit false for settled tx");
                } else {
                    market.updateRequestStatus(
                        d.data_vhash,
                        d.request_hash,
                        int256(uint256(SGXRequest.RequestStatus.init))
                    );
                }
            }
        }
    }
}
