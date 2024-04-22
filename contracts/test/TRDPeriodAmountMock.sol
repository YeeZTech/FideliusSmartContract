// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPeriodAmount} from "../IPeriodAmount.sol";

contract TRDPeriodAmountMock is IPeriodAmount {
    function getPeriodAmount() public pure returns (uint256) {
        return 1e18;
    }
}
