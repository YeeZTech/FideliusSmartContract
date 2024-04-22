// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokenBankV2} from "../contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {ERC20Token, ERC20TokenFactory} from "../contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
import {THTokenRaise, THTokenRaiseFactory} from "../contracts/TokenRaise.sol";
import {THMint, THMintFactory} from "../contracts/THMint.sol";
import {THPeriod, THPeriodFactory} from "../contracts/THPeriod.sol";
import {THTRDispatcher, THTRDispatcherFactory} from "../contracts/THTRDispatcher.sol";
import {THTRDPeriodAmount, THTRDPeriodAmountFactory} from "../contracts/THTRDPeriodAmount.sol";
import {TrustList, TrustListFactory} from "../contracts/plugins/eth-contracts/TrustList.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import "contracts/test/USDT.sol";

import {DeployHelper} from "./DeployHelper.sol";

// const {DHelper, StepRecorder} = require("./util.js");

contract THTRDispatcherTest is Test, DeployHelper {
    uint256 price = 0;
    THTokenRaise tr;
    address th_tx;
    TetherToken usdt;
    uint256 i = 0;
    uint256 start_block = 0;
    TokenBankV2 pool;
    THPeriodFactory period_factory;
    THPeriod th_period;
    address tht;

    function setUp() public {
        setUpEnv();

        start_block = block.number;
        usdt = new TetherToken(0, "USDT", "USDT", 6);
        usdt.issue(100000000000000);
        usdt.issue(100000000000000);

        tr = new THTokenRaise(
            start_block,
            start_block + 10,
            100000000,
            address(usdt),
            20000000000000000000000,
            payable(account3.addr)
        );
        usdt.approve(msg.sender, 100000000000);
        vm.prank(account1.addr);
        usdt.approve(account1.addr, 100000000000);

        tr.raise(60000000);
        vm.prank(account1.addr);
        tr.raise(15000000);

        // pool.initialize("pool");
        // pool.grantRole(TRUSTED_ROLE, address(this));
        // period_factory = new THPeriodFactory();
        th_period = new THPeriod(start_block + 11, 2, 1);
        // tht = new ERC20Token("tht_token");
        // tlist = TrustList.at(sr.read("tht_token_trustlist"));
        // mint_factory = THMintFactory.deployed();
        // tx = mint_factory.createTHMint(th_period.address, tht_addr, pool.address, "10000000000000000000000");
        // th_mint = THMint.at(tx.logs[0].args.addr);
        // tlist.add_trusted(th_mint.address);
        // pa_factory = THTRDPeriodAmountFactory.deployed();
        // tx = pa_factory.createTHTRDPeriodAmount(1, 2, th_mint.address, tr.address);
        // pa = THTRDPeriodAmount.at(tx.logs[0].args.addr);
        // dis_factory = THTRDispatcherFactory.deployed();
        // tx = dis_factory.createTHTRDispatcher(tht_addr, pool.address, th_period.address, tr.address, pa.address, 0, 10)
        // th_dis = THTRDispatcher.at(tx.logs[0].args.addr);
        // pool_tl.add_trusted(th_dis.address);
    }

    function test_claimAndMint() public {
        console2.log(account1.addr);
        console2.log(account2.addr);
        console2.log(usdt.totalSupply());
        vm.expectRevert();
        tr.raise(45000000);
        uint256 cb = block.number;
        console2.log(cb);
        while (cb < th_period.start_block()) {
            th_period.get_current_period();
        }
        // th_mint.mint();
        // th_dis.claim({from:accounts[0]});
        // uint256 b0 = tht.balanceOf(accounts[0]);
        // assertEq(b0,7200000000000000000000);
        // th_dis.claim({from:accounts[1]});
        // uint b1 = tht.balanceOf(accounts[1]);
        // assertEq(b1,1800000000000000000000");
        // cb = block.number;
        // while (cb < start_block + 40){
        //     usdt.transfer(accounts[0], 0, {from:accounts[0]});
        //     cb = block.number;
        // }
        // th_mint.mint()
        // // //block 30,------2,3,4,5,6,7,,,8,period 7
        // th_dis.claim({from:accounts[0]});
        // b0 = tht.balanceOf(accounts[0]);
        // assertEq(b0,16800000000000000000000);
        // while (cb < start_block + 80){
        //     usdt.transfer(accounts[0], 0, {from:accounts[0]});
        //     cb = block.number;
        // }
        // // //block 70, period 11,------2,3,4,5,6,7,8,9,10,11,,,12
        // vm.expectRevert("claim already end");
        // th_dis.claim({from:accounts[1]});
        // uint256 bp = tht.balanceOf(pool.address);
        // assertEq(bp,51400000000000000000000);
    }
}
