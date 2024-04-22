// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {IPaymentProxy} from "./interface/PaymentProxyInterface.sol";

abstract contract PaymentConfirmToolUpgradeable is OwnableUpgradeable {
    address confirm_proxy;

    function __PaymentConfirmToolUpgradeable_init() internal {
        __Ownable_init(msg.sender);
    }

    function __PaymentConfirmToolUpgradeable_init_onchained() internal {}

    event PaymentConfirmRequest(bytes32 indexed hash_);

    modifier need_confirm() {
        if (confirm_proxy != address(0x0)) {
            bytes32 local = IPaymentProxy(confirm_proxy).startTransferRequest();
            _;
            require(
                local == IPaymentProxy(confirm_proxy).endTransferRequest(),
                "invalid nonce"
            );
            emit PaymentConfirmRequest(local);
        } else {
            _;
        }
    }

    /// @return 0 is init or pending, 1 is for succ, 2 is for fail
    function getTransferRequestStatus(
        bytes32 _hash
    ) public view returns (uint8) {
        if (confirm_proxy == address(0x0)) {
            return 1;
        }
        return IPaymentProxy(confirm_proxy).getTransferRequestStatus(_hash);
    }

    event ChangeConfirmProxy(address old_proxy, address new_proxy);

    function changeConfirmProxy(address new_proxy) public onlyOwner {
        address old = confirm_proxy;
        confirm_proxy = new_proxy;
        emit ChangeConfirmProxy(old, new_proxy);
    }

    uint256[49] private __gap;
}
