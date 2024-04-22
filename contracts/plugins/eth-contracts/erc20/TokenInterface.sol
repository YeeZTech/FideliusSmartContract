// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface TokenInterface {
    function destroyTokens(
        address _owner,
        uint _amount
    ) external returns (bool);

    function generateTokens(
        address _owner,
        uint _amount
    ) external returns (bool);
}
