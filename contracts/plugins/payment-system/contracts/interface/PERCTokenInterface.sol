// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface PERCTokenInterface {
    function generateTokens(
        address _owner,
        uint _amount
    ) external returns (bool);

    function burn(address _owner, uint _amount) external returns (bool);
}