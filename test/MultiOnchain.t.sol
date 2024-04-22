// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXKeyVerifierFactory, SGXKeyVerifier} from "contracts/market/SGXKeyVerifier.sol";
import {SGXProgramStore, SGXProgramStoreFactory} from "contracts/market/SGXProgramStore.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "contracts/market/SGXStaticDataMarketPlace.sol";
import {ERC20Token, ERC20TokenFactory} from "contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
import {TokenBankV2} from "contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {TrustList, TrustListFactory} from "contracts/plugins/eth-contracts/TrustList.sol";
import {SGXOnChainResultMarketImplV1} from "contracts/market/onchain/SGXOnChainResultMarketImplV1.sol";
import {SGXMultiOnChainResultMarket} from "contracts/market/multi_onchain/SGXMultiOnChainResultMarket.sol";
import {SGXDataMarketCommon} from "contracts/market/common/SGXDataMarketCommon.sol";
import {SGXRequest} from "contracts/market/SGXRequest.sol";

import "contracts/test/USDT.sol";

import {DeployHelper} from "test/DeployHelper.sol";
import "forge-std/Test.sol";

// import "forge-std/console2.sol";

// const SGXOnChainResultMarket = artifacts.require("SGXOnChainResultMarket");
// const { StepRecorder } = require("./util.js");

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

