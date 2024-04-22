// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// const {
//   BN,
//   constants,
//   expectEvent,
//   expectRevert,
// } = require("@openzeppelin/test-helpers");
// const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");
// const { expect } = require("chai");
// const SGXKeyVerifierFactory = artifacts.require("SGXKeyVerifierFactory");
// const SGXKeyVerifier = artifacts.require("SGXKeyVerifier");
// const SGXProgramStoreFactory = artifacts.require("SGXProgramStoreFactory");
// const SGXProgramStore = artifacts.require("SGXProgramStore");
// const SGXStaticDataMarketPlaceFactory = artifacts.require(
//   "SGXStaticDataMarketPlaceFactory"
// );
// const SGXStaticDataMarketPlace = artifacts.require("SGXStaticDataMarketPlace");
// const ERC20TokenFactory = artifacts.require("ERC20TokenFactory");
// const ERC20Token = artifacts.require("ERC20Token");
// const TokenBankV2 = artifacts.require("TokenBankV2");
// const TokenBankV2Factory = artifacts.require("TokenBankV2Factory");
// const TrustListFactory = artifacts.require("TrustListFactory");
// const TrustList = artifacts.require("TrustList");
// const USDT = artifacts.require("USDT");
// const SGXOffChainResultMarket = artifacts.require("SGXOffChainResultMarket");
// const { StepRecorder } = require("./util.js");
// const SGXOnChainResultMarketImplV1 = artifacts.require(
//   "SGXOffChainDataMarketImplV1"
// );
// const SGXDataMarketCommon = artifacts.require("SGXDataMarketCommon");
// const SGXRequest = artifacts.require("SGXRequest");

// contract("TESTSGXOffChainMarket", (accounts) => {
//   let program_store = {};
//   let verifier = {};
//   let market = {};
//   let token = {};
//   let pkey = {};
//   let program_hash = {};
//   let data_vhash = {};
//   let request_hash = {};
//   let offchain_result_market = {};
//   let common_market = {};

//   context("Test basic function", async () => {
//     //upload program and data
//     let enclave_hash =
//       "0xf9fdb38765b86d1e5cc87477ebe6c79109c8f24a68f516a91dcd91e3fce5daf8";
//     let data_hash =
//       "0xe5fa855fc525c9560b4e9e4127f5047941a89d61aed2ce749660d352fd74cdfc";
//     let pkey_data =
//       "0xff6e5667e5cd7645f2640ac2729c448e7f50f137ec7bca8be808526f625d12e9bfd6fb02cae75dbfd5289ccbc7fa97ff7db695577c9e726ab7fcd1911292de27";
//     let hash_sig =
//       "0xc7d81ef3ff1198ea7672cb4e02f4f040a0334cc98e0a4ebf5179bedd62c875354da072f6df29485536398d2661d99a149aefee96996efb22e0e471349ee726f21c";

//     //requestOffChain
//     let secret =
//       "0xd0b8cde999925c14bb7e8d3800bbd65f6b27de4c79be0a2001e19c48d9206f3947e0d9e63a934336963237f7776ee0ce5e4bb605837a1d916218ec3b24e06d19f8a18ea8f1e5671a1317f82c1eb43171e0a99be9fbb7825a19879b951324a3f79cf201ce60d637d5a22db907ae2976beff9fc28ee73e4081d630dfe6";
//     let input =
//       "0x0c02dbeb864fbd1fdcbbfbe6cd75b05390673d9d4b2123d896ddfa4afe760533da6092e5d2039d5ebe1aa1e2fb97edbb4df937d8ad628f933d535950480b9e7ea5f1bfcd7ee8fa3a718b17f792ea0b3dad8e614b126604332776dbe41d9eba0715d964788f37d95ab4fdc7";
//     let forward_sig =
//       "0x5ee9e33230328b5a2a4f4a3b40849800faa5906e0662cd279a975b4bb6314af202d822aba3e0fdc34d9e775ed93cbc11bc3f15354d4389074ba92c3068a247f61b";
//     let pkey_request =
//       "0x970d721df58dd96d0827a55d0ddfba1050241dce1c5f30be994d3e89c39e553d5342b4c23db2bb8ffd7262495a8b79ab4c3d32a81e2720902db74c7e77039823";

