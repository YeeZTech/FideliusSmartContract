// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokenBankInterface} from "contracts/plugins/eth-contracts/assets/TokenBankInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {THPeriodInterface} from "./THPeriodInterface.sol";
import {IPeriodAmount} from "./IPeriodAmount.sol";

interface THMintInterface {
    function mint() external;
}

interface THUserProportionInterface {
    function user_proportion(
        address addr
    ) external view returns (uint256, uint256);
}

contract THTRDispatcher is Ownable {
    THUserProportionInterface public THraise;

    IPeriodAmount public period_amount_contract;
    THPeriodInterface public THperiod;

    address public pool;
    address public target_token;
    mapping(address => uint256) public claimed_period;
    uint256 public begin_period;
    uint256 public end_period;

    constructor(
        address _target_token,
        address _pool,
        address _THperiod,
        address _raise,
        address _period_amount_contract,
        uint256 _begin_period,
        uint256 _end_period
    ) Ownable(msg.sender) {
        target_token = _target_token;
        pool = _pool;
        THperiod = THPeriodInterface(_THperiod);
        THraise = THUserProportionInterface(_raise);
        period_amount_contract = IPeriodAmount(_period_amount_contract);
        begin_period = _begin_period;
        end_period = _end_period;
    }

    function changePeriodAmountContract(address _contract) public onlyOwner {
        period_amount_contract = IPeriodAmount(_contract);
    }

    event THTRClaim(address addr, uint256 amount);

    function claim() public {
        uint256 period = THperiod.get_current_period();

        require(period > claimed_period[msg.sender], "no avaliable amount");
        require(period >= begin_period, "claim not start yet");
        require(period < end_period, "claim already end");

        (uint256 user_n, uint256 user_d) = THraise.user_proportion(msg.sender);
        require(user_n > 0, "no share");
        if (claimed_period[msg.sender] == 0) {
            claimed_period[msg.sender] = begin_period;
        }
        uint256 t = ((period - claimed_period[msg.sender]) *
            period_amount_contract.getPeriodAmount() *
            user_n) / user_d;
        claimed_period[msg.sender] = period;
        //require(t > 0, "no claimable share");
        TokenBankInterface(pool).issue(target_token, payable(msg.sender), t);
        emit THTRClaim(msg.sender, t);
    }
}

contract THTRDispatcherFactory {
    event NewTHTRDispatcher(address addr);

    function createTHTRDispatcher(
        address _target_token,
        address _pool,
        address _THperiod,
        address _THraise,
        address _period_amount_contract,
        uint256 _begin_period,
        uint256 _end_period
    ) public returns (address) {
        THTRDispatcher td = new THTRDispatcher(
            _target_token,
            _pool,
            _THperiod,
            _THraise,
            _period_amount_contract,
            _begin_period,
            _end_period
        );
        emit NewTHTRDispatcher(address(td));
        td.transferOwnership(msg.sender);
        return address(td);
    }
}
