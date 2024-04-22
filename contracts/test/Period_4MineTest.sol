// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {THPeriodInterface} from "../THPeriodInterface.sol";

contract THPeriod_for_mine_test is THPeriodInterface {
    uint256 public currentPeriod;

    function changeCurrentPeriod(uint256 _currentPeriod) public {
        currentPeriod = _currentPeriod;
    }

    function current_period() public view returns (uint256) {
        return currentPeriod;
    }

    function get_current_period() public view returns (uint256) {
        return currentPeriod;
    }
}
