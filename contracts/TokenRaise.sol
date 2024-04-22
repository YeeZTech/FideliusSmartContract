// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "contracts/plugins/eth-contracts/erc20/ERC20Impl.sol";

contract THTokenRaise is Ownable {
    using SafeERC20 for IERC20;

    address payable public raise_pool; //to hold USDC

    mapping(address => uint256) raise_amounts;
    uint256 public total_raise;
    uint256 public start_block;
    uint256 public end_block;
    uint256 public estimate_amount; //10000000 USDT
    uint256 public total_share; //20000000 THToken
    address public fiat_token;

    constructor(
        uint256 _start_block,
        uint256 _end_block,
        uint256 _amount,
        address _token,
        uint256 _share,
        address payable _raise_pool
    ) Ownable(msg.sender) {
        require(_end_block >= _start_block, "invalid end_block");
        start_block = _start_block;
        end_block = _end_block;
        estimate_amount = _amount;
        fiat_token = _token;
        total_share = _share;
        raise_pool = _raise_pool;
    }

    //raise USDC
    event Raised(address addr, uint256 amount);

    function raise(uint256 amount) public {
        require(block.number >= start_block, "raise not start");
        require(!is_end(), "raise end");
        {
            uint256 mu = uint256(10) ** IERC20Metadata(fiat_token).decimals();
            require(amount >= mu, "require at least 1 unit token");
        }
        IERC20(fiat_token).safeTransferFrom(
            msg.sender,
            address(raise_pool),
            amount
        );
        raise_amounts[msg.sender] = raise_amounts[msg.sender] + amount;
        total_raise = total_raise + amount;
        emit Raised(msg.sender, amount);
    }

    function is_end() public view returns (bool) {
        return block.number > end_block;
    }

    function user_proportion(
        address addr
    ) public view returns (uint256, uint256) {
        return (raise_amounts[addr], total_raise);
    }

    function get_current_share() public view returns (uint256) {
        (uint256 frac_n, uint256 frac_d) = get_share_fraction();
        return (total_share * frac_n) / frac_d;
    }

    function get_share_fraction() public view returns (uint256, uint256) {
        if (total_raise <= estimate_amount) {
            return (total_raise, estimate_amount * 2 - total_raise);
        }
        // f/2000-f
        else {
            return (1, 1);
        }
    }

    function get_current_price() public view returns (uint256) {
        uint256 frac = (total_raise * 1e18) / estimate_amount / 2; //fraction of total raised to estimated in 1e18, f/2000
        if (total_raise <= estimate_amount) {
            return (uint256(1e18)) - frac;
        } else {
            return frac;
        }
    }

    event EndBlockChanged(uint256 end_block);

    function change_end_block(
        uint256 _end_block
    ) public onlyOwner returns (uint256) {
        end_block = _end_block;
        emit EndBlockChanged(_end_block);
        return _end_block;
    }

    event EstimateAmountChanged(uint256 amount);

    function change_estimate_amount(
        uint256 _estimate
    ) public onlyOwner returns (uint256) {
        estimate_amount = _estimate;
        emit EstimateAmountChanged(_estimate);
        return _estimate;
    }

    event ChangeRaisePool(address old_pool, address new_pool);

    function change_raise_pool(address payable new_pool) public onlyOwner {
        require(new_pool != address(0x0), "invalid new pool");
        emit ChangeRaisePool(raise_pool, new_pool);
        raise_pool = new_pool;
    }
}

contract THTokenRaiseFactory {
    event NewTHTokenRaise(address addr);

    function createTHTokenRaise(
        uint256 _start_block,
        uint256 _end_block,
        uint256 _amount,
        address _token,
        uint256 _share,
        address payable _pool
    ) public returns (address) {
        THTokenRaise tr = new THTokenRaise(
            _start_block,
            _end_block,
            _amount,
            _token,
            _share,
            _pool
        );
        emit NewTHTokenRaise(address(tr));
        tr.transferOwnership(msg.sender);
        return address(tr);
    }
}
