// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SGXKeyVerifierFactory, SGXKeyVerifier} from "contracts/market/SGXKeyVerifier.sol";
import {SGXProgramStore, SGXProgramStoreFactory} from "contracts/market/SGXProgramStore.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "contracts/market/SGXStaticDataMarketPlace.sol";
import {ERC20Token, ERC20TokenFactory} from "contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
import {TokenBankV2} from "contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {TrustList, TrustListFactory} from "contracts/plugins/eth-contracts/TrustList.sol";
import {SGXOnChainResultMarketImplV1} from "contracts/market/onchain/SGXOnChainResultMarketImplV1.sol";
import {SGXDataMarketCommon} from "contracts/market/common/SGXDataMarketCommon.sol";
import {SGXOnChainResultMarket} from "contracts/market/onchain/SGXOnChainResultMarket.sol";
import "contracts/test/USDT.sol";
import "lib/forge-std/src/Test.sol";

contract TestSGXStaticDataMarket is Test {
    // setUp(){}
}

// contract("TESTSGXStaticDataMarket", (accounts) => {
//   let factory = {};
//   let program_store = {};
//   let verifier = {};
//   let market = {};
//   let token = {};
//   let pkey = {};
//   let program_hash = {};
//   let data_hash = {};
//   let data_vhash = {};
//   let request_hash = {};
//   let onchain_market = {};
//   let common_market = {};

