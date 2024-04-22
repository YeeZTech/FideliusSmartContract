// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {CommonBase} from "forge-std/Base.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {PaymentPool} from "contracts/plugins/payment-system/contracts/PaymentPool.sol";
import {PERCToken, PERCTokenFactory} from "contracts/plugins/payment-system/contracts/PERCToken.sol";

import {TokenManagement} from "contracts/plugins/payment-system/contracts/TokenManagement.sol";

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
//import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TokenBankV2} from "contracts/plugins/eth-contracts/assets/TokenBankV2.sol";
import {ERC20Token, ERC20TokenFactory} from "contracts/plugins/eth-contracts/erc20/ERC20Token.sol";
//mine
import {THTokenRaise, THTokenRaiseFactory} from "contracts/TokenRaise.sol";
import {THMint, THMintFactory} from "contracts/THMint.sol";
import {THPeriod, THPeriodFactory} from "contracts/THPeriod.sol";
import {THTRDispatcher, THTRDispatcherFactory} from "contracts/THTRDispatcher.sol";
import {THTRDPeriodAmount, THTRDPeriodAmountFactory} from "contracts/THTRDPeriodAmount.sol";
//market
import {SGXStaticData} from "contracts/market/SGXStaticData.sol";
import {SGXKeyVerifierFactory} from "contracts/market/SGXKeyVerifier.sol";
import {SGXProgramStoreFactory, SGXProgramStore} from "contracts/market/SGXProgramStore.sol";
import {SGXProgramStoreUpgradeable} from "contracts/market/SGXProgramStoreUpgradeable.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "contracts/market/SGXStaticDataMarketPlace.sol";
import {SGXStaticDataMarketPlaceUpgradeable} from "contracts/market/SGXStaticDataMarketPlaceUpgradeable.sol";
import {SGXVirtualDataImplV1} from "contracts/market/multi/SGXVirtualDataImplV1.sol";
import {SGXVirtualDataImplV1Upgradeable} from "contracts/market/multi/SGXVirtualDataImplV1Upgradeable.sol";

import {SGXMultiOnChainResultMarket} from "contracts/market/multi_onchain/SGXMultiOnChainResultMarket.sol";
import {SGXMultiOnChainResultMarketUpgradeable} from "contracts/market/multi_onchain/SGXMultiOnChainResultMarketUpgradeable.sol";

import {SGXOnChainResultMarketImplV1} from "contracts/market/onchain/SGXOnChainResultMarketImplV1.sol";
import {SGXOnChainResultMarketImplV1Upgradeable} from "contracts/market/onchain/SGXOnChainResultMarketImplV1Upgradeable.sol";
import {SGXMultiOffChainResultMarket} from "contracts/market/multi_offchain/SGXMultiOffChainResultMarket.sol";
import {SGXMultiOffChainResultMarketUpgradeable} from "contracts/market/multi_offchain/SGXMultiOffChainResultMarketUpgradeable.sol";
import {SGXOffChainResultMarketImplV1} from "contracts/market/offchain/SGXOffChainResultMarketImplV1.sol";
import {SGXOffChainResultMarketImplV1Upgradeable} from "contracts/market/offchain/SGXOffChainResultMarketImplV1Upgradeable.sol";

import {SGXDataMarketCommonImplV1} from "contracts/market/common/SGXDataMarketCommonImplV1.sol";
import {SGXDataMarketCommonImplV1Upgradeable} from "contracts/market/common/SGXDataMarketCommonImplV1Upgradeable.sol";
import {SGXVirtualDataImplV1Upgradeable} from "contracts/market/multi/SGXVirtualDataImplV1Upgradeable.sol";

import {SGXDataMarketCommon} from "contracts/market/common/SGXDataMarketCommon.sol";

import {NaiveOwner} from "contracts/test/NaiveOwner.sol";
import {TestQuickSort} from "contracts/test/TestQuickSort.sol";

import {TestERC20} from "contracts/test/TestERC20.sol";

