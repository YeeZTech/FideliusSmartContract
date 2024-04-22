// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokenBankV2} from "contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {THMiner} from "contracts/mine/THMiner.sol";
import {ERC20Token, ERC20TokenFactory} from "../contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {THPeriod} from "contracts/THPeriod.sol";

// // const {DHelper, StepRecorder} = require("./util.js");
// // const DataMarketPlace = artifacts.require("DataMarketPlace_for_mine_test");
// // const Program_Proxy = artifacts.require("Program_Proxy");

// contract THMinerTest is Test {
//     function setUp() public {
//         address market;
//         THPeriod period;
//         bytes
//             memory vhash = "0x76686173680000000000000000000000000000000000000000000000000000";
//         bytes
//             memory request_hash = "0x72657175657374686173680000000000000000000000000000000000000000";
//         THMiner thminer;
//         //   let receipt;

//         THminer hminer = THMiner.deployed();
//         THPeriod period = new THPeriod();
//         DataMarketPlace market = new DataMarketPlace();
//         Program_Proxy program_proxy = new Program_Proxy();
//         address token = thminer.reward_token();
//         address bank = thminer.token_pool();
//         token.generateTokens(bank.address, "9999999999999999999999999999999999999999");
//         period.changeCurrentPeriod(0);
//         market.changeDataPrice(10)
//         market.changeDataOwner(accounts[1]);
//         program_proxy.changeAlgoOwner(accounts[2]);
//         program_proxy.changeAlgoPrice(4);
//         market.changeBuyer(accounts[3]);
//     }

//     function test_ExpectChangeMarketPlace() public {

//     }

//     function test_RevertIfCallerIsNotOwner() public {

//     }

//     function test_ExpectChangeEventAndRatios() public {

//     }

//     function test_RevertIfCallerIsNotOwner() public {

//     }

//     function test_ExpectChangeEventAndRewardToken() public {

//     }

//     function test_RevertIfCallerIsNotOwner() public {

//     }

//     function test_ExpectChangeEventAndRewardPerRound() public {

//     }

//     function test_RevertIfCallerIsNotOwner() public {

//     }

//     function test_AllInformationIsTakenDownIfRoundIsZero() public {

//     }

//     function test_ExpectNoOneReceiveRewardIfRoundIsOne() public {

//     }

// }

// //   describe("Test ChangeMarketPlace function", async () => {
// //       it("expect a event and market place should be changed", async () => {
// //         //deploy another market, called market2
// //         sr =  StepRecorder("ganache", "market");
// //         market2 = await DataMarketPlace.at(sr.value("market2"));
// //         //check event
// //         receipt = await thminer.changeMarketPlace(market2.address)
// //         expectEvent(receipt,
// //         'ChangeMarketPlace',{0:market.address,1:market2.address});
// //         //check state var
// //         expect(await thminer.data_market_place()).to.equal(market2.address);
// //       });
// //       it("When caller is not the owner, expect a revert", async () => {
// //         await expectRevert(thminer.changeMarketPlace(market.address,{from:accounts[1]}),"caller is not the owner")
// //         //change to the original market for upcoming tests
// //         thminer.changeMarketPlace(market.address);
// //       });
// //     })

// //     describe("Test ChangeRatios function", async () => {
// //       it("expect a event and ratios should be changed", async () => {
// //         receipt = await thminer.changeRatios(300000,500000,200000);
// //         expectEvent(receipt, 'ChangeRatios', {0:new BN("300000"),1:new BN("500000"),2:new BN("200000")})
// //         expect((await thminer.algo_ratio()).toString()).to.equal("300000");
// //         expect((await thminer.data_ratio()).toString()).to.equal("500000");
// //         expect((await thminer.buyer_ratio()).toString()).to.equal("200000");
// //       });
// //       it("When caller is not the owner, expect a revert", async () => {
// //         await expectRevert(thminer.changeRatios(200000,300000,500000,{from:accounts[1]}),"caller is not the owner")
// //       });
// //     })

// //     describe("Test changeRewardToken function", async () => {
// //       it("expect a event and the token should be changed", async () => {
// //         token2 = await DataMarketPlace.at(sr.value("token2"));
// //         receipt = await thminer.changeRewardToken(token2.address)
// //         expectEvent(receipt,
// //         'ChangeRewardToken',{0:token2.address});
// //         //check state var
// //         expect(await thminer.reward_token()).to.equal(token2.address);
// //         //change back
// //         await thminer.changeRewardToken(token.address)
// //       });
// //       it("When caller is not the owner, expect a revert", async () => {
// //         await expectRevert(thminer.changeRewardToken(token2.address,{from:accounts[2]}),"caller is not the owner")
// //       });

// //     })

