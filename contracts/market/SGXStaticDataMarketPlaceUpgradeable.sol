// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProgramProxyInterface} from "./interface/ProgramProxyInterface.sol";
import {KeyVerifierInterface} from "./interface/KeyVerifierInterface.sol";
import {SignatureVerifier} from "./SignatureVerifier.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {SGXRequest} from "./SGXRequest.sol";
import {SGXStaticData} from "./SGXStaticData.sol";
import {OwnerProxyInterface} from "contracts/market/interface/OwnerProxyInterface.sol";
import {SGXStaticDataMarketStorageUpgradeable} from "./SGXStaticDataMarketStorageUpgradeable.sol";

import "forge-std/Test.sol";

//market:0xbB0F
contract SGXStaticDataMarketPlaceUpgradeable is
    SGXStaticDataMarketStorageUpgradeable
{
    using SGXStaticData for mapping(bytes32 => SGXStaticData.Data);
    using SignatureVerifier for bytes32;

    function initialize(
        address _program_proxy,
        address _owner_proxy,
        address _payment_token
    ) public initializer {
        __SGXStaticDataMarketStorageUpgradable_init();
        require(_program_proxy != address(0x0), "invalid program proxy");
        program_proxy = ProgramProxyInterface(_program_proxy);
        payment_token = _payment_token;
        owner_proxy = OwnerProxyInterface(_owner_proxy);
        ratio_base = 1000000;
    }

    function __SGXStaticDataMarketPlaceUpgradeable_init_unchained() internal {}

    event SDMarketChangeProgramProxy(
        address old_program_proxy,
        address new_program_proxy
    );

    function changeProgramProxy(address _program_proxy) public onlyOwner {
        address old = address(program_proxy);
        require(_program_proxy != address(0x0), "invalid program proxy");
        program_proxy = ProgramProxyInterface(_program_proxy);
        emit SDMarketChangeProgramProxy(old, _program_proxy);
    }

    event SDMarketChangeFee(uint256 old_fee_ratio, uint256 new_fee_ratio);

    function changeFee(uint256 _fee_ratio) public onlyOwner {
        uint256 old = fee_ratio;
        fee_ratio = _fee_ratio;
        emit SDMarketChangeFee(old, fee_ratio);
    }

    event SDMarketChangeFeePool(address old_fee_pool, address new_fee_pool);

    function changeFeePool(address payable _addr) public onlyOwner {
        address old = fee_pool;
        fee_pool = _addr;
        emit SDMarketChangeFeePool(old, fee_pool);
    }

    event SDMarketPause(bool paused);

    function pause(bool _paused) public onlyOwner {
        paused = _paused;
        emit SDMarketPause(paused);
    }

    event SDMarketChangeRevokePeriod(uint256 old_period, uint256 new_period);

    function changeRevokePeriod(uint256 _new_period) public onlyOwner {
        uint256 old = request_revoke_block_num;
        request_revoke_block_num = _new_period;
        emit SDMarketChangeRevokePeriod(old, _new_period);
    }

    function getDataInfo(
        bytes32 _vhash
    )
        public
        view
        returns (
            bytes32 data_hash,
            string memory extra_info,
            uint256 price,
            bytes memory pkey,
            address owner,
            bool removed,
            uint256 revoke_timeout_block_num,
            bool exists
        )
    {
        SGXStaticData.Data storage d = all_data[_vhash];
        return (
            d.data_hash,
            d.extra_info,
            d.price,
            d.pkey,
            owner_proxy.ownerOf(_vhash),
            d.removed,
            d.revoke_timeout_block_num,
            d.exists
        );
    }

    function getRequestInfo1(
        bytes32 _vhash,
        bytes32 request_hash
    )
        public
        view
        returns (
            address from,
            bytes memory pkey4v,
            bytes memory secret,
            bytes memory input,
            bytes memory forward_sig,
            bytes32 program_hash,
            bytes32 result_hash
        )
    {
        SGXRequest.Request storage r = all_data[_vhash].requests[request_hash];
        return (
            r.from,
            r.pkey4v,
            r.secret,
            r.input,
            r.forward_sig,
            r.program_hash,
            r.result_hash
        );
    }

    function getRequestInfo2(
        bytes32 _vhash,
        bytes32 request_hash
    )
        public
        view
        returns (
            address target_token,
            uint gas_price,
            uint block_number,
            uint256 revoke_block_num,
            uint256 data_use_price,
            uint program_use_price,
            SGXRequest.RequestStatus status,
            SGXRequest.ResultType result_type
        )
    {
        SGXRequest.Request storage r = all_data[_vhash].requests[request_hash];
        return (
            r.target_token,
            r.gas_price,
            r.block_number,
            r.revoke_block_num,
            r.data_use_price,
            r.program_use_price,
            r.status,
            r.result_type
        );
    }

    /////////////////////////////////////////////////////

    function delegateCallUseData(
        address _e,
        bytes memory _data
    ) public onlyRole(TRUSTED_ROLE) returns (bytes memory) {
        (bool succ, bytes memory returndata) = _e.delegatecall(_data);
        if (succ == false) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }
        require(succ, "delegateCallUseData failed");
        return returndata;
    }

    function getRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash
    ) public view returns (int) {
        return int(uint(all_data[_vhash].requests[request_hash].status));
    }

    function updateRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash,
        int status
    ) public onlyRole(TRUSTED_ROLE) {
        all_data[_vhash].requests[request_hash].status = SGXRequest
            .RequestStatus(status);
    }
}
