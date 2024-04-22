// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// PaymentSystem Import
import {PaymentPool} from "contracts/plugins/payment-system/contracts/PaymentPool.sol";
import {PERCToken, PERCTokenFactory} from "contracts/plugins/payment-system/contracts/PERCToken.sol";
import {TokenManagement} from "contracts/plugins/payment-system/contracts/TokenManagement.sol";
import {MockBank} from "contracts/plugins/payment-system/contracts/tests/MockBank.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

// Treehole Import
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
import {SGXProgramStoreFactory, SGXProgramStore} from "../contracts/market/SGXProgramStore.sol";
import {SGXProgramStoreUpgradeable} from "../contracts/market/SGXProgramStoreUpgradeable.sol";
import {SGXStaticDataMarketPlaceFactory, SGXStaticDataMarketPlace} from "../contracts/market/SGXStaticDataMarketPlace.sol";
import {SGXStaticDataMarketPlaceUpgradeable} from "../contracts/market/SGXStaticDataMarketPlaceUpgradeable.sol";
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

import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

contract DeployHelper is Test {
    // PaymentPool Define
    PaymentPool public paymentPool;
    PaymentPool public paymentPoolImpl;

    PERCTokenFactory public percTokenFactory;

    PERCToken public percToken;
    PERCToken public percTokenImpl;

    TokenManagement public tokenManagement;
    MockBank public mockBank;

    TestERC20 internal _testToken = new TestERC20();

    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    Account public account1 = makeAccount("accounts[1]");
    Account public account2 = makeAccount("accounts[2]");
    Account public account3 = makeAccount("accounts[3]");
    Account public account4 = makeAccount("accounts[4]");
    Account public account5 = makeAccount("accounts[5]");
    Account public account6 = makeAccount("accounts[6]");
    Account public account7 = makeAccount("accounts[7]");
    Account public account8 = makeAccount("accounts[8]");
    Account public account9 = makeAccount("accounts[9]");

    // Treehole Define

    // ERC20TokenFactory public erc20TokenFactory = new ERC20TokenFactory();
    // TrustListFactory public trustListFactory = new TrustListFactory();
    // TokenBankV2Factory public tokenBankV2Factory = new TokenBankV2Factory();
    // SGXKeyVerifierFactory public sgxKeyVerifierFactory =
    //     new SGXKeyVerifierFactory();
    // SGXProgramStoreFactory public sgxProgramStoreFactory =
    //     new SGXProgramStoreFactory();
    // SGXStaticDataMarketPlaceFactory sgxStaticDataMarketPlaceFactory =
    //     new SGXStaticDataMarketPlaceFactory();

    NaiveOwner public ownerProxy = new NaiveOwner();
    TestQuickSort public testQuickSort = new TestQuickSort();

    SGXStaticDataMarketPlace public sgxStaticDataMarketPlace; //market

    SGXProgramStore public sgxProgramStore; //program-store

    SGXVirtualDataImplV1 public sgxVirtualDataImplV1;
    SGXVirtualDataImplV1Upgradeable public sgxVirtualDataImplV1Upgradeable;

    SGXMultiOnChainResultMarket public sgxMultiOnChainResultMarket; //multi-onchain-market or onchain-market
    SGXOnChainResultMarketImplV1 public sgxOnChainResultMarketImplV1;
    SGXOnChainResultMarketImplV1Upgradeable
        public sgxOnChainResultMarketImplV1Upgradeable;

    SGXMultiOffChainResultMarket public sgxMultiOffChainResultMarket; //multi-offchain-market or offchain-market
    SGXOffChainResultMarketImplV1 public sgxOffChainResultMarketImplV1;
    SGXOffChainResultMarketImplV1Upgradeable
        public sgxOffChainResultMarketImplV1Upgradeable;

    SGXDataMarketCommonImplV1 public sgxDataMarketCommonImplV1;
    SGXDataMarketCommonImplV1Upgradeable
        public sgxDataMarketCommonImplV1Upgradeable;

    SGXDataMarketCommon public sgxDataMarketCommon; //common-market

    SGXStaticDataMarketPlaceUpgradeable
        public sgxStaticDataMarketPlaceUpgradeable; //market
    SGXStaticDataMarketPlaceUpgradeable
        public sgxStaticDataMarketPlaceUpgradeableImpl; //market

    SGXProgramStoreUpgradeable public sgxProgramStoreUpgradeable; //program-store
    SGXProgramStoreUpgradeable public sgxProgramStoreUpgradeableImpl; //program-store

    SGXMultiOnChainResultMarketUpgradeable
        public sgxMultiOnChainResultMarketUpgradeable; //multi-onchain-market or onchain-market
    SGXMultiOnChainResultMarketUpgradeable
        public sgxMultiOnChainResultMarketUpgradeableImpl; //multi-onchain-market or onchain-market
    SGXMultiOffChainResultMarketUpgradeable
        public sgxMultiOffChainResultMarketUpgradeable; //multi-offchain-market or offchain-market
    SGXMultiOffChainResultMarketUpgradeable
        public sgxMultiOffChainResultMarketUpgradeableImpl; //multi-offchain-market or offchain-market

    ProxyAdmin proxyAdmin;

    function setUpEnv() public {
        vm.label(address(ownerProxy), "ownerProxy");

        _deployPaymentSystem();

        _deployTreeHole();

        _deployTreeHoleUpgradeable();
    }

    function _deployPaymentSystem() internal {
        // PaymentSystem Init

        paymentPoolImpl = new PaymentPool();
        vm.label(address(paymentPool), "paymentPool Impl");

        paymentPool = PaymentPool(
            payable(
                address(
                    new TransparentUpgradeableProxy(
                        address(paymentPoolImpl),
                        address(this),
                        abi.encodeCall(PaymentPool.initialize, ("testPP"))
                    )
                )
            )
        ); //pay_proxy

        percTokenFactory = new PERCTokenFactory();

        percToken = percTokenFactory.createCloneToken(
            PERCToken(address(0)),
            0,
            "DSToken",
            18,
            "DST",
            true,
            address(paymentPool)
        );

        vm.label(address(percToken), "percToken");
        paymentPool.grantRole(TRUSTED_ROLE, address(this));
        percToken.grantRole(TRUSTED_ROLE, address(this));

        tokenManagement = new TokenManagement();
        vm.label(address(tokenManagement), "tokenManagement");

        tokenManagement.changeToken(address(percToken));

        paymentPool.grantRole(TRUSTED_ROLE, address(tokenManagement));
        percToken.grantRole(TRUSTED_ROLE, address(tokenManagement));

        paymentPool.grantRole(TRUSTED_ROLE, address(percToken));
        percToken.grantRole(TRUSTED_ROLE, address(paymentPool));
    }

    function _deployTreeHole() internal {
        // Treehole Init
        sgxProgramStore = new SGXProgramStore(address(ownerProxy));

        sgxStaticDataMarketPlace = new SGXStaticDataMarketPlace(
            address(sgxProgramStore),
            address(ownerProxy),
            address(percToken)
        ); //market
        sgxStaticDataMarketPlace.grantRole(TRUSTED_ROLE, address(this));
        sgxStaticDataMarketPlace.grantRole(
            TRUSTED_ROLE,
            address(tokenManagement)
        );
        sgxStaticDataMarketPlace.grantRole(TRUSTED_ROLE, address(paymentPool));
        sgxStaticDataMarketPlace.changeFee(100000);
        sgxStaticDataMarketPlace.changeFeePool(payable(address(this)));

        sgxVirtualDataImplV1 = new SGXVirtualDataImplV1();
        sgxMultiOnChainResultMarket = new SGXMultiOnChainResultMarket(); //multi_onchain_market
        sgxOnChainResultMarketImplV1 = new SGXOnChainResultMarketImplV1();

        sgxMultiOffChainResultMarket = new SGXMultiOffChainResultMarket(); //multi_offchain_market
        sgxOffChainResultMarketImplV1 = new SGXOffChainResultMarketImplV1();

        sgxMultiOnChainResultMarket.changeDataLib(
            address(sgxOnChainResultMarketImplV1)
        );
        sgxMultiOnChainResultMarket.changeVirtualDataLib(
            address(sgxVirtualDataImplV1)
        );
        sgxMultiOnChainResultMarket.changeMarket(
            address(sgxStaticDataMarketPlace)
        );

        sgxMultiOffChainResultMarket.changeDataLib(
            address(sgxOffChainResultMarketImplV1)
        );
        sgxMultiOffChainResultMarket.changeVirtualDataLib(
            address(sgxVirtualDataImplV1)
        );
        sgxMultiOffChainResultMarket.changeMarket(
            address(sgxStaticDataMarketPlace)
        );

        percToken.grantRole(TRUSTED_ROLE, address(sgxMultiOnChainResultMarket));
        percToken.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarket)
        );

        sgxStaticDataMarketPlace.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOnChainResultMarket)
        );
        sgxStaticDataMarketPlace.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarket)
        );
        sgxDataMarketCommonImplV1 = new SGXDataMarketCommonImplV1(); //common_impl
        sgxDataMarketCommon = new SGXDataMarketCommon(); //common_market
        sgxDataMarketCommon.changeDataLib(address(sgxDataMarketCommonImplV1));
        sgxDataMarketCommon.changeMarket(address(sgxStaticDataMarketPlace));

        percToken.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));
        sgxStaticDataMarketPlace.grantRole(
            TRUSTED_ROLE,
            address(sgxDataMarketCommon)
        );
        sgxMultiOnChainResultMarket.changeConfirmProxy(address(paymentPool));
        sgxDataMarketCommon.changeConfirmProxy(address(paymentPool));

        sgxMultiOffChainResultMarket.changeConfirmProxy(address(paymentPool));

        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOnChainResultMarket)
        );
        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarket)
        );
        paymentPool.grantRole(TRUSTED_ROLE, address(sgxStaticDataMarketPlace));
        paymentPool.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));

        vm.label(address(sgxProgramStore), "program-store");
        vm.label(address(sgxStaticDataMarketPlace), "static-data-market");
        vm.label(address(sgxMultiOnChainResultMarket), "multi-onchain-market");
        vm.label(
            address(sgxMultiOffChainResultMarket),
            "multi-offchain-market"
        );
        vm.label(address(sgxVirtualDataImplV1), "virtual-data-impl");
        vm.label(address(sgxOnChainResultMarketImplV1), "onchain-market-impl");
        vm.label(
            address(sgxOffChainResultMarketImplV1),
            "offchain-market-impl"
        );
        vm.label(address(sgxDataMarketCommon), "common-market");
        vm.label(address(sgxDataMarketCommonImplV1), "common-market-impl");
        vm.label(address(ownerProxy), "owner-proxy");
        vm.label(address(testQuickSort), "qsort");
    }

    function _deployTreeHoleUpgradeable() internal {
        // Treehole Init
        sgxProgramStoreUpgradeableImpl = new SGXProgramStoreUpgradeable();
        vm.label(
            address(sgxProgramStoreUpgradeableImpl),
            "program-store-upgradeable-impl"
        );

        sgxProgramStoreUpgradeable = SGXProgramStoreUpgradeable(
            address(
                new TransparentUpgradeableProxy(
                    address(sgxProgramStoreUpgradeableImpl),
                    address(this),
                    abi.encodeCall(
                        SGXProgramStoreUpgradeable.initialize,
                        (address(ownerProxy))
                    )
                )
            )
        );
        vm.label(
            address(sgxProgramStoreUpgradeable),
            "program-store-upgradeable"
        );

        sgxStaticDataMarketPlaceUpgradeableImpl = new SGXStaticDataMarketPlaceUpgradeable();
        vm.label(
            address(sgxStaticDataMarketPlaceUpgradeableImpl),
            "static-data-market-upgradeable-impl"
        );
        sgxStaticDataMarketPlaceUpgradeable = SGXStaticDataMarketPlaceUpgradeable(
            address(
                new TransparentUpgradeableProxy(
                    address(sgxStaticDataMarketPlaceUpgradeableImpl),
                    address(this),
                    abi.encodeCall(
                        SGXStaticDataMarketPlaceUpgradeable.initialize,
                        (
                            address(sgxProgramStoreUpgradeable),
                            address(ownerProxy),
                            address(percToken)
                        )
                    )
                )
            )
        );
        vm.label(
            address(sgxStaticDataMarketPlaceUpgradeable),
            "static-data-market-upgradeable"
        );

        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(this)
        );
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(tokenManagement)
        );
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(paymentPool)
        );
        sgxStaticDataMarketPlaceUpgradeable.changeFee(100000);
        sgxStaticDataMarketPlaceUpgradeable.changeFeePool(
            payable(address(this))
        );

        sgxVirtualDataImplV1Upgradeable = new SGXVirtualDataImplV1Upgradeable();

        sgxMultiOnChainResultMarketUpgradeableImpl = new SGXMultiOnChainResultMarketUpgradeable(); //multi_onchain_market
        vm.label(
            address(sgxMultiOnChainResultMarketUpgradeableImpl),
            "multi-onchain-market-upgradeable-impl"
        );
        sgxMultiOnChainResultMarketUpgradeable = SGXMultiOnChainResultMarketUpgradeable(
            address(
                new TransparentUpgradeableProxy(
                    address(sgxMultiOnChainResultMarketUpgradeableImpl),
                    address(this),
                    abi.encodeCall(
                        SGXMultiOnChainResultMarketUpgradeable.initialize,
                        ()
                    )
                )
            )
        );
        vm.label(
            address(sgxMultiOnChainResultMarketUpgradeable),
            "multi-onchain-market-upgradeable"
        );

        sgxOnChainResultMarketImplV1Upgradeable = new SGXOnChainResultMarketImplV1Upgradeable();

        sgxMultiOffChainResultMarketUpgradeableImpl = new SGXMultiOffChainResultMarketUpgradeable(); //multi_onchain_market
        vm.label(
            address(sgxMultiOffChainResultMarketUpgradeableImpl),
            "multi-offchain-market-upgradeable-impl"
        );
        sgxMultiOffChainResultMarketUpgradeable = SGXMultiOffChainResultMarketUpgradeable(
            address(
                new TransparentUpgradeableProxy(
                    address(sgxMultiOffChainResultMarketUpgradeableImpl),
                    address(this),
                    abi.encodeCall(
                        SGXMultiOffChainResultMarketUpgradeable.initialize,
                        ()
                    )
                )
            )
        );
        vm.label(
            address(sgxMultiOffChainResultMarketUpgradeable),
            "multi-offchain-market-upgradeable"
        );

        sgxOffChainResultMarketImplV1Upgradeable = new SGXOffChainResultMarketImplV1Upgradeable();

        sgxMultiOnChainResultMarketUpgradeable.changeDataLib(
            address(sgxOnChainResultMarketImplV1Upgradeable)
        );
        sgxMultiOnChainResultMarketUpgradeable.changeVirtualDataLib(
            address(sgxVirtualDataImplV1Upgradeable)
        );
        sgxMultiOnChainResultMarketUpgradeable.changeMarket(
            address(sgxStaticDataMarketPlaceUpgradeable)
        );

        sgxMultiOffChainResultMarketUpgradeable.changeDataLib(
            address(sgxOffChainResultMarketImplV1Upgradeable)
        );
        sgxMultiOffChainResultMarketUpgradeable.changeVirtualDataLib(
            address(sgxVirtualDataImplV1Upgradeable)
        );
        sgxMultiOffChainResultMarketUpgradeable.changeMarket(
            address(sgxStaticDataMarketPlaceUpgradeable)
        );

        percToken.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOnChainResultMarketUpgradeable)
        );
        percToken.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarketUpgradeable)
        );

        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOnChainResultMarketUpgradeable)
        );
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarketUpgradeable)
        );
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(sgxDataMarketCommon)
        );

        // sgxDataMarketCommonImplV1 = new SGXDataMarketCommonImplV1(); //common_impl
        // sgxDataMarketCommon = new SGXDataMarketCommon(); //common_market
        // sgxDataMarketCommon.changeDataLib(address(sgxDataMarketCommonImplV1));
        // sgxDataMarketCommon.changeMarket(address(sgxStaticDataMarketPlace));

        //percToken.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));
        // sgxStaticDataMarketPlace.grantRole(
        //     TRUSTED_ROLE,
        //     address(sgxDataMarketCommon)
        // );
        //sgxMultiOnChainResultMarketUpgradeable.changeConfirmProxy(address(paymentPool));
        //sgxDataMarketCommon.changeConfirmProxy(address(paymentPool));

        //test later
        //sgxMultiOffChainResultMarket.changeConfirmProxy(address(paymentPool));

        // paymentPool.grantRole(
        //     TRUSTED_ROLE,
        //     address(sgxMultiOnChainResultMarketUpgradeable)
        // );
        // paymentPool.grantRole(
        //     TRUSTED_ROLE,
        //     address(sgxMultiOffChainResultMarketUpgradeable)
        // );
        // paymentPool.grantRole(TRUSTED_ROLE, address(sgxStaticDataMarketPlace));
        // paymentPool.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));
    }

    receive() external payable {}
}
