// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PaymentConfirmTool} from "../PaymentConfirmTool.sol";
import {IPERC} from "../interface/IPERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenInterface} from "contracts/plugins/eth-contracts/erc20/TokenInterface.sol";
import {TokenBankInterface} from "contracts/plugins/eth-contracts/assets/TokenBankInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface BankInterface {
    function transfer(
        address payable to,
        uint tokens
    ) external returns (bool success);
}

contract UseCase is PaymentConfirmTool {
    using SafeERC20 for IERC20;
    address target_token;
    address recv;

    constructor(address _target_token, address _recv) Ownable(msg.sender) {
        target_token = _target_token;
        recv = _recv;
    }

    function buymulti(
        address a1,
        address a2,
        address _pool,
        uint256 amount
    ) public need_confirm {
        IERC20(target_token).safeTransferFrom(a1, address(this), amount);
        IERC20(target_token).safeTransferFrom(a2, _pool, amount);
    }

    function buy(uint256 amount) public need_confirm {
        IERC20(target_token).transferFrom(msg.sender, address(this), amount);
    }

    function burn(address a1, address a2, uint amount) public need_confirm {
        //TokenInterface(target_token).destroyTokens(a1, amount);
        //TokenInterface(target_token).destroyTokens(a2, amount);
        IPERC(target_token).burn(a1, amount);
        IPERC(target_token).burn(a2, amount);
    }

    function doTrade() public need_confirm {
        IERC20(target_token).safeTransfer(address(this), 100);
        IERC20(target_token).safeTransfer(recv, 100);
    }

    function pipeline(
        address s1,
        address s2,
        address r,
        uint256 amount
    ) public need_confirm {
        IERC20(target_token).safeTransferFrom(s1, address(this), amount);
        IERC20(target_token).safeTransfer(r, amount);
        IERC20(target_token).safeTransferFrom(s2, address(this), amount);
        IERC20(target_token).safeTransfer(r, amount);
    }

    function invalid_func() public {
        IERC20(target_token).safeTransfer(recv, 1);
    }

    function call_contract(
        address _bank,
        address payable _recv,
        uint256 amount
    ) public need_confirm {
        TokenBankInterface(_bank).issue(target_token, _recv, amount);
    }
}

contract UseCaseFactory {
    event CreateUseCase(address addr);

    function createUseCase(
        address _target_token,
        address _recv
    ) public returns (address) {
        UseCase addr = new UseCase(_target_token, _recv);
        emit CreateUseCase(address(addr));
        addr.transferOwnership(msg.sender);
        return address(addr);
    }
}
