// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPeriodAmount} from "./IPeriodAmount.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract THMintInterfaceForPA {
    uint256 public period_amount;
}

interface THTokenRaiseInterfaceForPA {
    function get_share_fraction() external view returns (uint256, uint256);
}

contract THTRDPeriodAmount is IPeriodAmount, Ownable {
    THTokenRaiseInterfaceForPA public THraise;
    THMintInterfaceForPA public minter;
    uint256 public TRfrac_n; // the fraction of TR
    uint256 public TRfrac_d;

    constructor(
        uint256 _n,
        uint256 _d,
        address _minter,
        address _raise
    ) Ownable(msg.sender) {
        TRfrac_n = _n;
        TRfrac_d = _d;
        minter = THMintInterfaceForPA(_minter);
        THraise = THTokenRaiseInterfaceForPA(_raise);
    }

    function getPeriodAmount() public view returns (uint256) {
        (uint256 share_n, uint256 share_d) = THraise.get_share_fraction();
        return
            (minter.period_amount() * share_n * TRfrac_n) / share_d / TRfrac_d;
    }
}

contract THTRDPeriodAmountFactory {
    event NewTHTRDPeriodAmount(address addr);

    function createTHTRDPeriodAmount(
        uint256 _n,
        uint256 _d,
        address _minter,
        address _raise
    ) public returns (address) {
        THTRDPeriodAmount pa = new THTRDPeriodAmount(_n, _d, _minter, _raise);
        emit NewTHTRDPeriodAmount(address(pa));
        pa.transferOwnership(msg.sender);
        return address(pa);
    }
}
