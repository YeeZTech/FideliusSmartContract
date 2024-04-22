// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../assets/TokenBankInterface.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import "../TrustListTools.sol";

contract GasRewarder is Ownable, TrustListTools {
    TokenBankInterface public bank;
    address public extra_token;
    uint256 public extra_token_amount;

    uint256 public extra_gas;

    uint256 public gas_reward_portion_n;
    uint256 public gas_reward_portion_d;

    constructor(address _bank) {
        bank = TokenBankInterface(_bank);
        gas_reward_portion_n = 100;
        gas_reward_portion_d = 100;
    }

    function setExtraGas(uint256 _extra) public onlyOwner {
        extra_gas = _extra;
    }

    function setGasRewardPortion(uint256 _d, uint256 _n) public onlyOwner {
        gas_reward_portion_n = _n;
        gas_reward_portion_d = _d;
        require(_n >= _d, "_n must be no less than _d");
    }

    function reward(
        address payable to,
        uint256 amount
    ) public is_trusted(msg.sender) {
        {
            uint256 ramount = ((amount + extra_gas * tx.gasprice) *
                gas_reward_portion_d) / gas_reward_portion_n;
            if (bank.balance(address(0x0)) > ramount) {
                bank.issue(address(0x0), to, ramount);
            }
        }

        if (extra_token != address(0x0) && extra_token_amount != 0) {
            bank.issue(extra_token, to, extra_token_amount);
        }
    } // 奖励函数

    function setExtraToken(
        address _token,
        uint256 extra_amount
    ) public onlyOwner {
        extra_token = _token;
        extra_token_amount = extra_amount;
    } // 设置额外代币
}