// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SGXProxyBase} from "../SGXProxyBase.sol";
import {GasRewardTool} from "contracts/plugins/eth-contracts/plugins/GasRewardTool.sol";
import "../interface/DataMarketPlaceInterface.sol";

interface IMarketCommonPrice {
    function getDataOwner(bytes32 _vhash) external returns (address);
}

contract SGXDataMarketPrice is GasRewardTool, SGXProxyBase {
    event SDMarketChangeDataPrice(
        bytes32 indexed vhash,
        uint256 old_price,
        uint256 new_price
    );

    constructor() Ownable(msg.sender) {}

    function changeDataPrice(bytes32 _hash, uint256 new_price) public {
        address owner = getDataOwner(_hash);
        require(owner == msg.sender, "only data owner may change price");

        bytes memory d = abi.encodeWithSignature(
            "changeDataPrice(bytes32,uint256)",
            _hash,
            new_price
        );
        bytes memory ret = market.delegateCallUseData(data_lib_address, d);
        uint256 old_price = abi.decode(ret, (uint256));
        emit SDMarketChangeDataPrice(_hash, old_price, new_price);
    }

    function getDataOwner(bytes32 _vhash) public view returns (address) {
        return market.owner_proxy().ownerOf(_vhash);
    }
}