contract THAddress is CommonBase {
    using stdJson for string;

    string path =
        string.concat(
            vm.projectRoot(),
            "/deployed-contracts-info/",
            vm.envString("ENV"),
            "-th.json"
        );
    string json = vm.readFile(path);

    //ProxyAdmin public proxyAdmin = ProxyAdmin(json.readAddress(".ProxyAdmin"));

    PaymentPool public paymentPool =
        PaymentPool(payable(json.readAddress(".PaymentPool.Proxy")));

    PaymentPool public paymentPoolImpl =
        PaymentPool(payable(json.readAddress(".PaymentPool.Impl")));

    PERCTokenFactory public percTokenFactory =
        PERCTokenFactory(json.readAddress(".PERCTokenFactory"));

    PERCToken public percToken =
        PERCToken(json.readAddress(".PERCToken.Proxy"));
    PERCToken public percTokenImpl =
        PERCToken(json.readAddress(".PERCToken.Impl"));

    TokenManagement public tokenManagement =
        TokenManagement(json.readAddress(".TokenManagement"));

    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    NaiveOwner public ownerProxy = NaiveOwner(json.readAddress(".NaiveOwner"));
    TestQuickSort public testQuickSort =
        TestQuickSort(json.readAddress(".TestQuickSort"));

    SGXVirtualDataImplV1Upgradeable public sgxVirtualDataImplV1Upgradeable =
        SGXVirtualDataImplV1Upgradeable(
            json.readAddress(".SGXVirtualDataImplV1Upgradeable")
        );

    SGXOnChainResultMarketImplV1Upgradeable
        public sgxOnChainResultMarketImplV1Upgradeable =
        SGXOnChainResultMarketImplV1Upgradeable(
            json.readAddress(".SGXOnChainResultMarketImplV1Upgradeable")
        );

    SGXOffChainResultMarketImplV1Upgradeable
        public sgxOffChainResultMarketImplV1Upgradeable =
        SGXOffChainResultMarketImplV1Upgradeable(
            json.readAddress(".SGXOffChainResultMarketImplV1Upgradeable")
        );

    SGXDataMarketCommonImplV1Upgradeable
        public sgxDataMarketCommonImplV1Upgradeable =
        SGXDataMarketCommonImplV1Upgradeable(
            json.readAddress(".SGXDataMarketCommonImplV1Upgradeable")
        );

    SGXDataMarketCommon public sgxDataMarketCommon =
        SGXDataMarketCommon(json.readAddress(".SGXDataMarketCommon")); //common-market

    SGXStaticDataMarketPlaceUpgradeable
        public sgxStaticDataMarketPlaceUpgradeable =
        SGXStaticDataMarketPlaceUpgradeable(
            json.readAddress(".SGXStaticDataMarketPlaceUpgradeable.Proxy")
        ); //market
    SGXStaticDataMarketPlaceUpgradeable
        public sgxStaticDataMarketPlaceUpgradeableImpl =
        SGXStaticDataMarketPlaceUpgradeable(
            json.readAddress(".SGXStaticDataMarketPlaceUpgradeable.Impl")
        ); //market

    SGXProgramStoreUpgradeable public sgxProgramStoreUpgradeable =
        SGXProgramStoreUpgradeable(
            json.readAddress(".SGXProgramStoreUpgradeable.Proxy")
        ); //program-store
    SGXProgramStoreUpgradeable public sgxProgramStoreUpgradeableImpl =
        SGXProgramStoreUpgradeable(
            json.readAddress(".SGXProgramStoreUpgradeable.Impl")
        ); //program-store; //program-store

    SGXMultiOnChainResultMarketUpgradeable
        public sgxMultiOnChainResultMarketUpgradeable =
        SGXMultiOnChainResultMarketUpgradeable(
            json.readAddress(".SGXMultiOnChainResultMarketUpgradeable.Proxy")
        ); //multi-onchain-market or onchain-market
    SGXMultiOnChainResultMarketUpgradeable
        public sgxMultiOnChainResultMarketUpgradeableImpl =
        SGXMultiOnChainResultMarketUpgradeable(
            json.readAddress(".SGXMultiOnChainResultMarketUpgradeable.Impl")
        ); //multi-onchain-market or onchain-market; //multi-onchain-market or onchain-market
    SGXMultiOffChainResultMarketUpgradeable
        public sgxMultiOffChainResultMarketUpgradeable =
        SGXMultiOffChainResultMarketUpgradeable(
            json.readAddress(".SGXMultiOffChainResultMarketUpgradeable.Proxy")
        ); //multi-offchain-market or offchain-market
    SGXMultiOffChainResultMarketUpgradeable
        public sgxMultiOffChainResultMarketUpgradeableImpl =
        SGXMultiOffChainResultMarketUpgradeable(
            json.readAddress(".SGXMultiOffChainResultMarketUpgradeable.Impl")
        ); //multi-offchain-market or offchain-market
}
