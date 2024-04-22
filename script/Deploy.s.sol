// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {stdJson} from "forge-std/StdJson.sol";

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";

import {THAddress} from "script/utils/THAddress.sol";

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

contract Deploy is Script, Test, THAddress {
    using stdJson for string;

    address public owner = 0xf4267391072B27D76Ed8f2A9655BCf5246013F2d;

    function run() public {
        vm.startBroadcast(owner);
        _deployPaymentSystem();
        _deployTreeHoleUpgradeable();
        // percToken.generateTokens(
        //     0x8CBfeaF611AbFd20e746329616b892D9e38400e2,
        //     1000000000000000000
        // );

        vm.stopBroadcast();
    }

    function _deployPaymentSystem() internal {
        paymentPoolImpl = new PaymentPool();
        vm.toString(address(paymentPoolImpl)).write(path, ".PaymentPool.Impl");

        paymentPool = PaymentPool(
            payable(
                address(
                    new TransparentUpgradeableProxy(
                        address(paymentPoolImpl),
                        owner,
                        abi.encodeWithSelector(
                            PaymentPool.initialize.selector,
                            "CNY UnionPay Proxy"
                        )
                    )
                )
            )
        );
        vm.toString(address(paymentPool)).write(path, ".PaymentPool.Proxy");

        percTokenFactory = new PERCTokenFactory();
        vm.toString(address(percTokenFactory)).write(path, ".PERCTokenFactory");

        percToken = percTokenFactory.createCloneToken(
            PERCToken(address(0)),
            0,
            "Chinese Yuan",
            6,
            "CNY",
            true,
            address(paymentPool)
        );
        vm.toString(address(percToken)).write(path, ".PERCToken.Proxy");

        percTokenImpl = PERCToken(percTokenFactory.impl());
        vm.toString(address(percTokenImpl)).write(path, ".PERCToken.Impl");

        percToken.changePaymentProxy(address(paymentPool));
        percToken.changeProxyRequire(true);

        tokenManagement = new TokenManagement();
        vm.toString(address(tokenManagement)).write(path, ".TokenManagement");

        tokenManagement.changeConfirmProxy(address(paymentPool));
        tokenManagement.changeToken(address(percToken));

        percToken.grantRole(TRUSTED_ROLE, owner);
        percToken.grantRole(TRUSTED_ROLE, address(paymentPool));

        paymentPool.grantRole(TRUSTED_ROLE, owner);
        paymentPool.grantRole(TRUSTED_ROLE, address(percToken));

        paymentPool.grantRole(TRUSTED_ROLE, address(tokenManagement));
        percToken.grantRole(TRUSTED_ROLE, address(tokenManagement));

        // percToken.generateTokens(
        //     0x845D866F4A9B1D13BcC2905bd90Af3C285Fb8c82,
        //     1000000000000000000
        // );
        percToken.generateTokens(owner, 1000000000000000000);
    }

    function _deployTreeHoleUpgradeable() internal {
        sgxDataMarketCommon = new SGXDataMarketCommon(); //common_market

        percToken.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));

        sgxDataMarketCommon.changeConfirmProxy(address(paymentPool));

        paymentPool.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));

        vm.toString(address(sgxDataMarketCommon)).write(
            path,
            ".SGXDataMarketCommon"
        );

        ownerProxy = new NaiveOwner();
        testQuickSort = new TestQuickSort();

        vm.toString(address(ownerProxy)).write(path, ".NaiveOwner");
        vm.toString(address(testQuickSort)).write(path, ".TestQuickSort");

        //--------------upgradeable

        // Treehole Init
        sgxProgramStoreUpgradeableImpl = new SGXProgramStoreUpgradeable();
        vm.toString(address(sgxProgramStoreUpgradeableImpl)).write(
            path,
            ".SGXProgramStoreUpgradeable.Impl"
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
        vm.toString(address(sgxProgramStoreUpgradeable)).write(
            path,
            ".SGXProgramStoreUpgradeable.Proxy"
        );

        sgxStaticDataMarketPlaceUpgradeableImpl = new SGXStaticDataMarketPlaceUpgradeable();
        vm.toString(address(sgxStaticDataMarketPlaceUpgradeableImpl)).write(
            path,
            ".SGXStaticDataMarketPlaceUpgradeable.Impl"
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
        vm.toString(address(sgxStaticDataMarketPlaceUpgradeable)).write(
            path,
            ".SGXStaticDataMarketPlaceUpgradeable.Proxy"
        );

        sgxStaticDataMarketPlaceUpgradeable.grantRole(TRUSTED_ROLE, owner);
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(tokenManagement)
        );
        sgxStaticDataMarketPlaceUpgradeable.grantRole(
            TRUSTED_ROLE,
            address(paymentPool)
        );
        // sgxStaticDataMarketPlaceUpgradeable.changeFee(100000);
        // sgxStaticDataMarketPlaceUpgradeable.changeFeePool(
        //     payable(address(this))
        // );

        sgxVirtualDataImplV1Upgradeable = new SGXVirtualDataImplV1Upgradeable(); //a template
        vm.toString(address(sgxVirtualDataImplV1Upgradeable)).write(
            path,
            ".SGXVirtualDataImplV1Upgradeable"
        );

        sgxMultiOnChainResultMarketUpgradeableImpl = new SGXMultiOnChainResultMarketUpgradeable(); //multi_onchain_market
        vm.toString(address(sgxMultiOnChainResultMarketUpgradeableImpl)).write(
            path,
            ".SGXMultiOnChainResultMarketUpgradeable.Impl"
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
        vm.toString(address(sgxMultiOnChainResultMarketUpgradeable)).write(
            path,
            ".SGXMultiOnChainResultMarketUpgradeable.Proxy"
        );

        sgxOnChainResultMarketImplV1Upgradeable = new SGXOnChainResultMarketImplV1Upgradeable(); // a template
        vm.toString(address(sgxOnChainResultMarketImplV1Upgradeable)).write(
            path,
            ".SGXOnChainResultMarketImplV1Upgradeable"
        );

        sgxMultiOffChainResultMarketUpgradeableImpl = new SGXMultiOffChainResultMarketUpgradeable(); //a template
        vm.toString(address(sgxMultiOffChainResultMarketUpgradeableImpl)).write(
                path,
                ".SGXMultiOffChainResultMarketUpgradeable.Impl"
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
        vm.toString(address(sgxMultiOffChainResultMarketUpgradeable)).write(
            path,
            ".SGXMultiOffChainResultMarketUpgradeable.Proxy"
        );

        sgxOffChainResultMarketImplV1Upgradeable = new SGXOffChainResultMarketImplV1Upgradeable();
        vm.toString(address(sgxOffChainResultMarketImplV1Upgradeable)).write(
            path,
            ".SGXOffChainResultMarketImplV1Upgradeable"
        );

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

        //extra for upgradeable

        sgxDataMarketCommon.changeMarket(
            address(sgxStaticDataMarketPlaceUpgradeable)
        );

        sgxDataMarketCommonImplV1Upgradeable = new SGXDataMarketCommonImplV1Upgradeable(); //common_impl
        vm.toString(address(sgxDataMarketCommonImplV1Upgradeable)).write(
            path,
            ".SGXDataMarketCommonImplV1Upgradeable"
        );
        sgxDataMarketCommon.changeDataLib(
            address(sgxDataMarketCommonImplV1Upgradeable)
        );

        //sgxDataMarketCommon.changeConfirmProxy(address(paymentPool));
        sgxMultiOnChainResultMarketUpgradeable.changeConfirmProxy(
            address(paymentPool)
        );
        sgxMultiOffChainResultMarketUpgradeable.changeConfirmProxy(
            address(paymentPool)
        );

        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOnChainResultMarketUpgradeable)
        );
        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxMultiOffChainResultMarketUpgradeable)
        );
        paymentPool.grantRole(
            TRUSTED_ROLE,
            address(sgxStaticDataMarketPlaceUpgradeable)
        );
        //paymentPool.grantRole(TRUSTED_ROLE, address(sgxDataMarketCommon));
    }
}
