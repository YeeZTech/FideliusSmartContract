// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PaymentConfirmTool} from "./PaymentConfirmTool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PERCTokenInterface} from "./interface/PERCTokenInterface.sol";

contract TokenManagement is PaymentConfirmTool {
    PERCTokenInterface public token;

    constructor() Ownable(msg.sender) {}

    function generateTokens(address _owner, uint _amount) public onlyOwner {
        token.generateTokens(_owner, _amount);
    }

    function destroyTokens(
        address _owner,
        uint _amount
    ) public onlyOwner need_confirm {
        token.burn(_owner, _amount);
    }

    function changeToken(address _new) public onlyOwner {
        token = PERCTokenInterface(_new);
    }
}