contract SGXMultiOnChainResultMarketTest is DeployHelper {
    //   let factory = {};
    SGXKeyVerifier verifier;
    bytes pkey;
    bytes32 program_hash;

    function setUp() public {
        setUpEnv();
        //deal(address(percToken), address(this), 1000000000);
        percToken.generateTokens(address(this), 1000000000);
    }

    function test_multiOnchainMarket() public {
        //-------------------upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            0,
            0x80badd1e7f5f749873522cf0f921e4510ba80666d7e7e98375e3f12683641f86
        );
        //-------------------upload data
        bytes32 dhash1 = 0xa6f468b0f1c830a7e26ccecb2d5990ad3c27004bf6fc05ea53eda73c83f4cdc2;
        bytes
            memory hash_sig1 = hex"472e9ad362aea51738a3bffc3e4c6bd47239b8488230ff0429811059a2ac311a20bb944bd94d9bf4668fdf76f1606e79e0c023cbe5b1b923718d1dd921696ac91c";
        bytes
            memory pkey1 = hex"1dded5db8e469ec0e1c84ed7a1cd1cca17a8bed64c3d37ec7534d6dfcbe2328915f141aefc425cf910253e68e91a1069582d5712486cd0b18c53c8a95a89fb82";
        bytes32 dhash2 = 0x311d09ae35b391f9fb0a3a58d0abf0f886d02f58150067814bbb92a1da642937;
        bytes
            memory hash_sig2 = hex"9b58c4389dd6b192d701bfac77cc6c13cd21b9ef7730e2e28bedfb4e06a00c987700b71a94e896e7fb461b94e5652d8ca430cd4559a4669c581e149c0bc525411b";
        bytes
            memory pkey2 = hex"7382a40d02bfe2fd5c21085a8ddd9c4935cfb9c927121f1174e87e72a0d85e0eaaff2e8369aa7bfa749da61f6a75102b673d29bd13b0f3655a0742faddb7f001";
        bytes32 data_vhash1 = sgxDataMarketCommon.createStaticData(
            dhash1,
            "test env",
            0,
            pkey1,
            hash_sig1
        );
        bytes32 data_vhash2 = sgxDataMarketCommon.createStaticData(
            dhash2,
            "test env",
            0,
            pkey2,
            hash_sig2
        );
        //---------------submit request
        bytes
            memory secret = hex"6a8116af37eaf1d902d0b56c9609812a1cb18cfe706588f03701d1c34df0f6b68ebdc29b04297de4a93fb3340ef726495b5b4e46a288f02f031d6dddf4cbfa24cbe17988a465f0c9f2898c78d7923adc72125ba8854d5ce30b57a780ccd524e318fb4ef9e8e071d695fc565d250dab7f0b25e9d68887f23dfab8a54d";
        bytes
            memory input = hex"c6f21b568e8cab53758eabbb1e70ab68fb8259f72af51b5d232d93532c12e74ee661b212a34509a9c30f0b5ac31cc2cc3f41f59e9e1996a9274fe48dcc63009e276ff551823f127b534729b40885f9bed5508ecfaa52817e2d47b29d48119ac42c2f1ff067c2905d126e2c1cdf6afbdecbb1eff50f7559ae7bbd";
        bytes
            memory forward_sig = hex"18afb52a3d2ace61679b43f79cbb91916d0db7cdcda861ea4b310d140e163da82c94edbbc8282517894bb3cb35a58c51cb1f071fd0450ea51906918634528d101c";
        uint256 gas_price = 0;
        pkey = hex"3081b9c5c5b8eeb666358f476ba3b4a2c637db27e91a8674e8def379fe5e8ec514dd4302e997b35b0705de9a7d781858f0d663ce5189eee2652ea87e289423c0";
        bytes32[] memory data_vhashes = new bytes32[](2);
        data_vhashes[0] = data_vhash1;
        data_vhashes[1] = data_vhash2;
        percToken.approve(
            address(sgxMultiOnChainResultMarket),
            1000000000000000
        );
        SGXMultiOnChainResultMarket.RequestParam
            memory param = SGXMultiOnChainResultMarket.RequestParam(
                secret,
                input,
                forward_sig,
                program_hash,
                pkey
            );
        bytes32 confirm_hash;

        vm.recordLogs();
        (bytes32 data_vhash, bytes32 request_hash) = sgxMultiOnChainResultMarket
            .requestOnChain(data_vhashes, param, gas_price, 1000);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console2.log("entries length: ", entries.length);

        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(1))));
            }
        }

        console2.log("data_vhash:");
        console2.logBytes32(data_vhash);
        console2.log("request:");
        console2.logBytes32(request_hash);
        {
            (
                bytes32 data_hash,
                string memory extra_info,
                uint256 price,
                bytes memory pkey11,
                address owner,
                bool removed,
                uint256 revoke_timeout_block_num,
                bool exists
            ) = sgxStaticDataMarketPlace.getDataInfo(data_vhash);

            console2.logBytes32(data_hash);
            console2.log(extra_info);
            console2.logUint(price);
            console2.logBytes(pkey11);
            console2.logAddress(owner);
            console2.logBool(removed);
            console2.logUint(revoke_timeout_block_num);
            console2.logBool(exists);
        }
        console2.log("request info:");
        {
            (
                address target_token,
                uint gasprice,
                uint block_number,
                uint256 revoke_block_num,
                uint256 data_use_price,
                uint program_use_price,
                SGXRequest.RequestStatus status,
                SGXRequest.ResultType result_type
            ) = sgxStaticDataMarketPlace.getRequestInfo2(
                    data_vhash,
                    request_hash
                );
            console2.logAddress(target_token);
            console2.logUint(gasprice);
            console2.logUint(block_number);
            console2.logUint(revoke_block_num);
            console2.logUint(data_use_price);
            console2.logUint(program_use_price);
            console2.log(uint(status));
            console2.logUint(uint(result_type));
        }
        //----------------transfer commit--------------
        sgxMultiOnChainResultMarket.transferCommit(confirm_hash, true);
        //----------------submit result----------------
        bytes
            memory result = hex"d5e04c8c23c24b5642dbf5aa4bc91f75a95a78b47d2c8fa69effd48e11c869843f80c63a1357d2c87b1bb8129d3d3b2badd939614a293a18585c1654eb2acc05598230ffe01234d465d00526d9f2bc757d199acf9e5433fbc285181cbe4c413239214a898b6a18376169fda0cfa72ec23675c5574c94b04fbd";
        bytes
            memory result_signature = hex"9caf4c422fde7e9a2278d98bc14e26f4a0f3896b6ce09d5ee0eb1ae97652893d326acf2fbbfc89abe1a014706bc968d508b37321b71da91366333babe9d1b70a1b";

        sgxMultiOnChainResultMarket.submitOnChainResult(
            data_vhash,
            request_hash,
            0,
            result,
            result_signature
        );
    }

    function testWithPaymentTokenBeing0x0() public {
        //----------------init----------------
        address token = address(0x0);
        console2.log(token);
        // sgxMultiOnChainResultMarket->onchain_market
        // sgxStaticDataMarketPlace->market
        // sgxProgramStore ->program_store
        // sgxDataMarketCommon ->common_market
        sgxMultiOnChainResultMarket.changeMarket(
            address(sgxStaticDataMarketPlace)
        );
        console2.log("onchain market: ", address(sgxMultiOnChainResultMarket));
        sgxDataMarketCommon.changeMarket(address(sgxStaticDataMarketPlace));
        //----------------upload program----------------
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            0,
            0x80badd1e7f5f749873522cf0f921e4510ba80666d7e7e98375e3f12683641f86
        );
        //----------------upload data----------------
        bytes32 dhash1 = 0xa6f468b0f1c830a7e26ccecb2d5990ad3c27004bf6fc05ea53eda73c83f4cdc2;
        bytes
            memory hash_sig1 = hex"472e9ad362aea51738a3bffc3e4c6bd47239b8488230ff0429811059a2ac311a20bb944bd94d9bf4668fdf76f1606e79e0c023cbe5b1b923718d1dd921696ac91c";
        bytes
            memory pkey1 = hex"1dded5db8e469ec0e1c84ed7a1cd1cca17a8bed64c3d37ec7534d6dfcbe2328915f141aefc425cf910253e68e91a1069582d5712486cd0b18c53c8a95a89fb82";
        bytes32 dhash2 = 0x311d09ae35b391f9fb0a3a58d0abf0f886d02f58150067814bbb92a1da642937;
        bytes
            memory hash_sig2 = hex"9b58c4389dd6b192d701bfac77cc6c13cd21b9ef7730e2e28bedfb4e06a00c987700b71a94e896e7fb461b94e5652d8ca430cd4559a4669c581e149c0bc525411b";
        bytes
            memory pkey2 = hex"7382a40d02bfe2fd5c21085a8ddd9c4935cfb9c927121f1174e87e72a0d85e0eaaff2e8369aa7bfa749da61f6a75102b673d29bd13b0f3655a0742faddb7f001";
        bytes32 data_vhash1 = sgxDataMarketCommon.createStaticData(
            dhash1,
            "test env",
            0,
            pkey1,
            hash_sig1
        );
        bytes32 data_vhash2 = sgxDataMarketCommon.createStaticData(
            dhash2,
            "test env",
            0,
            pkey2,
            hash_sig2
        );
        //----------------submit request----------------
        bytes
            memory secret = hex"6a8116af37eaf1d902d0b56c9609812a1cb18cfe706588f03701d1c34df0f6b68ebdc29b04297de4a93fb3340ef726495b5b4e46a288f02f031d6dddf4cbfa24cbe17988a465f0c9f2898c78d7923adc72125ba8854d5ce30b57a780ccd524e318fb4ef9e8e071d695fc565d250dab7f0b25e9d68887f23dfab8a54d";
        bytes
            memory input = hex"c6f21b568e8cab53758eabbb1e70ab68fb8259f72af51b5d232d93532c12e74ee661b212a34509a9c30f0b5ac31cc2cc3f41f59e9e1996a9274fe48dcc63009e276ff551823f127b534729b40885f9bed5508ecfaa52817e2d47b29d48119ac42c2f1ff067c2905d126e2c1cdf6afbdecbb1eff50f7559ae7bbd";
        bytes
            memory forward_sig = hex"18afb52a3d2ace61679b43f79cbb91916d0db7cdcda861ea4b310d140e163da82c94edbbc8282517894bb3cb35a58c51cb1f071fd0450ea51906918634528d101c";
        uint256 gas_price = 0;
        pkey = hex"3081b9c5c5b8eeb666358f476ba3b4a2c637db27e91a8674e8def379fe5e8ec514dd4302e997b35b0705de9a7d781858f0d663ce5189eee2652ea87e289423c0";
        bytes32[] memory data_vhashes = new bytes32[](2);
        data_vhashes[0] = data_vhash1;
        data_vhashes[1] = data_vhash2;
        percToken.approve(
            address(sgxMultiOnChainResultMarket),
            1000000000000000
        );
        SGXMultiOnChainResultMarket.RequestParam
            memory param = SGXMultiOnChainResultMarket.RequestParam(
                secret,
                input,
                forward_sig,
                program_hash,
                pkey
            );

        bytes32 confirm_hash;

        vm.recordLogs();
        (bytes32 data_vhash, bytes32 request_hash) = sgxMultiOnChainResultMarket
            .requestOnChain(data_vhashes, param, gas_price, 1000);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console2.log("entries length: ", entries.length);

        console2.log("data_vhash: ");
        console2.logBytes32(data_vhash);
        console2.log("request: ");
        console2.logBytes32(request_hash);

        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(1))));
            }
        }

        {
            DataInfo memory dataInfo;
            (
                dataInfo.data_hash,
                dataInfo.extra_info,
                dataInfo.price,
                dataInfo.pkey,
                dataInfo.owner,
                dataInfo.removed,
                dataInfo.revoke_timeout_block_num,
                dataInfo.exists
            ) = sgxStaticDataMarketPlace.getDataInfo(data_vhash);
            console2.log("\n dataInfo: \n data_hash:");
            console2.logBytes32(dataInfo.data_hash);
            console2.log("extra_info:");
            console2.log(dataInfo.extra_info);
            console2.log("price:");
            console2.logUint(dataInfo.price);
            console2.log("pkey:");
            console2.logBytes(dataInfo.pkey);
            console2.log("owner:");
            console2.logAddress(dataInfo.owner);
            console2.log("removed:");
            console2.logBool(dataInfo.removed);
            console2.log("revoke_timeout_block_num:");
            console2.logUint(dataInfo.revoke_timeout_block_num);
            console2.log("exists:");
            console2.logBool(dataInfo.exists);
        }

        //----------------transfer commit--------------
        sgxMultiOnChainResultMarket.transferCommit(confirm_hash, true);

        //----------------submit cost----------------
        // uint64 cost = 12876;
        // bytes
        //     memory cost_sig = hex"8de4601130a5f12b1f97ad52ebbf9c4cd3aa2ea24c86ea596970e131e0f55e427f9d3c2e83c2dbbfe6c031bdeb58327a53c8525a7ec5b59ba3287e35cd18d5731c";
        // uint256 gap = sgxMultiOnChainResultMarket.remindRequestCost(
        //     data_vhash,
        //     request_hash,
        //     cost,
        //     cost_sig
        // );
        // console2.log("gap: ", gap);
        //----------------submit result----------------
        bytes
            memory result = hex"d5e04c8c23c24b5642dbf5aa4bc91f75a95a78b47d2c8fa69effd48e11c869843f80c63a1357d2c87b1bb8129d3d3b2badd939614a293a18585c1654eb2acc05598230ffe01234d465d00526d9f2bc757d199acf9e5433fbc285181cbe4c413239214a898b6a18376169fda0cfa72ec23675c5574c94b04fbd";

        bytes
            memory result_signature = hex"9caf4c422fde7e9a2278d98bc14e26f4a0f3896b6ce09d5ee0eb1ae97652893d326acf2fbbfc89abe1a014706bc968d508b37321b71da91366333babe9d1b70a1b";
        sgxMultiOnChainResultMarket.submitOnChainResult(
            data_vhash,
            request_hash,
            0,
            result,
            result_signature
        );
    }

    function testPriceNot0() public {
        //----------------init----------------
        // sgxMultiOnChainResultMarket->onchain_market
        // sgxStaticDataMarketPlace->market
        // sgxProgramStore ->program_store
        // sgxDataMarketCommon ->common_market

        sgxStaticDataMarketPlace.changeFee(0);
        sgxStaticDataMarketPlace.changeFeePool(payable(address(0)));

        SGXKeyVerifier verifier = new SGXKeyVerifier();
        verifier.set_verifier_addr(
            address(0xf4267391072B27D76Ed8f2A9655BCf5246013F2d),
            true
        );

        //----------------upload program----------------
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            0x80badd1e7f5f749873522cf0f921e4510ba80666d7e7e98375e3f12683641f86
        );
        //----------------upload data----------------
        bytes32 dhash1 = 0xa6f468b0f1c830a7e26ccecb2d5990ad3c27004bf6fc05ea53eda73c83f4cdc2;
        bytes
            memory hash_sig1 = hex"472e9ad362aea51738a3bffc3e4c6bd47239b8488230ff0429811059a2ac311a20bb944bd94d9bf4668fdf76f1606e79e0c023cbe5b1b923718d1dd921696ac91c";
        bytes
            memory pkey1 = hex"1dded5db8e469ec0e1c84ed7a1cd1cca17a8bed64c3d37ec7534d6dfcbe2328915f141aefc425cf910253e68e91a1069582d5712486cd0b18c53c8a95a89fb82";
        bytes32 dhash2 = 0x311d09ae35b391f9fb0a3a58d0abf0f886d02f58150067814bbb92a1da642937;
        bytes
            memory hash_sig2 = hex"9b58c4389dd6b192d701bfac77cc6c13cd21b9ef7730e2e28bedfb4e06a00c987700b71a94e896e7fb461b94e5652d8ca430cd4559a4669c581e149c0bc525411b";
        bytes
            memory pkey2 = hex"7382a40d02bfe2fd5c21085a8ddd9c4935cfb9c927121f1174e87e72a0d85e0eaaff2e8369aa7bfa749da61f6a75102b673d29bd13b0f3655a0742faddb7f001";

        bytes32 data_vhash1 = sgxDataMarketCommon.createStaticData(
            dhash1,
            "test env",
            5000,
            pkey1,
            hash_sig1
        );
        bytes32 data_vhash2 = sgxDataMarketCommon.createStaticData(
            dhash2,
            "test env",
            5000,
            pkey2,
            hash_sig2
        );
        //----------------submit request----------------
        bytes
            memory secret = hex"6a8116af37eaf1d902d0b56c9609812a1cb18cfe706588f03701d1c34df0f6b68ebdc29b04297de4a93fb3340ef726495b5b4e46a288f02f031d6dddf4cbfa24cbe17988a465f0c9f2898c78d7923adc72125ba8854d5ce30b57a780ccd524e318fb4ef9e8e071d695fc565d250dab7f0b25e9d68887f23dfab8a54d";
        bytes
            memory input = hex"c6f21b568e8cab53758eabbb1e70ab68fb8259f72af51b5d232d93532c12e74ee661b212a34509a9c30f0b5ac31cc2cc3f41f59e9e1996a9274fe48dcc63009e276ff551823f127b534729b40885f9bed5508ecfaa52817e2d47b29d48119ac42c2f1ff067c2905d126e2c1cdf6afbdecbb1eff50f7559ae7bbd";
        bytes
            memory forward_sig = hex"18afb52a3d2ace61679b43f79cbb91916d0db7cdcda861ea4b310d140e163da82c94edbbc8282517894bb3cb35a58c51cb1f071fd0450ea51906918634528d101c";
        uint256 gas_price = 0;
        pkey = hex"3081b9c5c5b8eeb666358f476ba3b4a2c637db27e91a8674e8def379fe5e8ec514dd4302e997b35b0705de9a7d781858f0d663ce5189eee2652ea87e289423c0";
        bytes32[] memory data_vhashes = new bytes32[](2);
        data_vhashes[0] = data_vhash1;
        data_vhashes[1] = data_vhash2;
        uint256 l = percToken.balanceOf(address(this));
        percToken.destroyTokens(address(this), l);
        percToken.generateTokens(address(this), 1000000000);
        percToken.approve(address(sgxMultiOnChainResultMarket), 0);
        percToken.approve(
            address(sgxMultiOnChainResultMarket),
            1000000000000000
        );
        SGXMultiOnChainResultMarket.RequestParam
            memory param = SGXMultiOnChainResultMarket.RequestParam(
                secret,
                input,
                forward_sig,
                program_hash,
                pkey
            );

        bytes32 confirm_hash;
        vm.recordLogs();
        (bytes32 data_vhash, bytes32 request_hash) = sgxMultiOnChainResultMarket
            .requestOnChain(data_vhashes, param, gas_price, 10500);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console2.log("entries length: ", entries.length);

        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(1))));
            }
        }

        console2.log("data_vhash: ");
        console2.logBytes32(data_vhash);
        console2.log("request: ");
        console2.logBytes32(request_hash);

        {
            DataInfo memory dataInfo;
            (
                dataInfo.data_hash,
                dataInfo.extra_info,
                dataInfo.price,
                dataInfo.pkey,
                dataInfo.owner,
                dataInfo.removed,
                dataInfo.revoke_timeout_block_num,
                dataInfo.exists
            ) = sgxStaticDataMarketPlace.getDataInfo(data_vhash);
            console2.log("\n dataInfo: \n data_hash:");
            console2.logBytes32(dataInfo.data_hash);
            console2.log("extra_info:");
            console2.log(dataInfo.extra_info);
            console2.log("price:");
            console2.logUint(dataInfo.price);
            console2.log("pkey:");
            console2.logBytes(dataInfo.pkey);
            console2.log("owner:");
            console2.logAddress(dataInfo.owner);
            console2.log("removed:");
            console2.logBool(dataInfo.removed);
            console2.log("revoke_timeout_block_num:");
            console2.logUint(dataInfo.revoke_timeout_block_num);
            console2.log("exists:");
            console2.logBool(dataInfo.exists);
        }

        //----------------transfer commit--------------
        sgxMultiOnChainResultMarket.transferCommit(confirm_hash, true);
        //----------------submit cost--------------
        // uint64 cost = 12876;
        // bytes
        //     memory cost_sig = hex"8de4601130a5f12b1f97ad52ebbf9c4cd3aa2ea24c86ea596970e131e0f55e427f9d3c2e83c2dbbfe6c031bdeb58327a53c8525a7ec5b59ba3287e35cd18d5731c";
        // uint256 gap = sgxMultiOnChainResultMarket.remindRequestCost(
        //     data_vhash,
        //     request_hash,
        //     cost,
        //     cost_sig
        // );
        // console2.log("gap: ", gap);

        //----------------submit result--------------
        bytes
            memory result = hex"d5e04c8c23c24b5642dbf5aa4bc91f75a95a78b47d2c8fa69effd48e11c869843f80c63a1357d2c87b1bb8129d3d3b2badd939614a293a18585c1654eb2acc05598230ffe01234d465d00526d9f2bc757d199acf9e5433fbc285181cbe4c413239214a898b6a18376169fda0cfa72ec23675c5574c94b04fbd";
        bytes
            memory result_signature = hex"9caf4c422fde7e9a2278d98bc14e26f4a0f3896b6ce09d5ee0eb1ae97652893d326acf2fbbfc89abe1a014706bc968d508b37321b71da91366333babe9d1b70a1b";
        result_signature = hex"9caf4c422fde7e9a2278d98bc14e26f4a0f3896b6ce09d5ee0eb1ae97652893d326acf2fbbfc89abe1a014706bc968d508b37321b71da91366333babe9d1b70a1b";
        sgxMultiOnChainResultMarket.submitOnChainResult(
            data_vhash,
            request_hash,
            0,
            result,
            result_signature
        );
    }
}
