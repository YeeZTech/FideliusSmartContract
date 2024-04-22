// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface THMinerInterface {
    function mine_submit_result(bytes32 _vhash, bytes32 request_hash) external;
}