// //     describe("Test changeRewardPerRound function", async () => {
// //       it("expect a event and the reward per round should be changed", async () => {
// //         receipt = await thminer.changeRewardPerRound(10000000);
// //         expectEvent(receipt, 'ChangeRewardPerRound', {0:"10000000"})
// //         expect((await thminer.total_reward_per_round()).toString()).to.equal("10000000")
// //       });
// //       it("When caller is not the owner, expect a revert", async () => {
// //         await expectRevert(thminer.changeRewardPerRound(20000000,{from:accounts[1]}),"caller is not the owner")
// //       });
// //     })

// //   describe("Test mine_submit_result function", async () => {
// //     it("when round is 0, all information should not be taken down", async () => {
// //       await thminer.mine_submit_result(vhash, request_hash);
// //       //user info of the data owener should be default
// //       user_info = await thminer.userClaimStatus(accounts[1],0);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(false);
// //       //round info of the first round should be default
// //       round_info= await thminer.all_rounds(0)
// //       expect(await round_info[0].toNumber()).to.equal(0);
// //       expect(await round_info[1].toNumber()).equal(0);
// //       //balance of buyer, data_owner, algo_owner should be zero
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("0");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("0");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("0");
// //     });
// //     it("Round 1, first transation, expect no one to receive any reward", async () => {
// //       await period.changeCurrentPeriod(1);

