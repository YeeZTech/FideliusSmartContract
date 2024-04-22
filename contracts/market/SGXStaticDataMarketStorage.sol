// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProgramProxyInterface} from "./interface/ProgramProxyInterface.sol";
import {KeyVerifierInterface} from "./interface/KeyVerifierInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SignatureVerifier} from "./SignatureVerifier.sol";
import {GasRewardTool} from "contracts/plugins/eth-contracts/plugins/GasRewardTool.sol";
import {PaymentConfirmTool} from "contracts/plugins/payment-system/contracts/PaymentConfirmTool.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {SGXStaticData} from "./SGXStaticData.sol";
import {OwnerProxyInterface} from "./interface/OwnerProxyInterface.sol";

abstract contract SGXStaticDataMarketStorage is
    Ownable,
    GasRewardTool,
    PaymentConfirmTool,
    AccessControl
{
    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    mapping(bytes32 => SGXStaticData.Data) public all_data;

    bool public paused;

    ProgramProxyInterface public program_proxy;
    OwnerProxyInterface public owner_proxy;
    address public payment_token;
    uint256 public request_revoke_block_num;

    address payable public fee_pool;
    uint256 public ratio_base;
    uint256 public fee_ratio;
}
