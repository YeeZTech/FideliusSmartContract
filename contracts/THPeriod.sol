// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract THPeriod is Ownable {
    uint256 public length_base;
    uint256 public length_slope;
    uint256 public start_block;
    uint256 public current_period;
    uint256 public last_block;

    constructor(
        uint256 _start_block,
        uint256 _base,
        uint256 _slope
    ) Ownable(msg.sender) {
        start_block = _start_block;
        last_block = start_block;
        length_base = _base;
        length_slope = _slope;
        current_period = 0;
    }

    event THUpdatePeriod(uint256 old_period, uint256 new_period);

    function _update_period() internal {
        if (block.number < start_block) {
            return;
        }
        uint256 old = current_period;
        if (current_period == 0) {
            current_period = 1;
        }

        uint256 t = last_block +
            (current_period - 1) *
            length_slope +
            length_base;
        while (t <= block.number) {
            current_period++;
            last_block = t;
            t = t + (current_period - 1) * length_slope + length_base;
        }
        emit THUpdatePeriod(old, current_period);
    }

    function get_current_period() public returns (uint256) {
        _update_period();
        return current_period;
    }

    function update_period() public {
        _update_period();
    }

    event CurveInfoChanged(uint256 length_base, uint256 length_slope);

    function change_curve_info(uint256 _base, uint256 _slope) public onlyOwner {
        length_base = _base;
        length_slope = _slope;
        emit CurveInfoChanged(_base, _slope);
    }
}

contract THPeriodFactory {
    event NewTHPeriod(address addr);

    function createTHPeriod(
        uint256 _start_block,
        uint256 _base,
        uint256 _slope
    ) public returns (address) {
        THPeriod tp = new THPeriod(_start_block, _base, _slope);
        emit NewTHPeriod(address(tp));
        tp.transferOwnership(msg.sender);
        return address(tp);
    }
}
