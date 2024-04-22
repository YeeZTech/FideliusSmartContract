// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXKeyVerifierFactory, SGXKeyVerifier} from "contracts/market/SGXKeyVerifier.sol";
import {SGXProgramStore, SGXProgramStoreFactory} from "contracts/market/SGXProgramStore.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "contracts/market/SGXStaticDataMarketPlace.sol";
import {ERC20Token, ERC20TokenFactory} from "../contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
import {TokenBankV2} from "../contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {TrustList, TrustListFactory} from "../contracts/plugins/eth-contracts/TrustList.sol";
import {SGXMultiOffChainResultMarket} from "contracts/market/multi_offchain/SGXMultiOffChainResultMarket.sol";
import "contracts/test/USDT.sol";

import {SGXDataMarketCommon} from "contracts/market/common/SGXDataMarketCommon.sol";
import {SGXRequest} from "contracts/market/SGXRequest.sol";

import {DeployHelper} from "test/DeployHelper.sol";

import {SGXRequest} from "contracts/market/SGXRequest.sol";

import "forge-std/Test.sol";

struct DataInfo {
    bytes32 data_hash;
    string extra_info;
    uint256 price;
    bytes pkey;
    address owner;
    bool removed;
    uint256 revoke_timeout_block_num;
    bool exists;
}

contract LocalTest is DeployHelper {
    using stdJson for string;
    SGXKeyVerifier verifier;

    function setUp() public {
        setUpEnv();
    }

    function test_upload_data() public {
        bytes32 data_hash1 = 0x7b743530e90f3c8ea7021158a284691ca4aa92319ad254e2534801c44cf62469;
        bytes
            memory hash_sig1 = hex"8ee1d44f4ed3f288eebe149099804d506b0bb02335c6277b87fcdce9d87fee970e18a9bad55cec0424d431bc5221aa3d3c604e314cb6a98b0d4fb482f0c630f21b";
        bytes
            memory pkey1 = hex"d2fc78c9299c7742fc5fe817e3d2d455dd2a80d28d16c0889c5f3f47abba839acf07913917b3ca3f39c2d451c71e7be565977abe1ce3c8822f9e424fb9e222d7";
        bytes32 data_vhash1 = sgxDataMarketCommon.createStaticData(
            data_hash1,
            "123",
            1000000,
            pkey1,
            hash_sig1
        );
    }
}
