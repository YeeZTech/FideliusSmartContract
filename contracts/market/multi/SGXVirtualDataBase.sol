// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SGXVirtualDataInterface} from "./SGXVirtualDataInterface.sol";
import {DataMarketPlaceInterface} from "../interface/DataMarketPlaceInterface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma experimental ABIEncoderV2;

//import "forge-std/Test.sol";

abstract contract SGXVirtualDataBase is Ownable {
    using SafeERC20 for IERC20;

    struct data_source_info {
        bytes32 data_vhash;
        uint256 data_price;
    }

    SGXVirtualDataInterface public virtual_lib_address;
    mapping(bytes32 => data_source_info[]) public data_sources;

    event NewVirtualData(bytes32 indexed vhash, bytes32[] vhashes);

    event ChangeVirtualDataLib(address old_lib, address new_lib);

    function changeVirtualDataLib(address _new_lib) public onlyOwner {
        address old = address(virtual_lib_address);
        virtual_lib_address = SGXVirtualDataInterface(_new_lib);
        emit ChangeVirtualDataLib(old, _new_lib);
    }

    function createVirtualData(
        DataMarketPlaceInterface market,
        bytes32[] memory _vhashes
    ) internal returns (bytes32) {
        bytes32 vhash;
        {
            //virtual_lib_address.createVirtualDataFromMultiData.selector;
            //bytes memory data;
            bytes memory data = abi.encodeWithSelector(
                virtual_lib_address.createVirtualDataFromMultiData.selector,
                _vhashes
            );
            bytes memory ret = market.delegateCallUseData(
                address(virtual_lib_address),
                data
            );
            (vhash) = abi.decode(ret, (bytes32));
        }

        // {
        //     bytes memory d2 = abi.encodeWithSignature(
        //         "internalTransferVirtualDataOwnership(bytes32,address)",
        //         vhash,
        //         msg.sender
        //     );
        //     market.delegateCallUseData(address(virtual_lib_address), d2);
        // }
        emit NewVirtualData(vhash, _vhashes);
        return vhash;
    }

    function recordDataSource(
        DataMarketPlaceInterface market,
        bytes32 request_hash,
        bytes32[] memory _vhashes
    ) internal {
        data_source_info[] storage dsi = data_sources[request_hash];
        for (uint i = 0; i < _vhashes.length; i++) {
            (, , uint256 price, , , , , ) = market.getDataInfo(_vhashes[i]);
            data_source_info memory dmi;
            dmi.data_price = price;
            dmi.data_vhash = _vhashes[i];
            dsi.push(dmi);
        }
    }

    function dispatchFee(
        DataMarketPlaceInterface market,
        bytes32 vhash,
        bytes32 request_hash,
        uint64 cost
    ) internal {
        address token = market.payment_token();
        if (token == address(0x0)) {
            return;
        }
        if (IERC20(token).balanceOf(address(this)) == 0) {
            return;
        }

        data_source_info[] storage dsi = data_sources[request_hash];
        for (uint i = 0; i < dsi.length; i++) {
            (, , , , address owner, , , ) = market.getDataInfo(
                dsi[i].data_vhash
            );
            IERC20(token).safeTransfer(owner, dsi[i].data_price);
        }
        (, uint256 gas_price, , , , , , ) = market.getRequestInfo2(
            vhash,
            request_hash
        );
        IERC20(token).safeTransfer(msg.sender, gas_price * cost);
    }

    function belongDataOwner(
        DataMarketPlaceInterface market,
        bytes32 request_hash,
        address addr
    ) public view returns (bool) {
        data_source_info[] storage dsi = data_sources[request_hash];
        for (uint i = 0; i < dsi.length; i++) {
            (, , , , address owner, , , ) = market.getDataInfo(
                dsi[i].data_vhash
            );
            if (owner == addr) {
                return true;
            }
        }
        return false;
    }
}
