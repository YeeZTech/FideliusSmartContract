// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {GasRewardToolUpgradeable} from "contracts/plugins/eth-contracts/plugins/GasRewardToolUpgradeable.sol";
import {SGXProxyBaseUpgradeable} from "../SGXProxyBaseUpgradeable.sol";
import {MinerProxyUpgradeable} from "../../mine/MinerProxyUpgradeable.sol";
import {SGXVirtualDataBaseUpgradeable} from "../multi/SGXVirtualDataBaseUpgradeable.sol";
import {SGXOnChainResultMarketBaseUpgradeable} from "../onchain/SGXOnChainResultMarketBaseUpgradeable.sol";

pragma experimental ABIEncoderV2;

//multi-onchain-market: 0xf38a458174B64bFd7B58ed7Df56A02423f617a0d
contract SGXMultiOnChainResultMarketUpgradeable is
    OwnableUpgradeable,
    GasRewardToolUpgradeable,
    SGXProxyBaseUpgradeable,
    MinerProxyUpgradeable,
    SGXVirtualDataBaseUpgradeable,
    SGXOnChainResultMarketBaseUpgradeable
{
    struct RequestParam {
        bytes secret;
        bytes input;
        bytes forward_sig;
        bytes32 program_hash;
        bytes pkey;
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function requestOnChain(
        bytes32[] memory _vhashes,
        RequestParam memory param,
        uint256 gas_price,
        uint256 amount
    ) public rewardGas returns (bytes32, bytes32) {
        bytes32 vhash = createVirtualData(market, _vhashes);

        // confirm before
        bytes32 transferRequestHash;
        {
            transferRequestHash = _beforeConfirm(
                vhash,
                keccak256(
                    abi.encode(
                        address(this),
                        param.pkey,
                        param.secret,
                        param.input,
                        param.forward_sig,
                        param.program_hash,
                        gas_price,
                        block.number
                    )
                )
            );
        }

        bytes32 request_hash = _requestOnChain(
            vhash,
            param.secret,
            param.input,
            param.forward_sig,
            param.program_hash,
            gas_price,
            param.pkey,
            amount
        );
        recordDataSource(market, request_hash, _vhashes);

        // confirm after
        _afterConfirm(vhash, request_hash, transferRequestHash);

        return (vhash, request_hash);
    }

    function submitOnChainResult(
        bytes32 _vhash,
        bytes32 request_hash,
        uint64 cost,
        bytes memory result,
        bytes memory sig
    ) public rewardGas returns (bool) {
        // confirm before
        bytes32 transferRequestHash;
        {
            transferRequestHash = _beforeConfirm(_vhash, request_hash);
        }

        bool v = _submitOnChainResult(_vhash, request_hash, cost, result, sig);
        dispatchFee(market, _vhash, request_hash, cost);

        // confirm after
        _afterConfirm(_vhash, request_hash, transferRequestHash);

        //__GasRewardToolUpgradeable_init_autoTransferCommit(transferRequestHash, true);
        return v;
    }

    function rejectRequest(
        bytes32 _vhash,
        bytes32 request_hash
    ) public rewardGas need_confirm_hash(_vhash, request_hash) {
        require(
            belongDataOwner(market, request_hash, msg.sender),
            "only data owner may reject"
        );
        {
            bytes memory data = abi.encodeWithSignature(
                "rejectRequest(bytes32,bytes32)",
                _vhash,
                request_hash
            );
            market.delegateCallUseData(data_lib_address, data);
        }
        emit SDMarketRejectRequest(_vhash, request_hash);
    }
}
