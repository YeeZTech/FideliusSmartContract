// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenInterface} from "contracts/plugins/eth-contracts/erc20/TokenInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {THPeriodInterface} from "./THPeriodInterface.sol";

contract THMint is Ownable {
    address payable public pool; //this is a token bank
    address public target_token;
    THPeriodInterface public period_contract;
    uint256 public last_mint_period;
    uint256 public period_amount;

    constructor(
        address _period_contract,
        address _target_token,
        address payable _pool,
        uint256 _period_amount
    ) Ownable(msg.sender) {
        period_contract = THPeriodInterface(_period_contract);
        target_token = _target_token;
        pool = _pool;
        period_amount = _period_amount;
        last_mint_period = 0;
    }

    event THMintPeriod(
        uint256 from_period,
        uint256 to_period,
        uint256 mint_amount
    );

    function mint() public {
        uint256 old = period_contract.current_period();
        uint256 cp = period_contract.get_current_period();
        if (cp <= last_mint_period) return;
        uint256 amount = (cp - last_mint_period) * period_amount;
        TokenInterface(target_token).generateTokens(pool, amount);
        last_mint_period = cp;
        emit THMintPeriod(old, cp, amount);
    }

    event PoolChanged(address new_pool);

    function change_pool(address payable _pool) public onlyOwner {
        pool = _pool;
        emit PoolChanged(_pool);
    }

    event PeriodAmountChanged(uint256 amount);

    function change_period_amount(uint256 _amount) public onlyOwner {
        period_amount = _amount;
        emit PeriodAmountChanged(_amount);
    }
}

contract THMintFactory {
    event NewTHMint(address addr);

    function createTHMint(
        address _period_contract,
        address _target_token,
        address payable _pool,
        uint256 _period_amount
    ) public returns (address) {
        THMint newMint = new THMint(
            _period_contract,
            _target_token,
            _pool,
            _period_amount
        );

        emit NewTHMint(address(newMint));
        newMint.transferOwnership(msg.sender);
        return address(newMint);
    }
}
