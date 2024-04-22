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

contract SGXMultiOffChainResultMarketTest is DeployHelper {
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

    // function test_temp_offchain() public {
    //     sgxStaticDataMarketPlace.changeFee(0);
    //     sgxStaticDataMarketPlace.changeFeePool(payable(address(0)));
    //     // init
    //     percToken.generateTokens(account3.addr, 10 ** 6);
    //     percToken.generateTokens(account4.addr, 10 ** 6);
    // }

    function test_multiOffchainMarket_basic() public {
        sgxStaticDataMarketPlace.changeFee(0);
        sgxStaticDataMarketPlace.changeFeePool(payable(address(0)));
        // init
        percToken.generateTokens(account3.addr, 10 ** 6);
        percToken.generateTokens(account4.addr, 10 ** 6);
        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );
        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        uint256 amount = 1000;
        vm.prank(account3.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);

        // sgxMultiOffChainResultMarket.
        vm.prank(account3.addr);
        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
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
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);
        // result ready
        vm.prank(account3.addr);
        bool r = sgxMultiOffChainResultMarket.submitOffChainResultReady(
            vhash,
            request_hash,
            0,
            sig_ready,
            result_hash
        );
        console2.log("submit offchain result ready return: ", r);
        // request Skey
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        );
        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
        // refund request by another account
        console2.log("refund payment: ", gap);
        vm.prank(account4.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);
        vm.prank(account4.addr);
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap);
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
            ) = sgxStaticDataMarketPlace.getRequestInfo1(vhash, request_hash);
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
        sgxMultiOffChainResultMarket.submitOffChainSkey(
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
            percToken.balanceOf(address(sgxStaticDataMarketPlace)),
            0,
            "market balance"
        );
    }

    function test_multiOffchainMarket_withProxy() public {
        sgxStaticDataMarketPlace.changeFee(0);
        sgxStaticDataMarketPlace.changeFeePool(payable(address(0)));
        percToken.changeProxyRequire(true);

        // init
        percToken.generateTokens(account3.addr, 10 ** 6);
        percToken.generateTokens(account4.addr, 10 ** 6);
        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );
        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        uint256 amount = 1000;
        vm.prank(account3.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);

        bytes32 confirm_hash;

        // sgxMultiOffChainResultMarket.
        vm.prank(account3.addr);
        vm.recordLogs();
        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
                data_vhashes,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey_request,
                amount
            ); // nonce = 1
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // console2.log("entries length: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                // 每次在使用Request时，都会有一个nonce记录这次transfer的序号（从1开始），调用StartTransfer时会使nonce+1，这个nonce会通过keccak256哈希作为RequestHash
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(1))));
            }
        }

        //----------------transfer commit--------------
        sgxMultiOffChainResultMarket.transferCommit(confirm_hash, true);

        // remind cost
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);
        // result ready
        vm.prank(account3.addr);
        vm.recordLogs();
        sgxMultiOffChainResultMarket.submitOffChainResultReady(
            vhash,
            request_hash,
            0,
            sig_ready,
            result_hash
        ); // nonce = 2
        entries = vm.getRecordedLogs();
        // console2.log("entries length: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(2))));
            }
        }
        //----------------transfer commit--------------
        sgxMultiOffChainResultMarket.transferCommit(confirm_hash, true);

        // request Skey
        vm.prank(account3.addr);
        vm.recordLogs();
        sgxMultiOffChainResultMarket.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        ); // 3
        entries = vm.getRecordedLogs();
        // console2.log("entries length: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(3))));
            }
        }
        //----------------transfer commit--------------
        sgxMultiOffChainResultMarket.transferCommit(confirm_hash, true);

        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        ); // nonce = 4 失败
        // refund request by another account
        console2.log("refund payment: ", gap);
        vm.prank(account4.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);

        vm.prank(account4.addr);
        vm.recordLogs();
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap); // nonce = 4
        entries = vm.getRecordedLogs();
        // console2.log("entries length: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(4))));
            }
        }
        //----------------transfer commit--------------
        sgxMultiOffChainResultMarket.transferCommit(confirm_hash, true);

        // console2.log("request info:");
        // {
        //     (
        //         address from,
        //         bytes memory pkey4v,
        //         bytes memory secret_,
        //         bytes memory input_,
        //         bytes memory forward_sig_,
        //         bytes32 program_hash_,
        //         bytes32 result_hash_
        //     ) = sgxStaticDataMarketPlace.getRequestInfo1(vhash, request_hash);
        //     console2.logAddress(from);
        //     console2.logBytes(pkey4v);
        //     console2.logBytes(secret_);
        //     console2.logBytes(input_);
        //     console2.logBytes(forward_sig_);
        //     console2.logBytes32(program_hash_);
        //     console2.logBytes32(result_hash_);
        // }

        // Submit Skey again - sufficient amount
        vm.prank(account3.addr);

        vm.recordLogs();
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        ); // nonce = 5
        entries = vm.getRecordedLogs();
        // console2.log("entries length: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (
                entries[i].topics[0] ==
                keccak256("PaymentConfirmRequest(bytes32)")
            ) {
                console2.log("entry index: ", i);
                confirm_hash = entries[i].topics[1];
                assertEq(confirm_hash, keccak256(abi.encodePacked(uint256(5))));
            }
        }
        //----------------transfer commit--------------
        sgxMultiOffChainResultMarket.transferCommit(confirm_hash, true);

        // // Check each acounts' balance
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
            percToken.balanceOf(address(sgxStaticDataMarketPlace)),
            0,
            "market balance"
        );
    }

    function test_multiOffchainMarketWithFee() public {
        // init
        percToken.generateTokens(account3.addr, 10 ** 6);
        percToken.generateTokens(account4.addr, 10 ** 6);
        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );
        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);
        vm.prank(account3.addr);

        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
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
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);
        // result ready
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.submitOffChainResultReady(
            vhash,
            request_hash,
            0,
            sig_ready,
            result_hash
        );
        // request Skey
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        );
        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
        // refund request by another account
        console2.log("refund payment: ", gap);
        vm.prank(account4.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);
        vm.prank(account4.addr);
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap);
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
            ) = sgxStaticDataMarketPlace.getRequestInfo1(vhash, request_hash);
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
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
        // Check each acounts' balance
        assertEq(percToken.balanceOf(address(this)), 1550, "account0 balance");
        assertEq(percToken.balanceOf(account1.addr), 5000, "account1 balance");
        assertEq(percToken.balanceOf(account2.addr), 5000, "account2 balance");
        assertEq(
            percToken.balanceOf(account3.addr),
            999000,
            "account3 balance"
        );
        // need add 9000 + 1050 + 500 = 10550
        assertEq(
            percToken.balanceOf(account4.addr),
            989450,
            "account4 balance"
        );
        assertEq(
            percToken.balanceOf(address(sgxStaticDataMarketPlace)),
            0,
            "market balance"
        );
    }

    function test_rejectRequest() public {
        sgxStaticDataMarketPlace.changeFee(0);
        sgxStaticDataMarketPlace.changeFeePool(payable(address(0)));
        // init
        percToken.generateTokens(account3.addr, 10 ** 6);
        percToken.generateTokens(account4.addr, 10 ** 6);
        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );
        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);
        vm.prank(account3.addr);

        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
                data_vhashes,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey_request,
                amount
            );

        vm.prank(account1.addr);
        sgxMultiOffChainResultMarket.rejectRequest(vhash, request_hash);

        (
            ,
            ,
            ,
            ,
            ,
            ,
            SGXRequest.RequestStatus status,

        ) = sgxStaticDataMarketPlace.getRequestInfo2(vhash, request_hash);
        assertEq(uint(status), uint(SGXRequest.RequestStatus.rejected));
    }

    function test_with_payment_token_being_0x0() public {
        // init market_no_payment
        SGXStaticDataMarketPlace market_no_payment;
        market_no_payment = new SGXStaticDataMarketPlace(
            address(sgxProgramStore),
            address(ownerProxy),
            address(0x0)
        );

        market_no_payment.grantRole(TRUSTED_ROLE, address(this));
        market_no_payment.grantRole(TRUSTED_ROLE, address(tokenManagement));
        market_no_payment.grantRole(TRUSTED_ROLE, address(paymentPool));
        market_no_payment.changeFee(100000);
        market_no_payment.changeFeePool(payable(address(this)));

        sgxMultiOffChainResultMarket.changeMarket(address(market_no_payment));
        market_no_payment.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarket)
        );

        sgxDataMarketCommon.changeMarket(address(market_no_payment));
        market_no_payment.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));
        paymentPool.grantRole(TRUSTED_ROLE, address(market_no_payment));

        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );

        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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

        console2.log("payment token: ", market_no_payment.payment_token());

        console2.log("percToken: ", address(percToken));

        console2.log("payment token: ", market_no_payment.payment_token());

        // sgxMultiOffChainResultMarket.changePaymentToken(token);

        vm.prank(account3.addr);
        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
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
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);

        // result ready
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.submitOffChainResultReady(
            vhash,
            request_hash,
            0,
            sig_ready,
            bytes32(sig_submit)
        );

        // request Skey
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        );

        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        // vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );

        // refund request by another account
        console2.log("refund payment: ", gap);
        vm.prank(account4.addr);
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap);
        // s = await market.getRequestInfo1(data_vhash, request_hash);
        // console.log("Request info: ", s);

        // Submit Skey again - sufficient amount
        // tx = await market.getDataInfo(data_vhash1);
        // console.log(tx);
        // tx = await market.getDataInfo(data_vhash2);
        // console.log(tx);
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );
    }

    function test_revoke() public {
        percToken.generateTokens(account3.addr, 10 ** 6);

        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );

        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        percToken.approve(address(sgxMultiOffChainResultMarket), 0);

        vm.prank(account3.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 10 ** 15);

        vm.prank(account3.addr);
        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
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
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            0,
            sig_ready
        );
        console2.log("gap: ", gap);

        // refund request
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap);
        // comsole2.log("request info:");

        // revoke by another account
        vm.prank(account2.addr);
        vm.expectRevert("only request owner can revoke");
        sgxMultiOffChainResultMarket.revokeRequest(vhash, request_hash);

        // revoke
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.revokeRequest(vhash, request_hash);

        // Submit Skey again - sufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("invalid status");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            0,
            skey,
            sig_submit
        );

        // Check each acounts' balance
        assertEq(percToken.balanceOf(address(this)), 0, "account0 balance");
        assertEq(percToken.balanceOf(account1.addr), 0, "account1 balance");
        assertEq(percToken.balanceOf(account2.addr), 0, "account2 balance");
        assertEq(
            percToken.balanceOf(account3.addr),
            1000000,
            "account3 balance"
        );
        assertEq(
            percToken.balanceOf(address(sgxStaticDataMarketPlace)),
            0,
            "market balance"
        );
    }

    function test_with_cost_not_being_0() public {
        percToken.generateTokens(account3.addr, 20000);

        // upload program
        program_hash = sgxProgramStore.upload_program(
            "test_url",
            500,
            enclave_hash
        );

        // upload data
        //we use program_hash as format_lib_hash, it's a mock
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
        uint256 gas_price = 1;
        uint256 amount = 1000;

        // 为了进入下一区块？？
        vm.prank(account3.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 0);

        vm.prank(account3.addr);
        percToken.approve(address(sgxMultiOffChainResultMarket), 20000);

        vm.prank(account3.addr);
        (bytes32 vhash, bytes32 request_hash) = sgxMultiOffChainResultMarket
            .requestOffChain(
                data_vhashes,
                secret,
                input,
                forward_sig,
                program_hash,
                gas_price,
                pkey_request,
                amount
            );
        //   console.log(
        //     "data_vhash: ",
        //     data_vhash,
        //     " --> ",
        //     await market.all_data(data_vhash)
        //   );

        {
            // (
            //     address target_token,
            //     uint gas_price,
            //     uint block_number,
            //     uint256 revoke_block_num,
            //     uint256 data_use_price,
            //     uint program_use_price,
            //     SGXRequest.RequestStatus status,
            //     SGXRequest.ResultType result_type
            // ) =
            sgxStaticDataMarketPlace.getRequestInfo2(vhash, request_hash);
            // console2.logAddress(target_token);
            // console2.log(gas_price);
            // console2.log(block_number);
            // console2.log(revoke_block_num);
            // console2.log(data_use_price);
            // console2.log(program_use_price);
            // console2.log(uint(status));
            // console2.log(uint(result_type));
        }

        // remind cost （这个cost从哪拿到的？？）
        uint64 cost = 0;
        uint256 gap = sgxMultiOffChainResultMarket.remindRequestCost(
            vhash,
            request_hash,
            cost,
            sig_ready
        );
        console2.log("gap: ", gap);

        //  result ready
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.submitOffChainResultReady(
            vhash,
            request_hash,
            cost,
            sig_ready,
            result_hash
        );

        // request Skey
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.requestOffChainSkey(
            vhash,
            request_hash,
            result_hash
        );

        // Submit Skey - insufficient amount
        vm.prank(account3.addr);
        vm.expectRevert("insufficient amount");
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            cost,
            skey,
            sig_submit
        );

        // refund request
        console2.log("refund payment: ", gap);
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.refundRequest(vhash, request_hash, gap);

        // Submit Skey again - sufficient amount
        vm.prank(account3.addr);
        sgxMultiOffChainResultMarket.submitOffChainSkey(
            vhash,
            request_hash,
            cost,
            skey,
            sig_submit
        );

        // Check each acounts' balance
        assertEq(percToken.balanceOf(address(this)), 1550, "account0 balance");
        assertEq(percToken.balanceOf(account1.addr), 5000, "account1 balance");
        assertEq(percToken.balanceOf(account2.addr), 5000, "account2 balance");
        assertEq(percToken.balanceOf(account3.addr), 8450, "account3 balance");
        assertEq(
            percToken.balanceOf(address(sgxStaticDataMarketPlace)),
            0,
            "market balance"
        );
    }
}
