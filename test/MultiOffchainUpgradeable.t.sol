// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXKeyVerifierFactory, SGXKeyVerifier} from "contracts/market/SGXKeyVerifier.sol";
import {SGXProgramStore, SGXProgramStoreFactory} from "contracts/market/SGXProgramStore.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "contracts/market/SGXStaticDataMarketPlace.sol";
import {SGXDataMarketCommonImplV1Upgradeable} from "contracts/market/common/SGXDataMarketCommonImplV1Upgradeable.sol";

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

contract SGXMultiOffChainResultMarketUpgradeableTest is DeployHelper {
    using stdJson for string;
    SGXKeyVerifier verifier;
    bytes pkey;
    bytes32 program_hash;
    string path =
        string.concat(
            vm.projectRoot(),
            "/test/file/multi_offchain_summary.json"
        );
    string json = vm.readFile(path);

    bytes32 enclave_hash;
    bytes32 data_hash1;
    bytes32 data_hash2;
    bytes pkey_data1;
    bytes pkey_data2;
    bytes hash_sig1;
    bytes hash_sig2;
    bytes secret;
    bytes input;
    bytes forward_sig;
    bytes pkey_request;
    bytes sig_ready;
    bytes32 result_hash;
    bytes skey;
    bytes sig_submit;
    bytes32 data_vhash1;
    bytes32 data_vhash2;

    function setUp() public {
        setUpEnv();
        sgxDataMarketCommon.changeMarket(
            address(sgxStaticDataMarketPlaceUpgradeable)
        );

        sgxDataMarketCommonImplV1Upgradeable = new SGXDataMarketCommonImplV1Upgradeable(); //common_impl
        sgxDataMarketCommon.changeDataLib(
            address(sgxDataMarketCommonImplV1Upgradeable)
        );

        console2.log(
            "common_impl: ",
            address(sgxDataMarketCommonImplV1Upgradeable)
        );

        sgxDataMarketCommon.changeConfirmProxy(address(paymentPool));

        //test later
        //sgxMultiOffChainResultMarketUpgradeable.changeConfirmProxy(address(paymentPool));

        // paymentPool.grantRole(
        //     TRUSTED_ROLE,
        //     address(sgxMultiOnChainResultMarketUpgradeable)
        // );
        // paymentPool.grantRole(
        //     TRUSTED_ROLE,
        //     address(sgxMultiOffChainResultMarketUpgradeable)
        // );
        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxStaticDataMarketPlaceUpgradeable)
        );
        //paymentPool.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));

        console2.log(address(0x0));
        //deal(address(percToken), address(this), 1000000000);
        //percToken.generateTokens(address(this), 1000000000);

        //upload program and data
        enclave_hash = json.readBytes32(".enclave_hash");
        data_hash1 = json.readBytes32(".input[0].input_data_hash");
        hash_sig1 = json.readBytes(".input[0].hash_sig");
        pkey_data1 = json.readBytes(".input[0].public-key");
        assertEq(
            data_hash1,
            0xa6f468b0f1c830a7e26ccecb2d5990ad3c27004bf6fc05ea53eda73c83f4cdc2
        );
        data_hash2 = json.readBytes32(".input[1].input_data_hash");
        hash_sig2 = json.readBytes(".input[1].hash_sig");
        pkey_data2 = json.readBytes(".input[1].public-key");
        //requestOffChain
        secret = json.readBytes(".request_info.shu_info.encrypted_skey");
        input = json.readBytes(".analyzer-input");
        forward_sig = json.readBytes(".request_info.shu_info.forward_sig");
        pkey_request = json.readBytes(".request_info.analyzer-pkey");
        //submitOffChainResultReady && remindCost
        sig_ready = json.readBytes(".cost-signature");
        // requestOffChainSkey
        result_hash = json.readBytes32(".result_hash");
        // submitOffChainSkey
        skey = json.readBytes(".result_encrypt_key");
        sig_submit = json.readBytes(".result-signature");

        //there some difference between ganache test and normal (the former doesn't has a proxy)
        percToken.changeProxyRequire(false);
    }

    function test_multiOffchainMarketUpgradeable() public {
        console2.log("ownerproxy out:", address(ownerProxy));
        sgxStaticDataMarketPlaceUpgradeable.changeFee(0);
        sgxStaticDataMarketPlaceUpgradeable.changeFeePool(payable(address(0)));
        // init
        percToken.generateTokens(account3.addr, 10 ** 6);
        percToken.generateTokens(account4.addr, 10 ** 6);
        // upload program
        program_hash = sgxProgramStoreUpgradeable.upload_program(
            "test_url",
            500,
            enclave_hash
        );
        // upload data
        //we use program_hash as format_lib_hash, it's a mock
        console2.log("common in test:", address(sgxDataMarketCommon));

        vm.prank(account1.addr);
        data_vhash1 = sgxDataMarketCommon.createStaticData(
            data_hash1,
            "test env",
            5000,
            pkey_data1,
            hash_sig1
        );
        vm.prank(account2.addr);
        data_vhash2 = sgxDataMarketCommon.createStaticData(
            data_hash2,
            "test env",
            5000,
            pkey_data2,
            hash_sig2
        );
        bytes32[] memory data_vhashes = new bytes32[](2);
        data_vhashes[0] = data_vhash1;
        data_vhashes[1] = data_vhash2;
        // request offchain
        uint256 gas_price = 10 ** 10;
        uint256 amount = 10 ** 3;
        vm.prank(account3.addr);
        percToken.approve(
            address(sgxMultiOffChainResultMarketUpgradeable),
            10 ** 15
        );
        vm.prank(account3.addr);

        (
            bytes32 vhash,
            bytes32 request_hash
        ) = sgxMultiOffChainResultMarketUpgradeable.requestOffChain(
                data_vhashes,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey_request,
                amount
            );
        // remind cost
        uint256 gap = sgxMultiOffChainResultMarketUpgradeable.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);
        // result ready
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarketUpgradeable.submitOffChainResultReady(
            vhash,
            request_hash,
            0,
            sig_ready,
            result_hash
        );
        // request Skey
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarketUpgradeable.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        );
        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarketUpgradeable.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
        // refund request by another account
        console2.log("refund payment: ", gap);
        vm.prank(account4.addr);
        percToken.approve(
            address(sgxMultiOffChainResultMarketUpgradeable),
            10 ** 15
        );
        vm.prank(account4.addr);
        sgxMultiOffChainResultMarketUpgradeable.refundRequest(
            vhash,
            request_hash,
            gap
        );
        console2.log("request info:");
        {
            (
                address from,
                bytes memory pkey4v,
                bytes memory secret_,
                bytes memory input_,
                bytes memory forward_sig_,
                bytes32 program_hash_,
                bytes32 result_hash_
            ) = sgxStaticDataMarketPlaceUpgradeable.getRequestInfo1(
                    vhash,
                    request_hash
                );
            console2.logAddress(from);
            console2.logBytes(pkey4v);
            console2.logBytes(secret_);
            console2.logBytes(input_);
            console2.logBytes(forward_sig_);
            console2.logBytes32(program_hash_);
            console2.logBytes32(result_hash_);
        }
        // Submit Skey again - sufficient amount
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarketUpgradeable.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
        // Check each acounts' balance
        assertEq(percToken.balanceOf(address(this)), 500, "account0 balance");
        assertEq(percToken.balanceOf(account1.addr), 5000, "account1 balance");
        assertEq(percToken.balanceOf(account2.addr), 5000, "account2 balance");
        assertEq(
            percToken.balanceOf(account3.addr),
            999000,
            "account3 balance"
        );
        assertEq(
            percToken.balanceOf(account4.addr),
            990500,
            "account4 balance"
        );
        assertEq(
            percToken.balanceOf(address(sgxStaticDataMarketPlaceUpgradeable)),
            0,
            "market balance"
        );
    }
}
