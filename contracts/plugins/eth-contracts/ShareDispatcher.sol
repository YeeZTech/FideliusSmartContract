// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AddressArray} from "./utils/AddressArray.sol";
import {SafeMath} from "./utils/SafeMath.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import "./erc20/ERC20Impl.sol";
import {TokenBankInterface} from "./assets/TokenBankInterface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ShareProofInterface {
    function getHeightlist(uint n) external view returns (uint height);

    function totalSupplyAt(uint _blockNumber) external view returns (uint);

    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) external view returns (uint);

    function getCheckpointLength() external view returns (uint);
}

contract ShareDispatcher is Ownable {
    using SafeMath for uint;
    using AddressArray for address[];

    struct employee_info {
        uint claimed;
        uint last_block_num;
        uint pause_block_num;
        uint last_checkpoint_num;
        bool paused;
        uint remains;
    }

    TokenBankInterface public erc20bank;
    ShareProofInterface public share_proof;
    address public share_token;

    string public name;
    mapping(address => employee_info) public employee_infos;
    uint public unit_amount;
    uint public start_block;
    uint public total_issued;
    uint public last_issue_block;
    uint public total_claimed;
    uint public self_end_block;
    uint public remains_from_pause;

    event ClaimedShare(address account, address to, uint amount);

    constructor(
        string memory _name,
        address _erc20bank,
        address _share_token,
        address _share_proof,
        uint _unit_amount,
        uint _start_block
    ) {
        name = _name;
        erc20bank = TokenBankInterface(_erc20bank);
        share_token = _share_token;
        share_proof = ShareProofInterface(_share_proof);
        unit_amount = _unit_amount;
        start_block = _start_block;
        last_issue_block = _start_block;
    }

    function change_token_bank(address _addr) public onlyOwner {
        require(_addr != address(0x0), "invalid address");
        erc20bank = TokenBankInterface(_addr);
    }

    function balance() public view returns (uint) {
        return IERC20(share_token).balanceOf(address(erc20bank));
    }

    function get_current_checkpoint(uint _block) public view returns (uint) {
        uint len = share_proof.getCheckpointLength();
        if (len == 0) return 0;
        if (_block >= (share_proof.getCheckpointLength() - 1)) return len;
        if (_block < share_proof.getHeightlist(0)) return 0;
        // Binary search of the index+1 in the array
        uint min = 0;
        uint max = len - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (share_proof.getHeightlist(mid) <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min + 1;
    }

    function get_and_update_period_sum(
        address account,
        uint _end_block
    ) internal returns (uint) {
        uint end_checkpoint_num = get_current_checkpoint(_end_block);
        employee_info storage ei = employee_infos[account];
        if (ei.last_block_num == 0) {
            ei.last_block_num = start_block;
        }
        ei.last_checkpoint_num = get_current_checkpoint(ei.last_block_num);
        uint sum = 0;
        uint lb = ei.last_block_num;
        for (uint i = ei.last_checkpoint_num; i < end_checkpoint_num; i++) {
            if (share_proof.totalSupplyAt(lb) != 0) {
                sum = sum.safeAdd(
                    share_proof
                        .getHeightlist(i)
                        .safeSub(lb)
                        .safeMul(share_proof.balanceOfAt(account, lb))
                        .safeMul(unit_amount)
                        .safeDiv(share_proof.totalSupplyAt(lb))
                );
            }
            lb = share_proof.getHeightlist(i);
        }
        if (share_proof.totalSupplyAt(lb) != 0) {
            sum = sum.safeAdd(
                _end_block
                    .safeSub(lb)
                    .safeMul(share_proof.balanceOfAt(account, lb))
                    .safeMul(unit_amount)
                    .safeDiv(share_proof.totalSupplyAt(lb))
            );
        }
        ei.last_block_num = _end_block;
        return sum;
    }

    function total_unclaimed_amount() public view returns (uint) {
        return
            total_issued
                .safeAdd(
                    block.number.safeSub(last_issue_block).safeMul(unit_amount)
                )
                .safeSub(total_claimed)
                .safeSub(remains_from_pause);
    }

    function change_employee_status(
        address account,
        bool pause
    ) public onlyOwner {
        require(employee_infos[account].paused != pause, "status already done");
        _change_employee_status(account, pause);
    }

    function _change_employee_status(address account, bool pause) internal {
        employee_infos[account].paused = pause;
        if (pause) {
            employee_infos[account].pause_block_num = block.number;
            employee_infos[account].remains = get_and_update_period_sum(
                account,
                block.number
            );
        } else {
            remains_from_pause = remains_from_pause.safeAdd(
                get_and_update_period_sum(account, block.number)
            );
        }
    }

    function update_total() public {
        require(block.number >= start_block, "SD: not begin");
        total_issued = total_issued.safeAdd(
            block.number.safeSub(last_issue_block).safeMul(unit_amount)
        );
        last_issue_block = block.number;
    }

    function claim_share(address payable addr) public returns (bool) {
        update_total();
        employee_info storage ei = employee_infos[msg.sender];
        uint amount = 0;
        uint eb;
        eb = block.number;

        if ((self_end_block != 0) && (eb > self_end_block)) {
            eb = self_end_block;
        }
        if (!ei.paused) {
            amount = get_and_update_period_sum(msg.sender, eb);
        }
        amount = amount.safeAdd(ei.remains);
        ei.remains = 0;
        require(amount <= balance(), "bank out of money");
        erc20bank.issue(share_token, addr, amount);
        ei.claimed = ei.claimed.safeAdd(amount);
        total_claimed = total_claimed.safeAdd(amount);

        emit ClaimedShare(msg.sender, addr, amount);
        return true;
    }

    function get_employee_info_with_account(
        address account
    )
        public
        view
        returns (
            uint share,
            uint claimed,
            uint last_claim_block_num,
            uint paused_block_num,
            bool paused
        )
    {
        share = share_proof
            .balanceOfAt(account, block.number)
            .safeMul(unit_amount)
            .safeDiv(share_proof.totalSupplyAt(block.number));
        claimed = employee_infos[account].claimed;
        last_claim_block_num = employee_infos[account].last_block_num;
        paused = employee_infos[account].paused;
        paused_block_num = employee_infos[account].pause_block_num;
    }

    function set_self_end(uint _self_end) public onlyOwner {
        require(_self_end > last_issue_block, "input block too early");
        self_end_block = _self_end;
    }
}

contract ShareDispatcherFactory {
    event NewShareDispatcher(address addr);

    function createShareDispatcher(
        string memory name,
        address erc20bank,
        address share_address,
        address proof_address,
        uint unit_amount,
        uint start_block
    ) public returns (address) {
        ShareDispatcher dispatcher = new ShareDispatcher(
            name,
            erc20bank,
            share_address,
            proof_address,
            unit_amount,
            start_block
        );
        emit NewShareDispatcher(address(dispatcher));
        dispatcher.transferOwnership(msg.sender);
        return address(dispatcher);
    }
}
