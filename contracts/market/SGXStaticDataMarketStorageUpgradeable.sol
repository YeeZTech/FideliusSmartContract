// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProgramProxyInterface} from "./interface/ProgramProxyInterface.sol";
import {KeyVerifierInterface} from "./interface/KeyVerifierInterface.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SignatureVerifier} from "./SignatureVerifier.sol";
import {GasRewardToolUpgradeable} from "contracts/plugins/eth-contracts/plugins/GasRewardToolUpgradeable.sol";
import {PaymentConfirmToolUpgradeable} from "contracts/plugins/payment-system/contracts/PaymentConfirmToolUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {SGXStaticData} from "./SGXStaticData.sol";
import {OwnerProxyInterface} from "./interface/OwnerProxyInterface.sol";

abstract contract SGXStaticDataMarketStorageUpgradeable is
    OwnableUpgradeable,
    GasRewardToolUpgradeable,
    PaymentConfirmToolUpgradeable,
    AccessControlUpgradeable
{
    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    function __SGXStaticDataMarketStorageUpgradable_init() internal {
        __Ownable_init(msg.sender);
        __GasRewardToolUpgradeable_init_onchained();
        __PaymentConfirmToolUpgradeable_init_onchained();
        __AccessControl_init_unchained();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function __SGXStaticDataMarketStorageUpgradable_init_unchained() internal {}

    mapping(bytes32 => SGXStaticData.Data) public all_data;

    bool public paused;

    ProgramProxyInterface public program_proxy;
    OwnerProxyInterface public owner_proxy;
    address public payment_token;
    uint256 public request_revoke_block_num;

    address payable public fee_pool;
    uint256 public ratio_base;
    uint256 public fee_ratio;

    uint256[41] private __gap;
}
