// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MultiSigTools} from "../MultiSigTools.sol";
import {TokenClaimer} from "../utils/TokenClaimer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract TokenBankV2 is
    OwnableUpgradeable,
    TokenClaimer,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;

    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    string public bank_name;
    //address public erc20_token_addr;

    event withdraw_token(address token, address to, uint256 amount);
    event issue_token(address token, address to, uint256 amount);

    event RecvETH(uint256 v);

    receive() external payable {
        emit RecvETH(msg.value);
    }

    function initialize(string memory name) public initializer {
        __Ownable_init(msg.sender);
        bank_name = name;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // constructor(string memory name) {
    //     bank_name = name;
    // }

    function claimStdTokens(
        address _token,
        address payable to
    ) public onlyOwner {
        _claimStdTokens(_token, to);
    }

    function balance(address erc20_token_addr) public view returns (uint) {
        if (erc20_token_addr == address(0x0)) {
            return address(this).balance;
        }
        return IERC20(erc20_token_addr).balanceOf(address(this));
    }

    function transfer(
        address erc20_token_addr,
        address payable to,
        uint tokens
    ) public onlyOwner returns (bool success) {
        require(
            tokens <= balance(erc20_token_addr),
            "TokenBankV2 not enough tokens"
        );
        if (erc20_token_addr == address(0x0)) {
            (bool _success, ) = to.call{value: tokens}("");
            require(_success, "TokenBankV2 transfer eth failed");
            emit withdraw_token(erc20_token_addr, to, tokens);
            return true;
        }
        IERC20(erc20_token_addr).safeTransfer(to, tokens);
        emit withdraw_token(erc20_token_addr, to, tokens);
        return true;
    }

    function issue(
        address erc20_token_addr,
        address payable _to,
        uint _amount
    ) public onlyRole(TRUSTED_ROLE) returns (bool success) {
        require(
            _amount <= balance(erc20_token_addr),
            "TokenBankV2 not enough tokens"
        );
        if (erc20_token_addr == address(0x0)) {
            (bool _success, ) = _to.call{value: _amount}("");
            require(_success, "TokenBankV2 transfer eth failed");
            emit issue_token(erc20_token_addr, _to, _amount);
            return true;
        }
        IERC20(erc20_token_addr).safeTransfer(_to, _amount);
        emit issue_token(erc20_token_addr, _to, _amount);
        return true;
    }
}

// contract TokenBankV2Factory {
//     event CreateTokenBank(string name, address addr);

//     function newTokenBankV2(string memory name) public returns (address) {
//         TokenBankV2 addr = new TokenBankV2(name);
//         emit CreateTokenBank(name, address(addr));
//         addr.transferOwnership(msg.sender);
//         return address(addr);
//     }
// }
