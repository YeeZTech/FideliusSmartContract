// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Miscellaneous {
    function transferConfirmedAndApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) public {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "invalid amount");

        token.approve(to, 0);
        token.approve(to, amount);
    }
}
