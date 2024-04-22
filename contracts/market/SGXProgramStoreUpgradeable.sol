// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProgramProxyInterface} from "./interface/ProgramProxyInterface.sol";
import {OwnerProxyInterface} from "./interface/OwnerProxyInterface.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// 不用可升级实现trustList转换accessControl
contract SGXProgramStoreUpgradeable is
    ProgramProxyInterface,
    AccessControlUpgradeable
{
    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");

    struct program_meta {
        string program_url;
        uint256 price;
        bytes32 enclave_hash;
        bool exists;
    }

    mapping(bytes32 => program_meta) public program_info;
    bytes32[] public program_hashes;
    OwnerProxyInterface public owner_proxy;

    function initialize(address _owner_proxy) public initializer {
        __AccessControl_init();
        owner_proxy = OwnerProxyInterface(_owner_proxy);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    event UploadProgram(bytes32 hash, address author);

    function upload_program(
        string memory _url,
        uint256 _price,
        bytes32 _enclave_hash
    ) public returns (bytes32) {
        bytes32 _hash = keccak256(
            abi.encodePacked(
                msg.sender,
                _url,
                _price,
                _enclave_hash,
                block.number
            )
        );
        require(!program_info[_hash].exists, "already exist");
        program_info[_hash].program_url = _url;
        program_info[_hash].price = _price;
        program_info[_hash].enclave_hash = _enclave_hash;
        program_info[_hash].exists = true;
        program_hashes.push(_hash);
        owner_proxy.initOwnerOf(_hash, msg.sender);
        emit UploadProgram(_hash, msg.sender);
        return _hash;
    }

    function program_price(bytes32 hash) public view returns (uint256) {
        return program_info[hash].price;
    }

    function program_owner(bytes32 hash) public view returns (address) {
        return owner_proxy.ownerOf(hash);
    }

    function get_program_info(
        bytes32 hash
    )
        public
        view
        returns (
            address author,
            string memory program_url,
            uint256 price,
            bytes32 enclaveHash
        )
    {
        require(program_info[hash].exists, "program not exist");
        program_meta storage m = program_info[hash];
        author = owner_proxy.ownerOf(hash);
        program_url = m.program_url;
        price = m.price;
        enclaveHash = m.enclave_hash;
    }

    function enclave_hash(bytes32 hash) public view returns (bytes32) {
        return program_info[hash].enclave_hash;
    }

    event ChangeProgramURL(bytes32 hash, string new_url);

    function change_program_url(
        bytes32 hash,
        string memory _new_url
    ) public returns (bool) {
        require(program_info[hash].exists, "program not exist");
        require(
            owner_proxy.ownerOf(hash) == msg.sender,
            "only owner can change this"
        );
        program_info[hash].program_url = _new_url;
        emit ChangeProgramURL(hash, _new_url);
        return true;
    }

    event ChangeProgramPrice(bytes32 hash, uint256 new_price);

    function change_program_price(
        bytes32 hash,
        uint256 _new_price
    ) public returns (bool) {
        require(program_info[hash].exists, "program not exist");
        require(
            owner_proxy.ownerOf(hash) == msg.sender,
            "only owner can change this"
        );
        program_info[hash].price = _new_price;
        emit ChangeProgramPrice(hash, _new_price);
        return true;
    }

    function is_program_hash_available(
        bytes32 hash
    ) public view returns (bool) {
        if (!program_info[hash].exists) {
            return false;
        }
        return true;
    }

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
}
