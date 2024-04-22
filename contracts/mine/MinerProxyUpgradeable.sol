// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {THMinerInterface} from "./THMinerInterface.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract MinerProxyUpgradeable is OwnableUpgradeable {
    address public miner;
    event ChangeMiner(address old_miner, address new_miner);

    function changeMiner(address _miner) public onlyOwner {
        emit ChangeMiner(miner, _miner);
        miner = _miner;
    }

    function mine_submit_result(bytes32 _vhash, bytes32 request_hash) internal {
        if (miner == address(0x0)) {
            return;
        }
        THMinerInterface(miner).mine_submit_result(_vhash, request_hash);
    }

    uint256[49] private __gap;
}