// //       await thminer.mine_submit_result(vhash, request_hash);
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("0");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("0");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("0");
// //     });
// //     it("Round2, first transation, account 1,3 will receive the reward for the round1", async () => {
// //       await period.changeCurrentPeriod(2);
// //       await market.changeDataPrice(5)
// //       await market.changeDataOwner(accounts[1]);
// //       await program_proxy.changeAlgoOwner(accounts[3]);
// //       await program_proxy.changeAlgoPrice(11);
// //       await market.changeBuyer(accounts[4]);
// //       receipt = await thminer.mine_submit_result(vhash, request_hash);
// //       console.log("Expect event: THRewardUserAtRound: {0:",accounts[1], ", 1: 1, 2:5000000" )
// //       console.log("Actual event: ",receipt.logs[0].args.addr)
// //       console.log("Actual event: ",receipt.logs[0].args.round.toString())
// //       console.log("Actual event: ",receipt.logs[0].args.amount.toString())
// //       console.log("Expect event: THRewardUserAtRound: {0:",accounts[3], ", 1: 1, 2:2000000" )
// //       console.log("Actual event: ",receipt.logs[1].args.addr)
// //       console.log("Actual event: ",receipt.logs[1].args.round.toString())
// //       console.log("Actual event: ",receipt.logs[1].args.amount.toString())
// //       //algoratio/ratiobase=3/10
// //       //dataratio/ratiobase=5/10
// //       //buyerratio/ratiobase=2/10
// //       //rewardPerround=10000000
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("5000000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("0");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("2000000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("0");
// //     });
// //     it("Test whether last active round are appropriately updated", async () => {
// //       expect((await thminer.user_last_active_round(accounts[1])).toString()).to.equal("2");
// //       expect((await thminer.user_last_active_round(accounts[2])).toString()).to.equal("1");
// //       expect((await thminer.user_last_active_round(accounts[3])).toString()).to.equal("2");
// //       expect((await thminer.user_last_active_round(accounts[4])).toString()).to.equal("2");
// //       expect((await thminer.user_last_active_round(accounts[5])).toString()).to.equal("0");

// //     });
// //     it("Round2, second transation, only account 2 will receive the reward for the round1", async () => {
// //       await period.changeCurrentPeriod(2);
// //       await market.changeDataPrice(15)
// //       await market.changeDataOwner(accounts[2]);
// //       await program_proxy.changeAlgoOwner(accounts[4]);
// //       await program_proxy.changeAlgoPrice(9);
// //       await market.changeBuyer(accounts[1]);

// //       receipt = await thminer.mine_submit_result(vhash, request_hash);
// //       console.log("Expect event: THRewardUserAtRound: {0:",accounts[2], ", 1: 1, 2:3000000}")
// //       console.log("Actual event: ",receipt.logs[0].args.addr)
// //       console.log("Actual event: ",receipt.logs[0].args.round.toString())
// //       console.log("Actual event: ",receipt.logs[0].args.amount.toString())

// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("5000000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("3000000");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("2000000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("0");
// //     });
// //     it("test mine_for_tx function: check whether the data is appropriately taken down, also test userClaimStatus & roundStatus function", async () => {
// //       user_info = await thminer.userClaimStatus(accounts[1],1);
// //       expect(await user_info[0].toNumber()).to.equal(10);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(true);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[2],1);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(4);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(true);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[3],1);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(14);
// //       expect(await user_info[3]).to.equal(true);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[4],1);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(false);

// //       round_info= await thminer.roundStatus(1);
// //       expect(await round_info[0].toNumber()).to.equal(10);
// //       expect(await round_info[1].toNumber()).equal(4);

// //       user_info = await thminer.userClaimStatus(accounts[1],2);
// //       expect(await user_info[0].toNumber()).to.equal(5);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(24);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[2],2);
// //       expect(await user_info[0].toNumber()).to.equal(15);
// //       expect(await user_info[1].toNumber()).to.equal(0);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[3],2);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(11);
// //       expect(await user_info[2].toNumber()).to.equal(0);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(true);

// //       user_info = await thminer.userClaimStatus(accounts[4],2);
// //       expect(await user_info[0].toNumber()).to.equal(0);
// //       expect(await user_info[1].toNumber()).to.equal(9);
// //       expect(await user_info[2].toNumber()).to.equal(16);
// //       expect(await user_info[3]).to.equal(false);
// //       expect(await user_info[4]).to.equal(true);

// //       round_info= await thminer.roundStatus(2);
// //       expect(await round_info[0].toNumber()).to.equal(20);
// //       expect(await round_info[1].toNumber()).equal(20);
// //     });
// //     it("When caller is not in the trustlist, expect a revert", async () => {
// //       await expectRevert(thminer.mine_submit_result(vhash, request_hash,{from:accounts[1]}),"revert not a trusted issuer")
// //     });
// //   })

// //   describe("Test claimTokenForRound function", async () => {
// //     it("claim tokens for round 1, should revert", async () => {
// //         await expectRevert(thminer.claimTokenForRound(accounts[1],1), "already claimed")
// //         await expectRevert(thminer.claimTokenForRound(accounts[2],1), "already claimed")
// //         await expectRevert(thminer.claimTokenForRound(accounts[3],1), "already claimed")
// //     });
// //     it("claim tokens for non-exist user, should revert", async () => {
// //       await expectRevert(thminer.claimTokenForRound(accounts[4],1),"address not exist")
// //     });
// //     it("claim tokens at round 3, should revert", async () => {
// //       await expectRevert(thminer.claimTokenForRound(accounts[4],3),"can only claim when a round is end")
// //     });
// //     it("claim tokens at round 3", async () => {
// //       await period.changeCurrentPeriod(3);
// //       await thminer.claimTokenForRound(accounts[1],2)
// //       await thminer.claimTokenForRound(accounts[2],2)
// //       await thminer.claimTokenForRound(accounts[3],2)
// //       await thminer.claimTokenForRound(accounts[4],2)
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("7450000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("6750000");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("3650000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("2150000");
// //     });
// //   })

// //   describe("Test mine_submit_result function", async () => {
// //     it("Round3, first transation, balance should not change, since token is already claimed for round2", async () => {
// //       await market.changeDataPrice(7)
// //       await market.changeDataOwner(accounts[3]);
// //       await program_proxy.changeAlgoOwner(accounts[1]);
// //       await program_proxy.changeAlgoPrice(2);
// //       await market.changeBuyer(accounts[2]);
// //       await thminer.mine_submit_result(vhash, request_hash);
// //       //balance should not change
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("7450000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("6750000");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("3650000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("2150000");
// //     });
// //     it("Round3, second transation, balance should not change, since token is already claimed for round2", async () => {
// //       await market.changeDataPrice(3)
// //       await market.changeDataOwner(accounts[3]);
// //       await program_proxy.changeAlgoOwner(accounts[1]);
// //       await program_proxy.changeAlgoPrice(8);
// //       await market.changeBuyer(accounts[2]);
// //       await thminer.mine_submit_result(vhash, request_hash);
// //       //balance should not change
// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("7450000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("6750000");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("3650000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("2150000");
// //     });
// //     it("claim tokens at round 3", async () => {
// //       await period.changeCurrentPeriod(4);
// //       await thminer.claimTokenForRound(accounts[1],3)
// //       await thminer.claimTokenForRound(accounts[2],3)
// //       await thminer.claimTokenForRound(accounts[3],3)

// //       expect((await token.balanceOf(accounts[1])).toString()).to.equal("10450000");
// //       expect((await token.balanceOf(accounts[2])).toString()).to.equal("8750000");
// //       expect((await token.balanceOf(accounts[3])).toString()).to.equal("8650000");
// //       expect((await token.balanceOf(accounts[4])).toString()).to.equal("2150000");
// //     });
// //   });
// //   //template
// //   // describe("Test  function", async () => {
// //   //   it("", async () => {

// //   //   });
// //   //   it("", async () => {

// //   //   });
// //   // })
