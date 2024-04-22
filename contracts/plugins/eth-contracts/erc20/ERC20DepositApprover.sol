// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "../utils/SafeMath.sol";

interface TargetInterface {
    function deposit(uint256 _amount) external;
}

contract ERC20DepositApprover {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function allowance(
        address token,
        address owner,
        address spender
    ) public view returns (uint256) {
        return IERC20(token).allowance(owner, spender);
    }

    event ApproverDeposit(
        address from,
        address token,
        uint256 amount,
        address target,
        address target_lp_token,
        uint256 target_lp_amount
    );

    function deposit(
        address _token,
        uint256 _amount,
        address _target,
        address _target_lp_token
    ) public {
        require(_token != address(0x0), "invalid token");
        require(_target != address(0x0), "invalid target");
        require(
            IERC20(_token).allowance(msg.sender, address(this)) >= _amount,
            "ERC20DepositApprover: not enough allowance"
        );
        require(
            IERC20(_token).balanceOf(msg.sender) >= _amount,
            "ERC20DepositApprover: not enough balance"
        );

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        if (IERC20(_token).allowance(address(this), _target) != 0) {
            IERC20(_token).approve(_target, 0);
        }
        IERC20(_token).approve(_target, _amount);

        uint256 prev = 0;
        if (_target_lp_token != address(0x0)) {
            prev = IERC20(_target_lp_token).balanceOf(address(this));
        }
        TargetInterface(_target).deposit(_amount);

        uint256 _after = 0;
        uint256 delta = 0;
        if (_target_lp_token != address(0x0)) {
            _after = IERC20(_target_lp_token).balanceOf(address(this));
            delta = _after.safeSub(prev);
            if (delta > 0) {
                IERC20(_target_lp_token).safeTransfer(msg.sender, delta);
            }
        }
        emit ApproverDeposit(
            msg.sender,
            _token,
            _amount,
            _target,
            _target_lp_token,
            delta
        );
    }
}
