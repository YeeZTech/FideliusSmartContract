// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {THMinerInterface} from "./THMinerInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MinerProxy is Ownable {
    address public miner;
    event ChangeMiner(address old_miner, address new_miner);

    constructor() {}

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
}
