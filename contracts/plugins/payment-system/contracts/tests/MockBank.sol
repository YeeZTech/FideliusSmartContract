// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/plugins/eth-contracts/MultiSigTools.sol";
import "contracts/plugins/eth-contracts/TrustListTools.sol";
import "contracts/plugins/eth-contracts/utils/TokenClaimer.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import "contracts/plugins/eth-contracts/erc20/IERC20.sol";
import "contracts/plugins/eth-contracts/erc20/SafeERC20.sol";

contract MockBank is Ownable, TokenClaimer {
    using SafeERC20 for IERC20;

    string public bank_name;
    //address public erc20_token_addr;

    event withdraw_token(address token, address to, uint256 amount);
    event issue_token(address token, address to, uint256 amount);

    event RecvETH(uint256 v);

    receive() external payable {
        emit RecvETH(msg.value);
    }

    constructor(string memory name) {
        bank_name = name;
    }

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
            "TestBank not enough tokens"
        );
        if (erc20_token_addr == address(0x0)) {
            (bool _success, ) = to.call{value: tokens}("");
            require(_success, "TestBank transfer eth failed");
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
    ) public returns (bool success) {
        require(
            _amount <= balance(erc20_token_addr),
            "TestBank not enough tokens"
        );
        if (erc20_token_addr == address(0x0)) {
            (bool _success, ) = _to.call{value: _amount}("");
            require(_success, "TestBank transfer eth failed");
            emit issue_token(erc20_token_addr, _to, _amount);
            return true;
        }
        IERC20(erc20_token_addr).safeTransfer(_to, _amount);
        emit issue_token(erc20_token_addr, _to, _amount);
        return true;
    }
}

contract MockBankFactory {
    event CreateTokenBank(string name, address addr);

    function newTestBank(string memory name) public returns (address) {
        MockBank addr = new MockBank(name);
        emit CreateTokenBank(name, address(addr));
        addr.transferOwnership(msg.sender);
        return address(addr);
    }
}
