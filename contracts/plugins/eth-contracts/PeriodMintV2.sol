// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./utils/SafeMath.sol";
import "./utils/AddressArray.sol";
import "./utils/TokenClaimer.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import "./erc20/TokenInterface.sol";

contract PeriodMintV2 is Ownable {
    using SafeMath for uint;
    using AddressArray for address[];

    TokenInterface public token_contract;
    uint public last_block_num;
    uint public period_block_num;
    uint public period_share;
    uint public total_alloc_share;

    mapping(address => uint) public share_amounts;
    address[] public shareholders;

    address public admin;

    constructor(
        address _token,
        uint _start_block,
        uint _period,
        uint _period_share
    ) {
        token_contract = TokenInterface(_token);
        last_block_num = _start_block;
        period_block_num = _period;
        period_share = _period_share;
        total_alloc_share = 0;
        admin = address(0);
    }

    function issue() public {
        uint interval = block.number.safeSub(last_block_num);
        uint periods = interval.safeDiv(period_block_num);
        if (periods == 0) return;

        last_block_num = last_block_num.safeAdd(
            periods.safeMul(period_block_num)
        );
        uint total_allocation = total_alloc_share;
        uint total_shares = periods.safeMul(period_share);
        uint256 total = 0;
        for (uint i = 0; i < shareholders.length - 1; i++) {
            if (share_amounts[shareholders[i]] == 0) continue;
            uint t = share_amounts[shareholders[i]]
                .safeMul(total_shares)
                .safeDiv(total_allocation);
            token_contract.generateTokens(shareholders[i], t);
            total = total + t;
        }
        token_contract.generateTokens(
            shareholders[shareholders.length - 1],
            total_shares - total
        );
    }

    function shareholder_exists(address account) private view returns (bool) {
        return shareholders.exists(account);
    }

    function _internal_add_shareholder(address account, uint amount) private {
        require(amount > 0, "invalid amount");
        require(account != address(0), "invalid address");
        require(!shareholder_exists(account), "already exist");

        issue();

        shareholders.push(account);
        share_amounts[account] = amount;
        total_alloc_share = total_alloc_share.safeAdd(amount);
    }

    function add_shareholder(address account, uint amount) public onlyOwner {
        _internal_add_shareholder(account, amount);
    }

    function _internal_config_shareholder(
        address account,
        uint amount
    ) private {
        require(account != address(0x0), "invalid address");
        require(shareholder_exists(account), "not exist");

        issue();

        total_alloc_share = total_alloc_share.safeSub(share_amounts[account]);
        total_alloc_share = total_alloc_share.safeAdd(amount);
        share_amounts[account] = amount;
    }

    function config_shareholder(
        address account,
        uint amount
    ) external onlyOwner {
        _internal_config_shareholder(account, amount);
    }

    function _internal_remove_shareholder(address account) private {
        require(account != address(0), "invalid address");
        require(shareholder_exists(account), "not exist");
        issue();
        total_alloc_share = total_alloc_share.safeSub(share_amounts[account]);
        share_amounts[account] = 0;
        shareholders.remove(account);
    }

    function remove_shareholder(address account) public onlyOwner {
        _internal_remove_shareholder(account);
    }

    function get_total_allocation() public view returns (uint total) {
        return total_alloc_share;
    }

    function get_share(address account) public view returns (uint) {
        return share_amounts[account];
    }

    function status()
        public
        view
        returns (
            uint _last_block_num,
            uint _period_block_num,
            uint _period_share
        )
    {
        return (last_block_num, period_block_num, period_share);
    }

    function set_issue_period_param(
        uint block_num,
        uint share
    ) public onlyOwner {
        require(block_num > 0);
        require(share > 0);
        issue();
        period_block_num = block_num;
        period_share = share;
    }

    function get_shareholders_count() public view returns (uint) {
        return shareholders.length;
    }

    function get_shareholder_amount_with_index(
        uint index
    ) public view returns (address account, uint amount) {
        require(index >= 0 && index < shareholders.length);
        return (shareholders[index], share_amounts[shareholders[index]]);
    }
}

contract PeriodMintV2Factory {
    event NewPeriodMintFactory(address addr);

    function createPeriodMint(
        address _token,
        uint _start_block,
        uint _period,
        uint _period_share
    ) public returns (address) {
        PeriodMintV2 pm = new PeriodMintV2(
            _token,
            _start_block,
            _period,
            _period_share
        );
        emit NewPeriodMintFactory(address(pm));
        pm.transferOwnership(msg.sender);
        return address(pm);
    }
}