//     //submitOffChainResultReady && remindCost
//     let sig_ready =
//       "0xef87fa6bd9552577917b5e04337564bf7a5d6b24e44d5cd1aa8ee8e177cbd4123aee872d8e0ab1955b50c52e7edfb8be87e47f4f2ba45b9017f56c3d13cd2c901b";

//     // requestOffChainSkey
//     let result_hash =
//       "0x1cbbb4999efac2df00dce0ae4b9e316745d7cd0710ecfb5866e3bbc9818e3c57";

//     // submitOffChainSkey
//     let skey =
//       "0x071d9104788c4981d137d7dbbe7581406366a0eadfe713d2ad64768d3664b88ccd573b9caed32ae3069c4bfede1560aa161ecd996d90e67e55f5958aa432e5163a1b1bff52ddae866d126cce420db0971fb4fc9b3bb1d7edd28764425e9e1ddacc1091a6948f14146a25b735ff73a9ff465337e753f71345f4dd0ef2";
//     let sig_submit =
//       "0x8796fc8f00c711187bec58d99047bac10cc2e953df1bd23cd13848f2c84ee6a02951db6c60e4a1f4f12128f01a63ef720586106ae7460a1eb99ce258d6de62851c";
//     it("init", async () => {
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       l = await token.balanceOf(accounts[3]);
//       await token.destroyTokens(accounts[3], l);
//       await token.generateTokens(accounts[3], 1000000);
//       await token.generateTokens(accounts[4], 1000000);

