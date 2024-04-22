// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {SGXStaticData} from "../SGXStaticData.sol";
import {SGXStaticDataMarketStorage} from "../SGXStaticDataMarketStorage.sol";
import {SignatureVerifier} from "../SignatureVerifier.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SGXDataMarketPriceImplV1 is SGXStaticDataMarketStorage {
    using SGXStaticData for mapping(bytes32 => SGXStaticData.Data);
    using SignatureVerifier for bytes32;
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender) {}

    function changeDataPrice(
        bytes32 _vhash,
        uint256 new_price
    ) public returns (uint256) {
        require(!paused, "already paused to use");
        require(all_data[_vhash].exists, "data vhash not exist");
        uint256 old_price = all_data[_vhash].price;
        all_data[_vhash].price = new_price;
        return old_price;
    }
}
