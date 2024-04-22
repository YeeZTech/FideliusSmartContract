// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProgramProxyInterface} from "./ProgramProxyInterface.sol";
import {OwnerProxyInterface} from "./OwnerProxyInterface.sol";

pragma experimental ABIEncoderV2;

interface DataMarketPlaceInterface {
    function payment_token() external view returns (address);

    function program_proxy() external view returns (ProgramProxyInterface);

    function owner_proxy() external view returns (OwnerProxyInterface);

    function delegateCallUseData(
        address _e,
        bytes memory data
    ) external returns (bytes memory);

    function getRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash
    ) external view returns (int);

    function updateRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash,
        int status
    ) external;

    function getDataInfo(
        bytes32 _vhash
    )
        external
        view
        returns (
            bytes32 data_hash,
            string memory extra_info,
            uint256 price,
            bytes memory pkey,
            address owner,
            bool removed,
            uint256 revoke_timeout_block_num,
            bool exists
        );

    function getRequestInfo1(
        bytes32 _vhash,
        bytes32 request_hash
    )
        external
        view
        returns (
            address from,
            bytes memory pkey4v,
            bytes memory secret,
            bytes memory input,
            bytes memory forward_sig,
            bytes32 program_hash,
            bytes32 result_hash
        );

    function getRequestInfo2(
        bytes32 _vhash,
        bytes32 request_hash
    )
        external
        view
        returns (
            address target_token,
            uint gas_price,
            uint block_number,
            uint256 revoke_block_num,
            uint256 data_use_price,
            uint program_use_price,
            uint status,
            uint result_type
        );
}