//   context("init", async () => {
//     it("init", async () => {
//       //assert.ok(token);
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       await token.generateTokens(accounts[0], 1000000000);
//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       onchain_market = await SGXOnChainResultMarket.at(
//         sr.value("onchain-market")
//       );
//       console.log("onchain market: ", sr.value("onchain-market"));
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program(
//         "test_url",
//         0,
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141"
//       );
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       dhash =
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
//       pkey =
//         "0x362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
//       let pkey_sig =
//         "0xd9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
//       let hash_sig =
//         "0xe014387b04dddc1a2ec75b42f2f8313395e1c391a8fb3bd1544d82071e1c1ae665ce132eac6f6f57f900c1d781714bddd8297b770d11714aa6e5ad4bdd9516eb1b";
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         dhash,
//         "test env",
//         0,
//         pkey,
//         hash_sig
//       );
//       //console.log("tx log: ", tx)
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("submit request", async () => {
//       let secret =
//         "0x9fbe7febcd5c9bd7e50a51ca03652271fd0455a800bf331e02a85e6223e8493905e8282f68e70b56eef6e51a3c69f453d8c5dcdb3ac36144e5e810a41202a478d4a6b4d57db8bb6ea0931c5907037eaac6ed9980426479ec401157bd649bc33e3eefbec1354fb8aa4feca5f1681aeed1581c201ab7f73c636051f63f4221183f51f2c02591a47322cf57055e18e63aa246f5c6d9ab2c28b233b8d807b843e9111cc110dfdc8ffcf7ad8afffd4848832a84";
//       let input =
//         "0xaf4145ab19e5a354c2118032d4a6ca81ac4ddf1ffcd0e227cd648fb1701d95f917e31481e38d832d38f0ffbbba80228ab1ee9c05e88f997cae4354677f4fe0b9dce23ca07309cddc32dd0997517aec00687314";
//       let forward_sig =
//         "0x0ce588a6d240a4c6da1b9c887c32576fd4eb43b170d42d4fea01e8cdfc50be634fdce867af14b76f8fbade6ca03a42b74ea855a1f12e80ff71e2dd5f79879f6d1c";
//       let gas_price = 10000000000;
//       pkey =
//         "0x5d7ee992f48ffcdb077c2cb57605b602bd4029faed3e91189c7fb9fccc72771e45b7aa166766e2ad032d0a195372f5e2d20db792901d559ab0d2bfae10ecea97";
//       impl = await SGXOnChainResultMarketImplV1.at(
//         await onchain_market.data_lib_address()
//       );
//       var c = new web3.eth.Contract(impl.abi, impl.address);
//       abi = c.methods
//         .requestOnChain(
//           data_vhash,
//           secret,
//           input,
//           forward_sig,
//           program_hash,
//           gas_price,
//           pkey,
//           0
//         )
//         .encodeABI();
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       console.log("payment token: ", await market.payment_token());

//       await token.approve(onchain_market.address, 1000000000000000);
//       tx = await onchain_market.requestOnChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey,
//         1000
//       );
//       //console.log('request log: ', tx.logs)
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     let gap = {};
//     it("submit cost", async () => {
//       let cost = 12876;
//       let cost_sig =
//         "0x8de4601130a5f12b1f97ad52ebbf9c4cd3aa2ea24c86ea596970e131e0f55e427f9d3c2e83c2dbbfe6c031bdeb58327a53c8525a7ec5b59ba3287e35cd18d5731c";
//       tx = await onchain_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         cost,
//         cost_sig
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     it("submit result", async () => {
//       let result =
//         "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//       let result_signature =
//         "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//       tx = await expectRevert(
//         onchain_market.submitOnChainResult(
//           data_vhash,
//           request_hash,
//           12876,
//           result,
//           result_signature
//         ),
//         "insufficient amount to pay onchain result"
//       );
//       // tx = await truffleAssert.reverts(
//       //   onchain_market.submitOnChainResult(
//       //     data_vhash,
//       //     request_hash,
//       //     12876,
//       //     result,
//       //     result_signature
//       //   ),
//       //   "insufficient amount"
//       // );
//     });

//     it("refund request", async () => {
//       let c = gap;
//       console.log("refund payment: ", c.toString());
//       tx = await onchain_market.refundRequest(data_vhash, request_hash, c);
//     });

//     it("submit result", async () => {
//       let result =
//         "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//       let result_signature =
//         "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//       tx = await onchain_market.submitOnChainResult(
//         data_vhash,
//         request_hash,
//         12876,
//         result,
//         result_signature
//       );
//     });
//   });

//   context("Test with payment token being 0x0", async () => {
//     it("init", async () => {
//       //assert.ok(token);
//       sr = StepRecorder("ganache", "market");
//       token = constants.ZERO_ADDRESS;
//       // await token.generateTokens(accounts[0], 1000000000);
//       market = await SGXStaticDataMarketPlace.at(sr.value("market-no-payment"));
//       onchain_market = await SGXOnChainResultMarket.at(
//         sr.value("onchain-market")
//       );
//       await onchain_market.changeMarket(market.address);
//       console.log("onchain market: ", sr.value("onchain-market"));
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
//       tx = await program_store.upload_program(
//         "test_url",
//         0,
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141"
//       );
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       dhash =
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
//       pkey =
//         "0x362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
//       let pkey_sig =
//         "0xd9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
//       let hash_sig =
//         "0xe014387b04dddc1a2ec75b42f2f8313395e1c391a8fb3bd1544d82071e1c1ae665ce132eac6f6f57f900c1d781714bddd8297b770d11714aa6e5ad4bdd9516eb1b";
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         dhash,
//         "test env",
//         0,
//         pkey,
//         hash_sig
//       );
//       //console.log("tx log: ", tx)
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("submit request", async () => {
//       let secret =
//         "0x9fbe7febcd5c9bd7e50a51ca03652271fd0455a800bf331e02a85e6223e8493905e8282f68e70b56eef6e51a3c69f453d8c5dcdb3ac36144e5e810a41202a478d4a6b4d57db8bb6ea0931c5907037eaac6ed9980426479ec401157bd649bc33e3eefbec1354fb8aa4feca5f1681aeed1581c201ab7f73c636051f63f4221183f51f2c02591a47322cf57055e18e63aa246f5c6d9ab2c28b233b8d807b843e9111cc110dfdc8ffcf7ad8afffd4848832a84";
//       let input =
//         "0xaf4145ab19e5a354c2118032d4a6ca81ac4ddf1ffcd0e227cd648fb1701d95f917e31481e38d832d38f0ffbbba80228ab1ee9c05e88f997cae4354677f4fe0b9dce23ca07309cddc32dd0997517aec00687314";
//       let forward_sig =
//         "0x0ce588a6d240a4c6da1b9c887c32576fd4eb43b170d42d4fea01e8cdfc50be634fdce867af14b76f8fbade6ca03a42b74ea855a1f12e80ff71e2dd5f79879f6d1c";
//       let gas_price = 10000000000;
//       pkey =
//         "0x5d7ee992f48ffcdb077c2cb57605b602bd4029faed3e91189c7fb9fccc72771e45b7aa166766e2ad032d0a195372f5e2d20db792901d559ab0d2bfae10ecea97";
//       impl = await SGXOnChainResultMarketImplV1.at(
//         await onchain_market.data_lib_address()
//       );
//       var c = new web3.eth.Contract(impl.abi, impl.address);
//       abi = c.methods
//         .requestOnChain(
//           data_vhash,
//           secret,
//           input,
//           forward_sig,
//           program_hash,
//           gas_price,
//           pkey,
//           0
//         )
//         .encodeABI();
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       // console.log("payment token: ", await market.payment_token());

//       // await token.approve(onchain_market.address, 1000000000000000);
//       tx = await onchain_market.requestOnChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey,
//         1000
//       );
//       //console.log('request log: ', tx.logs)
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     let gap = {};
//     it("submit cost", async () => {
//       let cost = 12876;
//       let cost_sig =
//         "0x8de4601130a5f12b1f97ad52ebbf9c4cd3aa2ea24c86ea596970e131e0f55e427f9d3c2e83c2dbbfe6c031bdeb58327a53c8525a7ec5b59ba3287e35cd18d5731c";
//       tx = await onchain_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         cost,
//         cost_sig
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     // it("submit result", async () => {
//     //   let result =
//     //     "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//     //   let result_signature =
//     //     "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//     //   tx = await expectRevert(
//     //     onchain_market.submitOnChainResult(
//     //       data_vhash,
//     //       request_hash,
//     //       12876,
//     //       result,
//     //       result_signature
//     //     ),
//     //     "insufficient amount to pay onchain result"
//     //   );
//     //   // tx = await truffleAssert.reverts(
//     //   //   onchain_market.submitOnChainResult(
//     //   //     data_vhash,
//     //   //     request_hash,
//     //   //     12876,
//     //   //     result,
//     //   //     result_signature
//     //   //   ),
//     //   //   "insufficient amount"
//     //   // );
//     // });

//     it("refund request", async () => {
//       let c = gap;
//       console.log("refund payment: ", c.toString());
//       tx = await onchain_market.refundRequest(data_vhash, request_hash, c);
//     });

//     it("submit result", async () => {
//       let result =
//         "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//       let result_signature =
//         "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//       tx = await onchain_market.submitOnChainResult(
//         data_vhash,
//         request_hash,
//         12876,
//         result,
//         result_signature
//       );
//     });
//   });

//   context("test op", async () => {
//     it("init", async () => {
//       //assert.ok(token);
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       await token.generateTokens(accounts[0], 1000000000);
//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       onchain_market = await SGXOnChainResultMarket.at(
//         sr.value("onchain-market")
//       );
//       console.log("onchain market: ", sr.value("onchain-market"));
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program(
//         "test_url",
//         0,
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141"
//       );
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       dhash =
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
//       pkey =
//         "0x362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
//       let pkey_sig =
//         "0xd9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
//       let hash_sig =
//         "0xe014387b04dddc1a2ec75b42f2f8313395e1c391a8fb3bd1544d82071e1c1ae665ce132eac6f6f57f900c1d781714bddd8297b770d11714aa6e5ad4bdd9516eb1b";
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         dhash,
//         "test env",
//         0,
//         pkey,
//         hash_sig
//       );
//       //console.log("tx log: ", tx)
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("submit request", async () => {
//       let secret =
//         "0x9fbe7febcd5c9bd7e50a51ca03652271fd0455a800bf331e02a85e6223e8493905e8282f68e70b56eef6e51a3c69f453d8c5dcdb3ac36144e5e810a41202a478d4a6b4d57db8bb6ea0931c5907037eaac6ed9980426479ec401157bd649bc33e3eefbec1354fb8aa4feca5f1681aeed1581c201ab7f73c636051f63f4221183f51f2c02591a47322cf57055e18e63aa246f5c6d9ab2c28b233b8d807b843e9111cc110dfdc8ffcf7ad8afffd4848832a84";
//       let input =
//         "0xaf4145ab19e5a354c2118032d4a6ca81ac4ddf1ffcd0e227cd648fb1701d95f917e31481e38d832d38f0ffbbba80228ab1ee9c05e88f997cae4354677f4fe0b9dce23ca07309cddc32dd0997517aec00687314";
//       let forward_sig =
//         "0x0ce588a6d240a4c6da1b9c887c32576fd4eb43b170d42d4fea01e8cdfc50be634fdce867af14b76f8fbade6ca03a42b74ea855a1f12e80ff71e2dd5f79879f6d1c";
//       let gas_price = 10000000000;
//       pkey =
//         "0x5d7ee992f48ffcdb077c2cb57605b602bd4029faed3e91189c7fb9fccc72771e45b7aa166766e2ad032d0a195372f5e2d20db792901d559ab0d2bfae10ecea97";
//       impl = await SGXOnChainResultMarketImplV1.at(
//         await onchain_market.data_lib_address()
//       );
//       var c = new web3.eth.Contract(impl.abi, impl.address);
//       abi = c.methods
//         .requestOnChain(
//           data_vhash,
//           secret,
//           input,
//           forward_sig,
//           program_hash,
//           gas_price,
//           pkey,
//           0
//         )
//         .encodeABI();
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       console.log("payment token: ", await market.payment_token());

//       await token.approve(onchain_market.address, 0);
//       await token.approve(onchain_market.address, 1000000000000000);
//       tx = await onchain_market.requestOnChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey,
//         1000
//       );
//       //console.log('request log: ', tx.logs)
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     //it('change data owner', async() =>{
//     //await common_market.changeDataOwner(data_vhash, accounts[2], {from:accounts[0]});
//     //await common_market.changeDataOwner(data_vhash, accounts[0], {from:accounts[2]})
//     //})
//     it("change data revoke info", async () => {
//       await common_market.changeRequestRevokeBlockNum(data_vhash, 123);
//     });
//     it("change request owner", async () => {
//       await common_market.transferRequestOwnership(
//         data_vhash,
//         request_hash,
//         accounts[2],
//         { from: accounts[0] }
//       );
//       await common_market.transferRequestOwnership(
//         data_vhash,
//         request_hash,
//         accounts[0],
//         { from: accounts[2] }
//       );
//     });
//   });

//   context("test reject", async () => {
//     it("init", async () => {
//       //assert.ok(token);
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       await token.generateTokens(accounts[0], 1000000000);
//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       onchain_market = await SGXOnChainResultMarket.at(
//         sr.value("onchain-market")
//       );
//       console.log("onchain market: ", sr.value("onchain-market"));
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program(
//         "test_url",
//         0,
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141"
//       );
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       dhash =
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
//       pkey =
//         "0x362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
//       let pkey_sig =
//         "0xd9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
//       let hash_sig =
//         "0xe014387b04dddc1a2ec75b42f2f8313395e1c391a8fb3bd1544d82071e1c1ae665ce132eac6f6f57f900c1d781714bddd8297b770d11714aa6e5ad4bdd9516eb1b";
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         dhash,
//         "test env",
//         0,
//         pkey,
//         hash_sig
//       );
//       //console.log("tx log: ", tx)
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("submit request", async () => {
//       let secret =
//         "0x9fbe7febcd5c9bd7e50a51ca03652271fd0455a800bf331e02a85e6223e8493905e8282f68e70b56eef6e51a3c69f453d8c5dcdb3ac36144e5e810a41202a478d4a6b4d57db8bb6ea0931c5907037eaac6ed9980426479ec401157bd649bc33e3eefbec1354fb8aa4feca5f1681aeed1581c201ab7f73c636051f63f4221183f51f2c02591a47322cf57055e18e63aa246f5c6d9ab2c28b233b8d807b843e9111cc110dfdc8ffcf7ad8afffd4848832a84";
//       let input =
//         "0xaf4145ab19e5a354c2118032d4a6ca81ac4ddf1ffcd0e227cd648fb1701d95f917e31481e38d832d38f0ffbbba80228ab1ee9c05e88f997cae4354677f4fe0b9dce23ca07309cddc32dd0997517aec00687314";
//       let forward_sig =
//         "0x0ce588a6d240a4c6da1b9c887c32576fd4eb43b170d42d4fea01e8cdfc50be634fdce867af14b76f8fbade6ca03a42b74ea855a1f12e80ff71e2dd5f79879f6d1c";
//       let gas_price = 10000000000;
//       pkey =
//         "0x5d7ee992f48ffcdb077c2cb57605b602bd4029faed3e91189c7fb9fccc72771e45b7aa166766e2ad032d0a195372f5e2d20db792901d559ab0d2bfae10ecea97";
//       impl = await SGXOnChainResultMarketImplV1.at(
//         await onchain_market.data_lib_address()
//       );
//       var c = new web3.eth.Contract(impl.abi, impl.address);
//       abi = c.methods
//         .requestOnChain(
//           data_vhash,
//           secret,
//           input,
//           forward_sig,
//           program_hash,
//           gas_price,
//           pkey,
//           0
//         )
//         .encodeABI();
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       console.log("payment token: ", await market.payment_token());

//       await token.approve(onchain_market.address, 0);
//       await token.approve(onchain_market.address, 1000000000000000);
//       tx = await onchain_market.requestOnChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey,
//         1000
//       );
//       //console.log('request log: ', tx.logs)
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     it("reject request", async () => {
//       await common_market.rejectRequest(data_vhash, request_hash);
//       s = await market.getRequestInfo2(data_vhash, request_hash);
//     });
//   });

//   context("test price not 0", async () => {
//     it("init", async () => {
//       //assert.ok(token);
//       sr = StepRecorder("ganache", "market");
//       token = await ERC20Token.at(sr.value("token"));
//       await token.generateTokens(accounts[0], 1000000000);
//       market = await SGXStaticDataMarketPlace.at(sr.value("market"));
//       onchain_market = await SGXOnChainResultMarket.at(
//         sr.value("onchain-market")
//       );
//       console.log("onchain market: ", sr.value("onchain-market"));
//       verifier = await SGXKeyVerifier.at(sr.value("verifier"));
//       program_store = await SGXProgramStore.at(sr.value("program-store"));
//       common_market = await SGXDataMarketCommon.at(sr.value("common-market"));
//       await verifier.set_verifier_addr(
//         "0xf4267391072B27D76Ed8f2A9655BCf5246013F2d",
//         true
//       );
//     });

//     it("upload program", async () => {
//       tx = await program_store.upload_program(
//         "test_url",
//         500,
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141"
//       );
//       program_hash = tx.logs[0].args.hash;
//     });

//     it("upload data", async () => {
//       dhash =
//         "0x3e0d3a43f4f45ba7a1234759c2ffa4028a44599d4ab29bec532bd2057c0f9141";
//       pkey =
//         "0x362a609ab5a6eecafdb2289890bd7261871c04fb5d7323d4fc750f6444b067a12a96efbe24c62572156caa514657d4a535101d2147337f41f51fcdfcf8f43a53";
//       let pkey_sig =
//         "0xd9b0a2d2a1c669c7cfd40e1bb71041597140cfff38ec36ff4027405bc18e0b0f2109b354641feda4c4c38bc17836e8b1d15b2054b0c359347595783f9d0664021b";
//       let hash_sig =
//         "0xe014387b04dddc1a2ec75b42f2f8313395e1c391a8fb3bd1544d82071e1c1ae665ce132eac6f6f57f900c1d781714bddd8297b770d11714aa6e5ad4bdd9516eb1b";
//       //we use program_hash as format_lib_hash, it's a mock
//       tx = await common_market.createStaticData(
//         dhash,
//         "test env",
//         5000,
//         pkey,
//         hash_sig
//       );
//       //console.log("tx log: ", tx)
//       data_vhash = tx.logs[0].args.vhash;
//     });

//     it("submit request", async () => {
//       let secret =
//         "0x9fbe7febcd5c9bd7e50a51ca03652271fd0455a800bf331e02a85e6223e8493905e8282f68e70b56eef6e51a3c69f453d8c5dcdb3ac36144e5e810a41202a478d4a6b4d57db8bb6ea0931c5907037eaac6ed9980426479ec401157bd649bc33e3eefbec1354fb8aa4feca5f1681aeed1581c201ab7f73c636051f63f4221183f51f2c02591a47322cf57055e18e63aa246f5c6d9ab2c28b233b8d807b843e9111cc110dfdc8ffcf7ad8afffd4848832a84";
//       let input =
//         "0xaf4145ab19e5a354c2118032d4a6ca81ac4ddf1ffcd0e227cd648fb1701d95f917e31481e38d832d38f0ffbbba80228ab1ee9c05e88f997cae4354677f4fe0b9dce23ca07309cddc32dd0997517aec00687314";
//       let forward_sig =
//         "0x0ce588a6d240a4c6da1b9c887c32576fd4eb43b170d42d4fea01e8cdfc50be634fdce867af14b76f8fbade6ca03a42b74ea855a1f12e80ff71e2dd5f79879f6d1c";
//       let gas_price = 10000000000;
//       let amount = 1000;
//       pkey =
//         "0x5d7ee992f48ffcdb077c2cb57605b602bd4029faed3e91189c7fb9fccc72771e45b7aa166766e2ad032d0a195372f5e2d20db792901d559ab0d2bfae10ecea97";
//       impl = await SGXOnChainResultMarketImplV1.at(
//         await onchain_market.data_lib_address()
//       );
//       var c = new web3.eth.Contract(impl.abi, impl.address);
//       abi = c.methods
//         .requestOnChain(
//           data_vhash,
//           secret,
//           input,
//           forward_sig,
//           program_hash,
//           gas_price,
//           pkey,
//           amount
//         )
//         .encodeABI();
//       console.log(
//         "data_vhash: ",
//         data_vhash,
//         " --> ",
//         await market.all_data(data_vhash)
//       );
//       console.log("payment token: ", await market.payment_token());

//       console.log("here");
//       console.log(onchain_market.address);
//       l = await token.balanceOf(accounts[0]);
//       await token.destroyTokens(accounts[0], l);
//       await token.generateTokens(accounts[0], 1000000000);
//       await token.approve(onchain_market.address, 0);
//       await token.approve(onchain_market.address, 1000000000);
//       tx = await onchain_market.requestOnChain(
//         data_vhash,
//         secret,
//         input,
//         forward_sig,
//         program_hash,
//         gas_price,
//         pkey,
//         amount
//       );
//       //console.log('request log: ', tx.logs)
//       request_hash = tx.logs[0].args.request_hash;
//     });

//     let gap = {};
//     it("submit cost", async () => {
//       let cost = 12876;
//       let cost_sig =
//         "0x8de4601130a5f12b1f97ad52ebbf9c4cd3aa2ea24c86ea596970e131e0f55e427f9d3c2e83c2dbbfe6c031bdeb58327a53c8525a7ec5b59ba3287e35cd18d5731c";
//       tx = await onchain_market.remindRequestCost(
//         data_vhash,
//         request_hash,
//         cost,
//         cost_sig
//       );
//       gap = tx.logs[0].args.gap;
//       console.log("gap: ", gap.toString());
//     });

//     // it("submit result", async () => {
//     //   let result =
//     //     "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//     //   let result_signature =
//     //     "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//     //   tx = await expectRevert(
//     //     onchain_market.submitOnChainResult(
//     //       data_vhash,
//     //       request_hash,
//     //       12876,
//     //       result,
//     //       result_signature
//     //     ),
//     //     "insufficient amount to pay onchain result"
//     //   );
//     //   // tx = await truffleAssert.reverts(
//     //   //   onchain_market.submitOnChainResult(
//     //   //     data_vhash,
//     //   //     request_hash,
//     //   //     12876,
//     //   //     result,
//     //   //     result_signature
//     //   //   ),
//     //   //   "insufficient amount"
//     //   // );
//     // });

//     // it("refund request", async () => {
//     //   let c = gap;
//     //   console.log("refund payment: ", c.toString());
//     //   tx = await onchain_market.refundRequest(data_vhash, request_hash, c);
//     // });

//     it("submit result", async () => {
//       let result =
//         "0x566df6fc662a2cd177ee05de6dde43e0b1aa2798866b1e1656ff5d2c38171a1e76de34448e9f527a04754942290a87e3c50de136d22c8b196e7db089f6edd8b2643830b1e8b8051ec75e55d4d8eabcce679b18c41aec0dad05df7e8c0e";
//       let result_signature =
//         "0xd83b1a6cddc99d5564c0a0dd38d66323055e86f6b226d5c588ac8d1fb09e5d056d41972873c41e286df1246cc667d6cf17a1699ec854921005304d6f0a02fc0f1b";
//       tx = await onchain_market.submitOnChainResult(
//         data_vhash,
//         request_hash,
//         12876,
//         result,
//         result_signature
//       );
//     });
//   });
// });