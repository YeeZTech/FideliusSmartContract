// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenClaimer {
    event ClaimedTokens(
        address indexed _token,
        address indexed _to,
        uint _amount
    );

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function _claimStdTokens(address _token, address payable to) internal {
        if (_token == address(0x0)) {
            (bool s, ) = to.call{value: address(this).balance}("");

            require(s, "TokenClaimer transfer eth failed");
            return;
        }
        uint balance = IERC20(_token).balanceOf(address(this));

        (bool status, ) = _token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, balance)
        );
        require(status, "call failed");
        emit ClaimedTokens(_token, to, balance);
    }
}
