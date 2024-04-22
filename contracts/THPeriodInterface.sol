// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface THPeriodInterface {
    function current_period() external view returns (uint256);

    function get_current_period() external returns (uint256);
}
