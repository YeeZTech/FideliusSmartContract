// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface GasRewardInterface {
    function reward(address payable to, uint256 amount) external;
}

abstract contract GasRewardTool is Ownable {
    GasRewardInterface public gas_reward_contract;

    constructor() {}

    modifier rewardGas() {
        uint256 gas_start = gasleft();
        _; // 表示执行修饰的函数题后再执行下面的内容。
        uint256 gasused = (gas_start - gasleft()) * tx.gasprice;
        if (gas_reward_contract != GasRewardInterface(address(0x0))) {
            gas_reward_contract.reward(payable(tx.origin), gasused);
        }
    }

    event ChangeRewarder(address _old, address _new);

    function changeRewarder(address _rewarder) public onlyOwner {
        address old = address(gas_reward_contract);
        gas_reward_contract = GasRewardInterface(_rewarder);
        emit ChangeRewarder(old, _rewarder);
    }
}