//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       offchain_result_market = await SGXOffChainResultMarket.at(
//         sr.value("offchain-result-market")
//       );
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program("test_url", 500, enclave_hash, {
//         from: accounts[1],
//       });
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         data_hash,
//         "test env",
//         5000,
//         pkey_data,
//         hash_sig,
//         { from: accounts[2] }
//       );
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("request offchain", async () => {
//       let gas_price = 10000000000;
//       let amount = 1000;
//       await token.approve(offchain_result_market.address, 1000000000000000, {
//         from: accounts[3],
//       });
//       tx = await offchain_result_market.requestOffChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey_request,
//         amount,
//         { from: accounts[3] }
//       );

//       request_hash = tx.logs[0].args.request_hash;
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       s = await market.getRequestInfo2(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     let gap = {};
//     it("remind cost", async () => {
//       tx = await offchain_result_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         0,
//         sig_ready
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     it("result ready", async () => {
//       await offchain_result_market.submitOffChainResultReady(
//         data_vhash,
//         request_hash,
//         0,
//         sig_ready,
//         { from: accounts[3] }
//       );
//     });

//     it("request Skey", async () => {
//       await offchain_result_market.requestOffChainSkey(
//         data_vhash,
//         request_hash,
//         result_hash,
//         { from: accounts[3] }
//       );
//     });

//     it("Submit Skey - insufficient amount", async () => {
//       await expectRevert(
//         offchain_result_market.submitOffChainSkey(
//           data_vhash,
//           request_hash,
//           0,
//           skey,
//           sig_submit,
//           { from: accounts[3] }
//         ),
//         "insufficient amount"
//       );
//     });

//     it("refund request by another account ", async () => {
//       console.log("refund payment: ", gap.toString());
//       await token.approve(offchain_result_market.address, 1000000000000000, {
//         from: accounts[4],
//       });
//       tx = await offchain_result_market.refundRequest(
//         data_vhash,
//         request_hash,
//         gap,
//         { from: accounts[4] }
//       );
//       s = await market.getRequestInfo1(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     it("Submit Skey again - sufficient amount", async () => {
//       await offchain_result_market.submitOffChainSkey(
//         data_vhash,
//         request_hash,
//         0,
//         skey,
//         sig_submit,
//         { from: accounts[3] }
//       );
//     });

//     it("Check each acounts' balance", async () => {
//       await expect((await token.balanceOf(accounts[1])).toString()).to.equal(
//         "500"
//       );
//       await expect((await token.balanceOf(accounts[2])).toString()).to.equal(
//         "5000"
//       );
//       await expect((await token.balanceOf(accounts[3])).toString()).to.equal(
//         "999000"
//       );
//       await expect((await token.balanceOf(accounts[4])).toString()).to.equal(
//         "995500"
//       );
//       await expect((await token.balanceOf(market.address)).toString()).to.equal(
//         "0"
//       );
//     });
//   });

//   context("Test with payment token being 0x0", async () => {
//     //upload program and data
//     let enclave_hash =
//       "0xf9fdb38765b86d1e5cc87477ebe6c79109c8f24a68f516a91dcd91e3fce5daf8";
//     let data_hash =
//       "0xe5fa855fc525c9560b4e9e4127f5047941a89d61aed2ce749660d352fd74cdfc";
//     let pkey_data =
//       "0xff6e5667e5cd7645f2640ac2729c448e7f50f137ec7bca8be808526f625d12e9bfd6fb02cae75dbfd5289ccbc7fa97ff7db695577c9e726ab7fcd1911292de27";
//     let hash_sig =
//       "0xc7d81ef3ff1198ea7672cb4e02f4f040a0334cc98e0a4ebf5179bedd62c875354da072f6df29485536398d2661d99a149aefee96996efb22e0e471349ee726f21c";

//     //requestOffChain
//     let secret =
//       "0xd0b8cde999925c14bb7e8d3800bbd65f6b27de4c79be0a2001e19c48d9206f3947e0d9e63a934336963237f7776ee0ce5e4bb605837a1d916218ec3b24e06d19f8a18ea8f1e5671a1317f82c1eb43171e0a99be9fbb7825a19879b951324a3f79cf201ce60d637d5a22db907ae2976beff9fc28ee73e4081d630dfe6";
//     let input =
//       "0x0c02dbeb864fbd1fdcbbfbe6cd75b05390673d9d4b2123d896ddfa4afe760533da6092e5d2039d5ebe1aa1e2fb97edbb4df937d8ad628f933d535950480b9e7ea5f1bfcd7ee8fa3a718b17f792ea0b3dad8e614b126604332776dbe41d9eba0715d964788f37d95ab4fdc7";
//     let forward_sig =
//       "0x5ee9e33230328b5a2a4f4a3b40849800faa5906e0662cd279a975b4bb6314af202d822aba3e0fdc34d9e775ed93cbc11bc3f15354d4389074ba92c3068a247f61b";
//     let pkey_request =
//       "0x970d721df58dd96d0827a55d0ddfba1050241dce1c5f30be994d3e89c39e553d5342b4c23db2bb8ffd7262495a8b79ab4c3d32a81e2720902db74c7e77039823";

//     //submitOffChainResultReady && remindCost
//     let sig_ready =
//       "0xef87fa6bd9552577917b5e04337564bf7a5d6b24e44d5cd1aa8ee8e177cbd4123aee872d8e0ab1955b50c52e7edfb8be87e47f4f2ba45b9017f56c3d13cd2c901b";

//     // requestOffChainSkey
//     let result_hash =
//       "0x1cbbb4999efac2df00dce0ae4b9e316745d7cd0710ecfb5866e3bbc9818e3c57";

//     // submitOffChainSkey
//     let skey =
//       "0x071d9104788c4981d137d7dbbe7581406366a0eadfe713d2ad64768d3664b88ccd573b9caed32ae3069c4bfede1560aa161ecd996d90e67e55f5958aa432e5163a1b1bff52ddae866d126cce420db0971fb4fc9b3bb1d7edd28764425e9e1ddacc1091a6948f14146a25b735ff73a9ff465337e753f71345f4dd0ef2";
//     let sig_submit =
//       "0x8796fc8f00c711187bec58d99047bac10cc2e953df1bd23cd13848f2c84ee6a02951db6c60e4a1f4f12128f01a63ef720586106ae7460a1eb99ce258d6de62851c";
//     it("init", async () => {
//       sr = StepRecorder("ganache", "market");
//       token = constants.ZERO_ADDRESS;
//       // l = await token.balanceOf(accounts[3]);
//       // await token.destroyTokens(accounts[3], l);
//       // await token.generateTokens(accounts[3], 1000000);
//       // await token.generateTokens(accounts[4], 1000000);

//       market = await SGXStaticDataMarketPlace.at(sr.value("market-no-payment"));
//       offchain_result_market = await SGXOffChainResultMarket.at(
//         sr.value("offchain-result-market")
//       );
//       await offchain_result_market.changeMarket(market.address);
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await common_market.changeMarket(market.address);
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program("test_url", 500, enclave_hash, {
//         from: accounts[1],
//       });
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         data_hash,
//         "test env",
//         5000,
//         pkey_data,
//         hash_sig,
//         { from: accounts[2] }
//       );
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("request offchain", async () => {
//       let gas_price = 10000000000;
//       let amount = 1000;
//       // await token.approve(offchain_result_market.address, 1000000000000000, {
//       //   from: accounts[3],
//       // });
//       tx = await offchain_result_market.requestOffChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey_request,
//         amount,
//         { from: accounts[3] }
//       );

//       request_hash = tx.logs[0].args.request_hash;
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       s = await market.getRequestInfo2(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     let gap = {};
//     it("remind cost", async () => {
//       tx = await offchain_result_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         0,
//         sig_ready
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     it("result ready", async () => {
//       await offchain_result_market.submitOffChainResultReady(
//         data_vhash,
//         request_hash,
//         0,
//         sig_ready,
//         { from: accounts[3] }
//       );
//     });

//     it("request Skey", async () => {
//       await offchain_result_market.requestOffChainSkey(
//         data_vhash,
//         request_hash,
//         result_hash,
//         { from: accounts[3] }
//       );
//     });

//     // it("Submit Skey - insufficient amount", async () => {
//     //   await expectRevert(
//     //     offchain_result_market.submitOffChainSkey(
//     //       data_vhash,
//     //       request_hash,
//     //       0,
//     //       skey,
//     //       sig_submit,
//     //       { from: accounts[3] }
//     //     ),
//     //     "insufficient amount"
//     //   );
//     // });

//     it("refund request by another account ", async () => {
//       console.log("refund payment: ", gap.toString());
//       // await token.approve(offchain_result_market.address, 1000000000000000, {
//       //   from: accounts[4],
//       // });
//       tx = await offchain_result_market.refundRequest(
//         data_vhash,
//         request_hash,
//         gap,
//         { from: accounts[4] }
//       );
//       s = await market.getRequestInfo1(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     it("Submit Skey again - sufficient amount", async () => {
//       await offchain_result_market.submitOffChainSkey(
//         data_vhash,
//         request_hash,
//         0,
//         skey,
//         sig_submit,
//         { from: accounts[3] }
//       );
//     });

//     // it("Check each acounts' balance", async () => {
//     //   await expect((await token.balanceOf(accounts[1])).toString()).to.equal(
//     //     "500"
//     //   );
//     //   await expect((await token.balanceOf(accounts[2])).toString()).to.equal(
//     //     "5000"
//     //   );
//     //   await expect((await token.balanceOf(accounts[3])).toString()).to.equal(
//     //     "999000"
//     //   );
//     //   await expect((await token.balanceOf(accounts[4])).toString()).to.equal(
//     //     "995500"
//     //   );
//     //   await expect((await token.balanceOf(market.address)).toString()).to.equal(
//     //     "0"
//     //   );
//     // });
//   });

//   context("Test revoke", async () => {
//     //upload program and data
//     let enclave_hash =
//       "0xf9fdb38765b86d1e5cc87477ebe6c79109c8f24a68f516a91dcd91e3fce5daf8";
//     let data_hash =
//       "0xe5fa855fc525c9560b4e9e4127f5047941a89d61aed2ce749660d352fd74cdfc";
//     let pkey_data =
//       "0xff6e5667e5cd7645f2640ac2729c448e7f50f137ec7bca8be808526f625d12e9bfd6fb02cae75dbfd5289ccbc7fa97ff7db695577c9e726ab7fcd1911292de27";
//     let hash_sig =
//       "0xc7d81ef3ff1198ea7672cb4e02f4f040a0334cc98e0a4ebf5179bedd62c875354da072f6df29485536398d2661d99a149aefee96996efb22e0e471349ee726f21c";

//     //requestOffChain
//     let secret =
//       "0xd0b8cde999925c14bb7e8d3800bbd65f6b27de4c79be0a2001e19c48d9206f3947e0d9e63a934336963237f7776ee0ce5e4bb605837a1d916218ec3b24e06d19f8a18ea8f1e5671a1317f82c1eb43171e0a99be9fbb7825a19879b951324a3f79cf201ce60d637d5a22db907ae2976beff9fc28ee73e4081d630dfe6";
//     let input =
//       "0x0c02dbeb864fbd1fdcbbfbe6cd75b05390673d9d4b2123d896ddfa4afe760533da6092e5d2039d5ebe1aa1e2fb97edbb4df937d8ad628f933d535950480b9e7ea5f1bfcd7ee8fa3a718b17f792ea0b3dad8e614b126604332776dbe41d9eba0715d964788f37d95ab4fdc7";
//     let forward_sig =
//       "0x5ee9e33230328b5a2a4f4a3b40849800faa5906e0662cd279a975b4bb6314af202d822aba3e0fdc34d9e775ed93cbc11bc3f15354d4389074ba92c3068a247f61b";
//     let pkey_request =
//       "0x970d721df58dd96d0827a55d0ddfba1050241dce1c5f30be994d3e89c39e553d5342b4c23db2bb8ffd7262495a8b79ab4c3d32a81e2720902db74c7e77039823";

//     //submitOffChainResultReady && remindCost
//     let sig_ready =
//       "0xef87fa6bd9552577917b5e04337564bf7a5d6b24e44d5cd1aa8ee8e177cbd4123aee872d8e0ab1955b50c52e7edfb8be87e47f4f2ba45b9017f56c3d13cd2c901b";

//     // requestOffChainSkey
//     let result_hash =
//       "0x1cbbb4999efac2df00dce0ae4b9e316745d7cd0710ecfb5866e3bbc9818e3c57";

//     // submitOffChainSkey
//     let skey =
//       "0x071d9104788c4981d137d7dbbe7581406366a0eadfe713d2ad64768d3664b88ccd573b9caed32ae3069c4bfede1560aa161ecd996d90e67e55f5958aa432e5163a1b1bff52ddae866d126cce420db0971fb4fc9b3bb1d7edd28764425e9e1ddacc1091a6948f14146a25b735ff73a9ff465337e753f71345f4dd0ef2";
//     let sig_submit =
//       "0x8796fc8f00c711187bec58d99047bac10cc2e953df1bd23cd13848f2c84ee6a02951db6c60e4a1f4f12128f01a63ef720586106ae7460a1eb99ce258d6de62851c";
//     it("init", async () => {
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       //destroy previously generated token
//       l = await token.balanceOf(accounts[3]);
//       await token.destroyTokens(accounts[3], l);
//       l = await token.balanceOf(accounts[1]);
//       await token.destroyTokens(accounts[1], l);
//       l = await token.balanceOf(accounts[2]);
//       await token.destroyTokens(accounts[2], l);

//       await token.generateTokens(accounts[3], 1000000);

//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       offchain_result_market = await SGXOffChainResultMarket.at(
//         sr.value("offchain-result-market")
//       );
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program("test_url", 500, enclave_hash, {
//         from: accounts[1],
//       });
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         data_hash,
//         "test env",
//         5000,
//         pkey_data,
//         hash_sig,
//         { from: accounts[2] }
//       );
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("request offchain", async () => {
//       let gas_price = 10000000000;
//       let amount = 1000;
//       await token.approve(offchain_result_market.address, 0, {
//         from: accounts[3],
//       });
//       await token.approve(offchain_result_market.address, 1000000000000000, {
//         from: accounts[3],
//       });
//       tx = await offchain_result_market.requestOffChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey_request,
//         amount,
//         { from: accounts[3] }
//       );
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     let gap = {};
//     it("remind cost", async () => {
//       tx = await offchain_result_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         0,
//         sig_ready
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     it("refund request ", async () => {
//       console.log("refund payment: ", gap.toString());
//       tx = await offchain_result_market.refundRequest(
//         data_vhash,
//         request_hash,
//         gap,
//         { from: accounts[3] }
//       );
//       s = await market.getRequestInfo1(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     it("revoke by another account", async () => {
//       await expectRevert(
//         offchain_result_market.revokeRequest(data_vhash, request_hash, {
//           from: accounts[2],
//         }),
//         "only request owner can revoke"
//       );
//     });

//     it("revoke", async () => {
//       await offchain_result_market.revokeRequest(data_vhash, request_hash, {
//         from: accounts[3],
//       });
//     });

//     it("Submit Skey again - sufficient amount", async () => {
//       await expectRevert(
//         offchain_result_market.submitOffChainSkey(
//           data_vhash,
//           request_hash,
//           0,
//           skey,
//           sig_submit,
//           { from: accounts[3] }
//         ),
//         "invalid status"
//       );
//     });

//     it("Check each acounts' balance", async () => {
//       await expect((await token.balanceOf(accounts[1])).toString()).to.equal(
//         "0"
//       );
//       await expect((await token.balanceOf(accounts[2])).toString()).to.equal(
//         "0"
//       );
//       await expect((await token.balanceOf(accounts[3])).toString()).to.equal(
//         "1000000"
//       );
//       await expect((await token.balanceOf(market.address)).toString()).to.equal(
//         "0"
//       );
//     });
//   });

//   context("Test  with cost not being 0", async () => {
//     //upload program and data
//     let enclave_hash =
//       "0x8f46b28bfb83a563956dc56ac7f981915c0934fbb7adc6d69ed668b6141dc3f8";
//     let data_hash =
//       "0xe76852394c2ddb5ab60b4320e70ddd032feba8aa6da5b71518bf1e40317c74f5";
//     let pkey_data =
//       "0xa52bd451b7a8ca42810fe5f2987402b3b329874beee3809aedaee002fd8c69bd7b20a2734295c0fe3f594b0540741796a012eb63fdbd8d0145e7da5f4389cb63";
//     let hash_sig =
//       "0x7d9f6ac0306c8b46780b503934e9db244cfdaa51b6f5e7d8499bd8aec9d9591249367e0a71c30c1205aab500b4ac97227eca70f4874463638309d098dbad311d1c";

//     //requestOffChain
//     let secret =
//       "0xd02bb7c5f9b5284856536d0185d78117e0e1cceaf44148a37cce3fcfe9efb6bac868256c78d370791968bed7abc362a4e7f7552ba3d56acebb7b227dc19443632ec9dc5142092f4bbbfef14e3c8db4fb674919b1cd41d7782866e92ab758e1f7eee879fcea46ed81372b196b5c2c4d5e2b849a9f8e87492cf4ba77ed";
//     let input =
//       "0x15418da26d27fac458afbbfd2b4b7335146b0f0dc48ef158905364e8c260eb2bc6cc4d61bfb6caad54b2519554df813bca8b312d1e4225a3ea06419a91f15fa1b6737218afdd6ab6b4b7eccfdbbd45350926713750271270f572fe2938275038ecd39c5596ad73bf5ebb83";
//     let forward_sig =
//       "0xa173cf76457d54100df57b6fde4fbdb78094589c3af8f0d0ba5572734cc0992a443adb0e815adee01d6fa128bd344f34fc5872306d61355fde8804c436dac04f1b";
//     let pkey_request =
//       "0x27d6cc363ba89c6b90722226f9aa14f7e94b97f557f6ae7796fb85229ae6ce9ac769107c129dff99883ba6273657ef84b3214bacd3e2661b7348d0a81bd974a8";

//     //submitOffChainResultReady && remindCost
//     let cost = 12325;
//     let sig_ready =
//       "0x65889b29edadfa43c5df4530c10a5a3d49592f60411644ac9af9bda392491a571a3722bb9dde0f96261a43f825b62b976007bab0e32a8acd9d821ebdb07aa0381b";

//     // requestOffChainSkey
//     let result_hash =
//       "0x2eb231a9c8736741d2e3b923e595f61ccc5ce786c9b3132bb8434d8d5e53fd16";

//     // submitOffChainSkey
//     let skey =
//       "0x097613576ac1b9217a316fdf0c4facef1413e54cd2365648507b4e0eabfc599031c732abfff621bf238a93ebaf9642a0aa7db34e52e2fc328fd2b4d0de09c01e27f828b4e8542cbf77aacf15d9af64fa3c328b8e9f89dd75a0272e49547b6a00b0942c4943f7d70d6dce769535d5f5328c1371c359485a930da08404";
//     let sig_submit =
//       "0xc801176fa641ab3837e3eb62e4d97d35aaf451c1150e42e694c9a0c4da72ed3f7d9f855d25b1556c675ed0f4522a0a44d2af0692733530eecb2fc23494875a071b";
//     let data_vhash;
//     let request_hash;
//     it("init", async () => {
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       //destory previously generated tokens
//       l = await token.balanceOf(accounts[3]);
//       await token.destroyTokens(accounts[3], l);
//       l = await token.balanceOf(accounts[1]);
//       await token.destroyTokens(accounts[1], l);
//       l = await token.balanceOf(accounts[2]);
//       await token.destroyTokens(accounts[2], l);

//       await token.generateTokens(accounts[3], 20000);

//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       offchain_result_market = await SGXOffChainResultMarket.at(
//         sr.value("offchain-result-market")
//       );
//       await offchain_result_market.changeMarket(market.address);
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await common_market.changeMarket(market.address);
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program("test_url", 500, enclave_hash, {
//         from: accounts[1],
//       });
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         data_hash,
//         "test env",
//         5000,
//         pkey_data,
//         hash_sig,
//         { from: accounts[2] }
//       );
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("request offchain", async () => {
//       let gas_price = 1;
//       let amount = 1000;
//       await token.approve(offchain_result_market.address, 0, {
//         from: accounts[3],
//       });
//       await token.approve(offchain_result_market.address, 20000, {
//         from: accounts[3],
//       });
//       tx = await offchain_result_market.requestOffChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey_request,
//         amount,
//         { from: accounts[3] }
//       );

//       request_hash = tx.logs[0].args.request_hash;
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       s = await market.getRequestInfo2(data_vhash, request_hash);
//       console.log("Request info: ", s);
//     });

//     let gap = {};
//     it("remind cost", async () => {
//       tx = await offchain_result_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         cost,
//         sig_ready
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     it("result ready", async () => {
//       await offchain_result_market.submitOffChainResultReady(
//         data_vhash,
//         request_hash,
//         cost,
//         sig_ready,
//         { from: accounts[3] }
//       );
//     });

//     it("request Skey", async () => {
//       await offchain_result_market.requestOffChainSkey(
//         data_vhash,
//         request_hash,
//         result_hash,
//         { from: accounts[3] }
//       );
//     });

//     it("Submit Skey - insufficient amount", async () => {
//       await expectRevert(
//         offchain_result_market.submitOffChainSkey(
//           data_vhash,
//           request_hash,
//           cost,
//           skey,
//           sig_submit,
//           { from: accounts[3] }
//         ),
//         "insufficient amount"
//       );
//     });

//     it("refund request", async () => {
//       console.log("refund payment: ", gap.toString());
//       tx = await offchain_result_market.refundRequest(
//         data_vhash,
//         request_hash,
//         gap,
//         { from: accounts[3] }
//       );
//     });

//     it("Submit Skey again - sufficient amount", async () => {
//       await offchain_result_market.submitOffChainSkey(
//         data_vhash,
//         request_hash,
//         cost,
//         skey,
//         sig_submit,
//         { from: accounts[3] }
//       );
//     });
//     it("Check each acounts' balance", async () => {
//       await expect((await token.balanceOf(accounts[1])).toString()).to.equal(
//         "500"
//       );
//       await expect((await token.balanceOf(accounts[2])).toString()).to.equal(
//         "17325"
//       );
//       await expect((await token.balanceOf(accounts[3])).toString()).to.equal(
//         "2175"
//       );
//       await expect((await token.balanceOf(market.address)).toString()).to.equal(
//         "0"
//       );
//     });
//   });
// });