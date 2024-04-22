// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OwnerProxyInterface} from "../market/interface/OwnerProxyInterface.sol";
import {ProgramProxyInterface} from "../market/interface/ProgramProxyInterface.sol";
import {DataMarketPlaceInterface} from "../market/interface/DataMarketPlaceInterface.sol";
import {NaiveOwner} from "./NaiveOwner.sol";

contract DataMarketPlace_for_mine_test is DataMarketPlaceInterface {
    uint256 public _data_price;
    address public _data_owner;
    address public _buyer;
    bytes32 public constant _program_hash = "abc";
    ProgramProxyInterface public _program_proxy;
    OwnerProxyInterface public _owner_proxy =
        OwnerProxyInterface(new NaiveOwner());
    bytes32 public constant fake_bytes32 = "fake";
    bytes public constant fake_bytes = "fake";
    string public constant fake_string = "fake";
    address public constant fake_address = address(0x0);
    bytes32 public constant vhash = keccak256(abi.encodePacked("vhash"));
    bytes32 public constant requesthash =
        keccak256(abi.encodePacked("requesthash"));

    constructor(address __program_proxy) {
        _program_proxy = ProgramProxyInterface(__program_proxy);
    }

    event ChangeDataPrice(uint256 old, uint m);

    function changeDataPrice(uint256 __data_price) public {
        emit ChangeDataPrice(_data_price, __data_price);
        _data_price = __data_price;
    }

    function changeDataOwner(address __data_owner) public {
        _data_owner = __data_owner;
    }

    function changeBuyer(address __buyer) public {
        _buyer = __buyer;
    }

    function program_proxy() public view returns (ProgramProxyInterface) {
        return _program_proxy;
    }

    function owner_proxy() public view returns (OwnerProxyInterface) {
        return _owner_proxy;
    }

    function delegateCallUseData(
        address _e,
        bytes memory data
    ) public pure returns (bytes memory) {
        return "0";
    }

    function getRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash
    ) public view returns (int) {
        return 0;
    }

    function updateRequestStatus(
        bytes32 _vhash,
        bytes32 request_hash,
        int status
    ) public {
        return;
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
        require(_vhash == vhash, "1");
        return (
            fake_bytes32,
            fake_string,
            _data_price,
            fake_bytes,
            _data_owner,
            false,
            0,
            false
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
        require(_vhash == vhash && request_hash == requesthash, "2");
        return (
            _buyer,
            fake_bytes,
            fake_bytes,
            fake_bytes,
            fake_bytes,
            fake_bytes32,
            fake_bytes32
        );
    }

    function getRequestInfo2(
        bytes32 _vhash,
        bytes32 request_hash
    )
        public
        pure
        returns (
            address target_token,
            uint gas_price,
            uint block_number,
            uint256 revoke_block_num,
            uint256 data_use_price,
            uint program_use_price,
            uint status,
            uint result_type
        )
    {
        require(_vhash == vhash && request_hash == requesthash, "3");
        return (fake_address, 0, 0, 0, 0, 0, 0, 0);
    }

    function payment_token() external view override returns (address) {}
}

contract Program_Proxy is ProgramProxyInterface {
    address public algo_owner;
    uint256 public algo_price;
    bytes32 private constant _enclave_hash = "fakedata";

    constructor() {}

    function changeAlgoOwner(address _algo_owner) public {
        algo_owner = _algo_owner;
    }

    function changeAlgoPrice(uint256 _algo_price) public {
        algo_price = _algo_price;
    }

    function program_price(bytes32 hash) public view returns (uint256) {
        return algo_price;
    }

    function program_owner(bytes32 hash) public view returns (address) {
        return algo_owner;
    }

    function setProgramOwner(address _algo_owner) public {
        algo_owner = _algo_owner;
    }

    function setProgramPrice(uint256 _algo_price) public {
        algo_price = _algo_price;
    }

    function enclave_hash(bytes32 hash) public pure returns (bytes32) {
        return _enclave_hash;
    }

    function is_program_hash_available(
        bytes32 hash
    ) public pure returns (bool) {
        return true;
    }
}
